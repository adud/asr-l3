	;; Multiplication signee
	;; si A=r0 B=r1 entiers relatifs
	;; apres appel, r2=A*B
	leti r0 -6
	leti r1	-7
	leti r5 0
	call mults
loop:	jump loop

#main

mults:	push r3
	push r4
	push r5
	sub3 r4 r5 r0
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
cpos:	pop r5
	pop r4
	pop r3
	return
	
#include mult.s

#endmain
