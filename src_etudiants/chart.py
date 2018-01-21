#! /usr/bin/python3
# -*- coding:utf-8 -*-

from sys import stdin
import matplotlib.pyplot as plt
from numpy import arange

#plt.xkcd()

data = stdin.readlines()
opfreq = data[5:data.index("\n",6)+1]
opfreq.pop()
opfreq = [li.split()[0:2] for li in opfreq]
opfreq = [(i,int(j)) for (i,j) in opfreq]

barres = list(zip(*opfreq))

y_pos = arange(len(barres[1]))
plt.barh(y_pos, barres[1][::-1])
plt.yticks(y_pos,barres[0][::-1])

plt.show()
