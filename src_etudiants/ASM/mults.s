	;; Multiplication signee
	;; si A=r0 B=r1 entiers relatifs
	;; apres appel, r2=A*B
	leti r0 -6
	leti r1	-7
	leti r5 0
	call mults
loop:	jump loop

mults:	sub3 r4 r5 r0
	jumpif slt apos
	let r0 r4
	xor3i r3 r3 1
apos:	sub3 r4 r5 r1
	jumpif slt bpos
	let r1 r4
	xor3i r3 r3 1

bpos:	push r7
	call mult
	pop r7
	cmpi r3 0
	jumpif z cpos
	sub3 r2 r5 r2
cpos:	return

mult:	leti r2 0
wb:	shift right r0 1	
	jumpif nc sk	
	add2 r2 r1
sk:	shift left r1 1
	cmpi r0 0
	jumpif nz wb
	return
