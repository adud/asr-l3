	leti r1 6
	leti r2 7
	call mult
	jump -13

mult:	leti r0 0		;si r1=A r2=B
wb:	cmp r1 0		;apres mult, r0=A*B
	jumpifz we
	and3i r3 r1 1
	jumpifz ie
	add2 r0 r2
ie:	shift left r2 1
	shift right r1 1
	jump wb
we:	return
	
