	leti r0 6
	leti r1 7
	call mult
loop:	jump loop

mult:	leti r2 0		;si r0=A r1=B
wb:	cmpi r0 0		;apres mult, r2=A*B
	jumpif z we
	and3i r3 r0 1
	jumpif z ie
	add2 r2 r1
ie:	shift left r1 1
	shift right r0 1
	jump wb
we:	return
