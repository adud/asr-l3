	leti r0 0x10004
taper:	setctr a1 r0
	readze a1 1 r1
	cmpi r1 1
	jumpif nz taper
loop:	jump loop
