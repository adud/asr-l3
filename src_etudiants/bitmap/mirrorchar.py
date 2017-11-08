#! /usr/bin/python3

import sys

from PIL import Image
import io

im = Image.open(sys.argv[1])
nbelem = im.size[0]//8

for pos in range(128):
    box = (pos*8,0,(pos+1)*8,8)
    reg = im.crop(box).transpose(Image.FLIP_LEFT_RIGHT)
    im.paste(reg,box)

delim = sys.argv[1].rfind(".")
nom = sys.argv[1][:delim]
suf = sys.argv[1][delim:]

img_io = io.BytesIO()
im.save(img_io, 'bmp')
#im.save(nom[::-1],"bmp")
img_io.seek(0)

sys.stdout.buffer.write(img_io.read())
