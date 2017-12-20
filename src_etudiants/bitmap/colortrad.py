#! /usr/bin/python3

from sys import argv
from math import floor

ent = int(argv[1],0) if len(argv)>1 else int(input("color ? "),0)

r, g, b = ent>>16,(ent>>8)&0xff,ent&0xff

r = floor(r/255*63)
g = floor(g/255*31)
b = floor(b/255*31)

print(hex(r<<10|g<<5|b))
