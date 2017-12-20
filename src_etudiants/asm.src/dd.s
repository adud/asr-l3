	;copie l'ecran juste en-dessous
	leti r0 0x0
	setctr a0 r0
	leti r0 0x0
	setctr a1 r0
	
	leti r1 0x10000
loop:	readze a0 64 r0
	write a1 64 r0
	sub2i r1 1
	jumpif nz loop

fin:	jump fin
