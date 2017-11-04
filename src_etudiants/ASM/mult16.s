	;; Multiplication 32 bits
	;; si avant appel r0=A,r1=B, A*B <2**32
	;; apres appel r2*2**16 + r3 = A*B
	leti r0 0x1001
	leti r1 0x0FFF
	call mult16
end:
	jump end
mult16:
	leti r2 0 ; r2 contient les bits de poids fort du résultat
	leti r3 0 ; r3 contient les bits de poids faible du résultat
mainloop: 
	shift right r0 1	;inv r0*r1 + r2*(2**16)+r3
	jumpif nc skip
	add2 r3 r1
	and3i r4 r3 0xFFFF0000 ; Si r3 tient sur plus que 16 bits, on retire ce qui
	jumpif z skip          ; dépasse des 16 bits de r3 et on l'ajoute à r2.
	and2i r3 0xFFFF
	shift right r4 16
	add2 r2 r4
skip:
	shift left r1 1
	cmpi r0 0
	jumpif nz mainloop
	return
