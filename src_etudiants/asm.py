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

verb = 0
VBMAX = 2
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
        val=int(s,0) # TODO  catch exception here
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
            try:
                address = labels[s] - end_of_instr[line]
            except KeyError:
                error("unknown label : "+s)
        else: # instruction == "call"
            try:
                address = labels[s]
            except KeyError:
                error("unknown label : "+s)
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
        if verb >= VBMAX:
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
        if val==0:
            return '0 0'
        elif val==-1:
            return '0 1'
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
    condlist = {"eq":"000", "z":"000",  "neq":"001",  "nz":"001",  "sgt":"010",  "slt":"011",  "gt":"100",  "ge":"101",  "nc":"101",  "lt":"110",  "c":"110",  "v":"111"}
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
        error("Invalid counter: " + ctr)



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

def get_lines(filename):
    """Turn the text of a file into a list of lines."""
    with open(filename) as f:
        lines = f.readlines()
    lines = [l[:-1] for l in lines] # remove the last '\n' characters
    return lines

def get_path(file):
    global filename
    
    if file[0] != "/": # relative file name
        # we want to get the current directory, so everything after the last
        # '/' character is removed
        path_list = filename.split("/")
        # the 'name' variable replace the last element of 'path'
        path_list[-1] = file
        return "/".join(path_list)
    else:
        # absolute file name
        return file


def include_file(i_file, baselabel):
    """Load a file, and return the code lines. If two lines '.main' and
    '.endmain' are defined, load only the code between these two lines.

    The code lines are returned as a list.

    i_file : the file to include"""

    # the name of the included file is added after the base label, followed by
    # the '$' character. This character is reserved.
    baselabel += i_file + "$"

    lines = get_lines(get_path(i_file))
    
    main_expr = re.compile("^\s*\.main\s*($|;)")
    endmain_expr = re.compile("^\s*\.endmain\s*($|;)")

    main_lines = [i for (i, l) in enumerate(lines)
                  if main_expr.match(l) is not None]
    endmain_lines = [i for (i, l) in enumerate(lines)
                     if endmain_expr.match(l) is not None]

    if main_lines == [] and endmain_lines == []:
        # recursively preprocessing the lines
        return preprocess(lines, baselabel, False, "")
    elif len(main_lines) > 1:
        raise BaseException("Loading error : too much .main directives.")
    elif len(endmain_lines) > 1:
        raise BaseException("Loading error : too much .endmain directives.")
    elif main_lines == []:
        raise BaseException("Loading error : .main directive missing.")
    elif endmain_lines == []:
        raise BaseException("Loading error : .endmain directive missing.")
    else:
        [main] = main_lines
        [endmain] = endmain_lines
        if main >= endmain:
            raise BaseException("Loading error : .main directive "
                                "defined after .endmain.")

        return preprocess(lines[main+1:endmain], baselabel, False, "")

# This list stores all the recursively included files during the preprocessing
# operation.
recinc_files = []
def preprocess(lines, baselabel="", make_dependencies=False, base_obj_file=""):
    """Apply the preprocesor operations to a list of lines.
    baselabel is the string that is added before every label."""
    # we assume that the user use neither ';' nor whitespace characters in
    directive_expr = re.compile("^\s*\.") # any directive
    include_expr = re.compile("^\s*\.include\s+(?P<i_file>[^;\s]+)\s*($|;)")
    main_expr = re.compile("^\s*\.main\s*($|;)")
    endmain_expr = re.compile("^\s*\.endmain\s*($|;)")
    const_expr1 = re.compile("^\s*\.const\s+[^;\s]+\s+[^;\s]+\s*($|;)")
    const_expr2 = re.compile(r'^\s*\.const\s+".*[^\\]"\s*(;|$)')
        
    final_lines = []
    files_to_include = [] # files are included at the end.
    for l in lines:
        if directive_expr.match(l) and \
           not (const_expr1.match(l) or const_expr2.match(l)):
            # this line is a directive other than a .const directive
            m = include_expr.match(l)
            if m is not None:
                i_file = m.group("i_file")
                # included lines are added in the file
                files_to_include.append(i_file)
            elif main_expr.match(l) or endmain_expr.match(l):
                pass
            else:
                # this directive is not valid
                raise BaseException("Don't know what to do with : " + l)
        else:
            if ";" in l: # remove the commentaries
                l = l[:l.find(";")]
            # split the line
            tokens = re.findall("[\S]+", l)
            # If there is a label, add the base label before and consume it.
            if tokens != [] and tokens[0][-1] == ":":
                label = tokens[0]
                if "$" in label:
                    raise BaseException("Error : the label %s contains a '$' "
                                        "character" % label)
                label = [baselabel + label]
                tokens = tokens[1:]
            else:
                label = []

            if tokens != [] and tokens[0] in ("call", "jump", "jumpif"):
                # If there is a jump to a label, add the baselabel before
                addr = tokens[-1]
                if addr[0] not in "0123456789+-":
                    # the address in a label
                    tokens[-1] = baselabel + addr

            l = " ".join(label + tokens)
            final_lines.append(l)

    for i_file in files_to_include:
        final_lines.extend(include_file(i_file, baselabel))
        recinc_files.append(i_file)

    if verb>=VBMAX:
        print "After the preprocessing operation :"
        for l in final_lines:
            print l

    if make_dependencies:
        with open(base_obj_file + ".d", "w") as f:
            path_to_include = [get_path(file) for file in recinc_files]
            f.write(base_obj_file + ".obj" + ": " +
                    " ".join(path_to_include) + "\n\n")

    return final_lines

def asm_pass(iteration, lines):
    global line
    global labels
    global current_address
    global end_of_instr
    code =[] # array of strings, one entry per instruction
    line = 0
    new_labels = {}
    new_end_of_instr = {}
    if verb>=1:
        print "PASS " + str(iteration)
    current_address = 0
    for source_line in lines:
        instruction_encoding=""
        if verb >= VBMAX:
            print "processing " + source_line # just to get rid of the
            #final newline

        # if there is a comment, get rid of it
        index = str.find(source_line, ";")
        if index !=-1:
            source_line = source_line[:index]

        # split the non-comment part of the line into tokens (thanks Stack Overflow) 
        tokens = re.findall('[\S]+', source_line) # \S means: any non-whitespace

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
                instruction_encoding = "110001 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2])
            if opcode == "and2" and token_count==3:
                instruction_encoding = "110010 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "and2i" and token_count==3:
                instruction_encoding = "110011 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2])
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
                                       asm_const_unsigned(tokens[3])
    
            if opcode == "or3" and token_count == 4:
                instruction_encoding = "1111000 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "or3i" and token_count == 4:
                instruction_encoding = "1111001 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_unsigned(tokens[3])
            if opcode == "xor3" and token_count == 4:
                instruction_encoding = "1111010 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_reg(tokens[3])
            if opcode == "xor3i" and token_count == 4:
                instruction_encoding = "1111011 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_const_unsigned(tokens[3])
            if opcode == "asr3" and token_count == 4:
                instruction_encoding = "1111100 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + \
                                       asm_shiftval(tokens[3])
            if opcode == ".const":
                const_expr1 = re.compile("^\s*\.const\s+(?P<n>[^;\s]+)\s+"
                                         "(?P<val>[^;\s]+)\s*(;|$)")
                const_expr2 = re.compile(r'^\s*\.const\s+(?P<str>".*[^\\]")\s*(;|$)')
                m1 = const_expr1.match(source_line)
                m2 = const_expr2.match(source_line)
                if m1 is not None:
                    size = int(m1.group("n"), 0)
                    val = int(m1.group("val"), 0)
                    instruction_encoding = binary_repr(val, size)
                elif m2 is not None:
                    s = eval(m2.group("str"))
                    list_bytes = [ord(c) for c in s] + [0] # adding the EOF
                    instruction_encoding = " ".join([binary_repr(b, 8)
                                                     for b in list_bytes])
            #end sabote
                    
            # If the line wasn't assembled:
            if instruction_encoding=="":
                error("don't know what to do with: " + source_line)
            else:
                # get rid of spaces. Thanks Stack Overflow
                compact_encoding = ''.join(instruction_encoding.split()) 
                instr_size = len(compact_encoding)
                # Debug output
                if verb >= VBMAX:
                    print "... @" + str(current_address) + " " + binary_repr(current_address,16) + "  :  " + compact_encoding
                    print  "                          "+  instruction_encoding+ "   size=" + str(instr_size)    
                current_address += instr_size
                if opcode in ("jump", "jumpif"):
                    new_end_of_instr[line] = current_address

                
        line += 1
        code.append(instruction_encoding)
    labels = new_labels
    end_of_instr = new_end_of_instr
    return code




#/* main */
if __name__ == '__main__':

    argparser = argparse.ArgumentParser(description='This is the assembler '
                                        'for the ASR2017 processor @ ENS-Lyon')
    argparser.add_argument('filename', help='name of the source file.  '
                           '"python asm.py toto.s" assembles toto.s into toto.obj')
    argparser.add_argument('-a', '--architecture', type=int, choices=(32, 64),
                           default=32, help='Decide wether it is a 32 or a 64 '
                                            'bits architecture. Default is 32')
    argparser.add_argument('-v', '--verbose', type=int, default=0,
                           help='verbose output')
    argparser.add_argument('-MD', '--make_dependencies',
                           help="generate a file containing dependencies",
                           action="store_true")
    argparser.add_argument('-o', '--outfile')
    argparser.add_argument('-opp', '--only_preprocess', action="store_true",
                           help="only preprocess the file")
    argparser.add_argument('-npp', '--no_preprocess', action="store_true",
                           help="bypass the preprocess")
    options=argparser.parse_args()
    filename = options.filename
    WORDSIZE = options.architecture
    verb = options.verbose
    make_dependencies = options.make_dependencies
    if options.outfile is None:
        oext = ".e" if options.only_preprocess else ".obj" 
        basefilename, extension = os.path.splitext(filename)
        obj_file = basefilename+oext
        base_obj_file = basefilename
    else:
        base_obj_file, extension = os.path.splitext(options.outfile)
        obj_file = options.outfile

    if make_dependencies:
        print("making dependencies...")

    print options.no_preprocess
    if not options.no_preprocess:
        lines = preprocess(get_lines(filename), "", make_dependencies,
                           base_obj_file)
    else:
        lines = get_lines(filename)

    if not options.only_preprocess:
        for i in range(1, nb_iterations + 1):
            code = asm_pass(i, lines)
    else:
        code = lines
            
    # statistics
    
    outfile = open(obj_file, "w")
    for instr in code:
        outfile.write(instr)
        outfile.write("\n")

    if verb >= 1:
        print "Average instruction size is " + str(1.0*current_address/len(code))
        print "with version ==" + str(WORDSIZE) + "=="
    outfile.close()
    
