	;;Multiplication :
	;; si avant appel r0=A,r1=B, A*B < 2**16
	;; apres appel r2=A*B
	leti r0 1928
	leti r1 2893
	call mult
loop:	jump loop

#main ; le code intéressant commence à partir de maintenant
mult:	push r0
	push r1
	leti r2 0
wb:	shift right r0 1	;inv:r0*r1+r2
	jumpif nc sk		;nb bits lus<=69
	add2 r2 r1
sk:	shift left r1 1
	cmpi r0 0
	jumpif nz wb
	pop r1
	pop r0
	return
#endmain
