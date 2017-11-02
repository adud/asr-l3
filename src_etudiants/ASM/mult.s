	leti r0 1928
	leti r1 2893
	call mult
loop:	jump loop

mult:	leti r2 0
wb:	shift right r0 1
	jumpif nc sk
	add2 r2 r1
sk:	shift left r1 1
	cmpi r0 0
	jumpif nz wb
	return
