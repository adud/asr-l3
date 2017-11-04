	;;Multiplication :
	;; si avant appel r0=A,r1=B, A*B < 2**16
	;; apres appel r2=A*B
	leti r0 1928
	leti r1 2893
	call mult
loop:	jump loop

mult:	leti r2 0
wb:	shift right r0 1	;inv:r0*r1+r2
	jumpif nc sk		;nb bits lus<=69
	add2 r2 r1
sk:	shift left r1 1
	cmpi r0 0
	jumpif nz wb
	return
