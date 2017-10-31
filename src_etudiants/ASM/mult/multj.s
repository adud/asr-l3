	leti r0 127
	leti r1 127
	call 62
	jump -13

mult:	leti r2 0		;si r0=A r1=B
wb:	cmpi r0 0		;apres mult, r2=A*B
	jumpif z 72
	and3i r3 r0 1
	jumpif z 10
	add2 r2 r1
ie:	shift left r1 1
	shift right r0 1
	jump -97
we:	return
