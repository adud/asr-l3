#! /usr/bin/python3

from sys import argv

def colortrad(r,g,b):
    return hex((r>>2)<<10|(g>>3)<<5|(b>>3))

def ppmtrad(filename):
    sortie = \
    """get_ptr: 
    getctr pc r6 
    add2i r6 24 
    return 
.const """
    with open(filename,"r") as f:
        data = f.readlines()
    head = data[1].split()
    head.append(data[2])
    head = [int(i) for i in head]
    sortie += str(head[0]*head[1]*16) + " 0x"
    for ligne in data[3:]:
        ligne = [int(i) for i in ligne.split()]
        for i in range(len(ligne)//3):
            r,g,b = ligne[3*i:3*(i+1)]
            sortie+=colortrad(r,g,b)[2:].rjust(4,"0")
    return sortie

if __name__ == "__main__":
    print(colortrad(int(argv[1]),int(argv[2]),int(argv[3])))
