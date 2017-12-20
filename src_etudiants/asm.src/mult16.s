	;; Multiplication 32 bits
	;; si avant appel r0=A,r1=B, A*B <2**32
	;; apres appel r2*2**16 + r3 = A*B
	;; conservation des registres r4-7
	leti r0 10000
	setctr sp r0		;stinit
	
	leti r0 0x1144aec4	;a,b : 0001,ffff
	leti r1 0x8c7d74d5	;c,d : 1000,0001
	call mult32
end:	jump end

#main
	
mult16:	push r4
	push r5
	leti r4 0 ; si r1 dépasse de 16 bits, les bits restants sont stockés en r4
	leti r2 0 ; r2 contient les bits de poids fort du résultat
	leti r3 0 ; r3 contient les bits de poids faible du résultat
mainloop: 
	shift right r0 1	;inv r0*r1 + r2*(2**16)+r3
	jumpif nc skip
	add2 r3 r1
	add2 r2 r4
	and3i r5 r3 0x10000 ; Si r3 tient sur 17 bits, on retire ce qui
	jumpif z skip       ; dépasse des 16 bits de r3 et on incrément r2
	and2i r3 0xffff
	add2i r2 1
skip:
	shift left r1 1
	shift left r4 1
	and3i r5 r1 0x10000
	jumpif z cond   ; si r1 tient sur 17 bits, on retire ce qui dépasse et on 
	and2i r1 0xffff ; incrémente r4.
	add2i r4 1
cond:
	cmpi r0 0
	jumpif nz mainloop
	pop r5
	pop r4
	return

	;; apres une multiplication 32 bits
	;; A*B = r2*2**16 + r3
	;; apres fusion
	;; A*B = r2
fusion:	
	shift left r2 16
	add2 r2 r3
	return
	;; multiplication 32 bits
	;; {r0 = uint32 A, r1 = uint32 B,
	;; A*B < 2**64}
	;; mult32
	;; {r2=C,r3=D, A*B = C*2**32 + D }
	;; tous les registres sont massacres
	
mult32:
	push r7			;A = aE + b; B= cE + d; E=2**16 
	and3i r5 r0 0xffff
	and3i r6 r1 0xffff
	shift right r0 16
	shift right r1 16
	
	push r0
	push r1
	
	let r1 r6
	
	call mult16
	call fusion

	let r4 r2
	let r0 r5
	let r1 r6

	call mult16
	call fusion

	let r6 r2
	let r0 r5
	pop r1
	push r1

	call mult16
	call fusion

	let r5 r2

	pop r1
	pop r0

	call mult16
	call fusion
	
	;r23456 : ac,??,ad,bc,bd

	let r0 r4
	let r1 r5
	shift left r0 16
	shift left r1 16
	shift right r4 16
	shift right r5 16

	add2 r6 r0
	jumpif nc sk1
	add2i r2 1
sk1:	add2 r6 r1
	jumpif nc sk2
	add2i r2 1
sk2:
	add2 r2 r4
	add2 r2 r5

	let r3 r6
		
	pop r7
	return
	
#endmain
