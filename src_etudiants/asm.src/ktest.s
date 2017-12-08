	leti r0 0x62000
taper:	setctr a1 r0
	leti r2 0
klp:	readze a1 1 r1
	cmpi r1 0
	jumpif nz out
	add2i r2 1
	cmpi r2 0x80
	jumpif nz klp
	jump taper
out:	add2i r2 93
	let r3 r2
	leti r0 -1
	leti r1 0
	leti r2 0
	
	call aff.s$putchar

loop:	jump loop

#include aff.s	
