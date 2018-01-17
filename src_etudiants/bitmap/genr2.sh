magick r2.jpg -resize 100x100  r2c.ppm
magick r2c.ppm -crop 44x57+30+43 r2cp.ppm
magick r2cp.ppm -fuzz 80% -fill black -floodfill +43+1 white -floodfill +30+52 white -floodfill +15+52 white -floodfill +1+1 white -compress none r2fin.ppm
./colortrad.py r2fin.ppm > constr2.s
rm r2c.ppm r2cp.ppm r2fin.ppm

