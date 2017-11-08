#! /bin/bash
#stdin : bitmap stdout : pbm sans spaces,retour ligne
python3 mirrorchar.py $1 | convert -compress none bmp:- pbm:- |sed '1,2 d' |sed -ze 's/\s//g;/^\s*$/d'
