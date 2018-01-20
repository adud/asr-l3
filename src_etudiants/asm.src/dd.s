	leti r0 0x10000
	setctr a0 r0
	leti r0 0x60000
	setctr a0 r0
	leti r0 0x2800

loop:	jump loop 

.main

	;; dd copy r0*4 bytes
	;; from a0 to a1
dd:	readze a0 32 r1
	write a1 32 r1
	sub2i r0 1
	jumpif nz dd
	return

.endmain
