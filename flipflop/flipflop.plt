set terminal epslatex
set output "flipflop.tex"

set xlabel "$t$"
set xtics 1,1,5
set grid xtics lw 3
plot[0:6][0:6.5] (int(x)%2)+0.5 title "ck",\
(x<1.5?1:(x<2.5?(2.5-x):0)) + 2 title "e",\
(x<2) + 3.5 title "a",\
(x<3) + 5 title "s"