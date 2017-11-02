	;;Division
	;;si r0=A r1=B
	;; apres div: r2=A//B r3=A%B

	leti r0 19886
	leti r1 212
	call div
loop:	jump loop

div:
	leti r2 0
	let r3 r0
	let r4 r1

ind:	cmp r0 r4		;44bits lus
	jumpif le ectr		;par boucle
	shift left r4 1
	jump ind		

ectr:	cmp r3 r1	;inv: r3 + r1*r2 
	jumpif lt endiv	;nb bits lus<=108
	shift right r4 1
	shift left r2 1
	sub3 r5 r3 r4		
	jumpif lt nif
	let r3 r5
	add2i r2 1
nif:	jump ectr
endiv:	return
