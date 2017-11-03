#!/usr/bin/env python

# This program assembles source assembly code into a bit string.
# The bit string includes spaces and newlines for readability,
# these should be ignored by the simulator when it reads the corresponding file.

import os
import sys
import re
import string
import argparse
from numpy import binary_repr

line=0 # global variable to make error reporting easier
current_address=0 # idem
labels={} # this dictionnary should not change during a pass
end_of_instr = {}
# for each relative jump instruction, maps the line of the instruction
# to the address at the end of the instruction. It should not change
# during a pass.
size_of_address = {}
# For each jump instruction, maps the line of the instruction to the
# size of the address operand contained in the instruction.

WORDSIZE = 32 #must be the same in simu.src/types.h
nb_iterations = 4

def error(e):
    raise BaseException("Error at line " + str(line) + " : " + e)



# All the asm_xxxx functions are helper functions that parse an operand and convert it into its binary encoding.
# Many are still missing

def asm_reg(s):
    "converts the string s into its encoding"
    if s[0]!='r':
        error("invalid register: " + s)
    try:
        val = int(s[1:])
    except ValueError:
        error("invalid register: " + s)
    if val<0 or val>7:
        error("invalid register: " + s)
    else:
        return binary_repr(val,3) + ' '  # thanks stack overflow. The 3 is the number of bits



def asm_addr_signed(s, iteration, instruction):
    """Converts the string s into its encoding

    iteration : the number of the pass
    instruction : either 'jump', 'jumpif' or 'call'."""
    # Is it a label or a constant? 
    if (s[0]>='0' and s[0]<='9') or s[0]=='-' or s[0]=='+' or s[0:2] == "0x" \
       or s[0:3] == "-0x":
        val=int(s) # TODO  catch exception here
        # The following is not very elegant but easy to trust
        if val>=-128 and val<= 127:
            return '0 ' + binary_repr(val, 8)
        elif val>=-32768 and val<= 32767:
            return '10 ' +  binary_repr(val, 16)
        elif val>=-(1<<31) and val <= (1<<31)-1:
            return '110 ' + binary_repr(val, 32)
        else:
            return '111 ' +  binary_repr(val, 64)
        
    elif iteration == 1:
        # In the first pass, there is no way to know how much bits the
        # the address take. We assume that the address takes the maximum
        # size, which is 32. Unknown bits are replaced by question marks.
        return "110 " + "?" * 32
    
    elif iteration < nb_iterations:
        # In the intermediates passes, we try to reduce the size taken by
        # the address.
        if instruction in ("jump", "jumpif"):
            address = labels[s] - end_of_instr[line]
        else: # instruction == "call"
            address = labels[s]
        # How much bits are needed to store the address ?
        if -128 <= address < 128:
            size_of_address[line] = 8
            return "0 " + "?" * 8
        elif (-1 << 15) <= address < (1 << 15):
            size_of_address[line] = 16
            return "10 " + "?" * 16
        else:
            size_of_address[line] = 32
            return "110 " + "?" * 32
        
    elif iteration == nb_iterations:
        # In the final pass, the address is finally given without any
        # question marks.
        if instruction in ("jump", "jumpif"):
            address = labels[s] - end_of_instr[line]
        else: # instruction == "call"
            address = labels[s]
        size = size_of_address[line]
        prefixes = {8:"0 ", 16:"10 ", 32:"110 "}
        print address
        return prefixes[size] + binary_repr(address, size)
            
    else:
        error("The label expansion at the iteration %d is not supported"
              % iteration)
    
    


        
def asm_const_unsigned(s):
    "converts the string s into its encoding"
    # Is it a label or a constant? 
    if (s[0]>='0' and s[0]<='9') or s[0:2]=="0x":
        try:
            val=int(s,0)
        except ValueError:
            error("Expecting a constant, got " + s)
        # The follwing is not very elegant but easy to trust
        if val==0 or val==1:
            return '0 ' + str(val)
        elif val< 256:
            return '10 ' + binary_repr(val, 8)
        elif  val< (1<<32):
            return '110 ' + binary_repr(val, 32)
        else:
            return '111 ' +  binary_repr(val, 64)
    else:
        error("Expecting a constant, got " + s)

        
def asm_const_signed(s):
    "converts the string s into its encoding"
    if (s[0]>='0' and s[0]<='9') or s[0] == "-" or s[0:2]=="0x" or \
       s[0:3]=="-0x":
        try:
            val=int(s,0)
        except ValueError:
            error("Expecting a constant, got " + s)
        if val==0 or val==1:
            return '0 ' + str(val)
        elif -128 <= val < 128:
            return '10 ' + binary_repr(val, 8)
        elif  (-1 << 31) <= val < (1 << 31):
            return '110 ' + binary_repr(val, 32)
        else:
            return '111 ' +  binary_repr(val, 64)
    else:
        error("Expecting a constant, got " + s)
    
def asm_shiftval(s):
    "converts the string s into its encoding"
    if (s[0]>='0' and s[0]<='9') or s[0:2]=="0x":
        try:
            val=int(s,0)
        except ValueError:
            error("Expecting a constant, got " + s)

        if val == 1:
            return "1"
        elif val < 64:
            return "0 " + binary_repr(val, 6)
        else:
            error("Expecting a constant between 0 and 63, got " + s)
    else:
        error("Expecting a constant between 0 and 63, got " + s)
           

def asm_condition(cond):
    """converts the string cond into its encoding in the condition code. """
    condlist = {"eq":"000", "z":"000",  "neq":"001",  "nz":"001",  "sgt":"010",  "slt":"011",  "gt":"100",  "ge":"101",  "nc":"101",  "lt":"110",  "c":"110",  "le":"111"}
    if cond in condlist:
        val = condlist[cond]
        return val + " "
    else:
        error("Invalid condition: " + cond)


def asm_counter(ctr):
    """converts the string ctr into its encoding. """
    codelist = {"pc":"00", "sp":"01",  "a0":"10",  "a1":"11",  "0":"00",  "1":"01",  "2":"10",  "3":"11"}
    if ctr in codelist:
        val = codelist[ctr]
        return val + " "
    else:
        error("Invalid counter: " + cond)



def asm_size(s):
    """converts the string s into its encoding. """
    codelist = {"1":"00", "4":"01",  "8":"100",  "16":"101",  "32":"110",  "64":"111"}
    if s in codelist:
        val = codelist[s]
        return val + " "
    else:
        error("Invalid size: " + str(s))


def asm_dir(dir):
    """converts the string s into its encoding. """
    codelist = {"left":"0", "right":"1", "0":"0", "1":"1"}
    if dir in codelist:
        return codelist[dir] + " "
    else:
        error("Invalid direction: " + dir)

def asm_pass(iteration, s_file):
    global line
    global labels
    global current_address
    global end_of_instr
    code =[] # array of strings, one entry per instruction
    line = 0
    new_labels = {}
    new_end_of_instr = {}
    print "\n PASS " + str(iteration)
    current_address = 0
    source = open(s_file)
    for source_line in source:
        instruction_encoding="" 
        print "processing " + source_line[0:-1] # just to get rid of the final newline

        # if there is a comment, get rid of it
        index = str.find(source_line, ";")
        if index !=-1:
            source_line = source_line[:index]

        # split the non-comment part of the line into tokens (thanks Stack Overflow) 
        tokens = re.findall('[\S]+', source_line) # \S means: any non-whitespace
        # print tokens # to debug

        # if there is a label, consume it
        if tokens:
            token=tokens[0]
            if token[-1] == ":": # last character
                label = token[0: -1] # all the characters except last one
                new_labels[label] = current_address
                tokens = tokens[1:]

        # now all that remains should be an instruction... or nothing
        if tokens:
            opcode = tokens[0]
            token_count = len(tokens)
            if opcode == "add2" and token_count==3:
                instruction_encoding = "0000 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "add2i" and token_count==3:
                instruction_encoding = "0001 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2])
            if opcode == "sub2" and token_count==3:
                instruction_encoding = "0010 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "sub2i" and token_count==3:
                instruction_encoding = "0011 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2])
            if opcode == "cmp" and token_count==3:
                instruction_encoding = "0100 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "cmpi" and token_count==3:
                instruction_encoding = "0101 " + asm_reg(tokens[1]) + asm_const_signed(tokens[2])
            if opcode == "let" and token_count==3:
                instruction_encoding = "0110 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "leti" and token_count==3:
                instruction_encoding = "0111 " + asm_reg(tokens[1]) + asm_const_signed(tokens[2])
            if opcode == "shift" and token_count == 4:
                instruction_encoding = "1000 " + asm_dir(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_shiftval(tokens[3])
            if opcode == "readze" and token_count == 4:
                instruction_encoding = "10010 " + asm_counter(tokens[1]) + asm_size(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "readse" and token_count == 4:
                instruction_encoding = "10011 " + asm_counter(tokens[1]) + asm_size(tokens[2]) + \
                                       asm_reg(tokens[3])
            # Here, a lot of constructive copypaste, for instance
            if opcode == "jump" and token_count==2:
                instruction_encoding = "1010 " + asm_addr_signed(tokens[1], iteration, "jump")
            #begin sabote
            if opcode == "jumpif" and token_count == 3:
                instruction_encoding = "1011 " + asm_condition(tokens[1]) + \
                                       asm_addr_signed(tokens[2], iteration, "jumpif")
            if opcode == "or2" and token_count==3:
                instruction_encoding = "110000 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "or2i" and token_count==3:
                instruction_encoding = "110001 " + asm_reg(tokens[1]) + asm_const_signed(tokens[2])
            if opcode == "and2" and token_count==3:
                instruction_encoding = "110010 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "and2i" and token_count==3:
                instruction_encoding = "110011 " + asm_reg(tokens[1]) + asm_const_signed(tokens[2])
            if opcode == "write" and token_count == 4:
                instruction_encoding = "110100 " + asm_counter(tokens[1]) + asm_size(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "call" and token_count == 2:
                instruction_encoding = "110101 " + asm_addr_signed(tokens[1], iteration, "call")
            if opcode == "setctr" and token_count == 3:
                instruction_encoding = "110110 " + asm_counter(tokens[1]) + asm_reg(tokens[2])
            if opcode == "getctr" and token_count == 3:
                instruction_encoding = "110111 " + asm_counter(tokens[1]) + asm_reg(tokens[2])
            if opcode == "push" and token_count == 2:
                instruction_encoding = "1110000 " + asm_reg(tokens[1])
            if opcode == "pop" and token_count ==2:
                #not really an opcode, only syntax sugar for readse sp WORDSIZE  
                instruction_encoding = "10010 " + asm_counter("sp") +\
                                       asm_size(str(WORDSIZE)) + asm_reg(tokens[1])
            if opcode == "return" and token_count == 1:
                instruction_encoding = "1110001"
            if opcode == "add3" and token_count == 4:
                instruction_encoding = "1110010 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "add3i" and token_count == 4:
                instruction_encoding = "1110011 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_unsigned(tokens[3])
            if opcode == "sub3" and token_count == 4:
                instruction_encoding = "1110100 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "sub3i" and token_count == 4:
                instruction_encoding = "1110101 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_unsigned(tokens[3])
            if opcode == "and3" and token_count == 4:
                instruction_encoding = "1110110 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "and3i" and token_count == 4:
                instruction_encoding = "1110111 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_signed(tokens[3])
    
            if opcode == "or3" and token_count == 4:
                instruction_encoding = "1111000 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "or3i" and token_count == 4:
                instruction_encoding = "1111001 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_signed(tokens[3])
            if opcode == "xor3" and token_count == 4:
                instruction_encoding = "1111010 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "xor3i" and token_count == 4:
                instruction_encoding = "1111011 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_signed(tokens[3])
            if opcode == "asr3" and token_count == 4:
                instruction_encoding = "1111100 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_shiftval(tokens[3])
            #end sabote
                    
            # If the line wasn't assembled:
            if instruction_encoding=="":
                error("don't know what to do with: " + source_line)
            else:
                # get rid of spaces. Thanks Stack Overflow
                compact_encoding = ''.join(instruction_encoding.split()) 
                instr_size = len(compact_encoding)
                # Debug output
                print "... @" + str(current_address) + " " + binary_repr(current_address,16) + "  :  " + compact_encoding
                print  "                          "+  instruction_encoding+ "   size=" + str(instr_size)    
                current_address += instr_size
                if opcode in ("jump", "jumpif"):
                    new_end_of_instr[line] = current_address

                
        line += 1
        code.append(instruction_encoding)
    source.close()
    labels = new_labels
    end_of_instr = new_end_of_instr
    return code




#/* main */
if __name__ == '__main__':

    argparser = argparse.ArgumentParser(description='This is the assembler for the ASR2017 processor @ ENS-Lyon')
    argparser.add_argument('filename', help='name of the source file.  "python asm.py toto.s" assembles toto.s into toto.obj')

    options=argparser.parse_args()
    filename = options.filename
    basefilename, extension = os.path.splitext(filename)
    obj_file = basefilename+".obj"

    for i in range(1, nb_iterations + 1):
        code = asm_pass(i, filename)
    
    # statistics
    print "Average instruction size is " + str(1.0*current_address/len(code))
    
    outfile = open(obj_file, "w")
    for instr in code:
        outfile.write(instr)
        outfile.write("\n")


    outfile.close()
