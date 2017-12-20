	;; un rien d'arithmetique sur les nombres positifs
	;; a virgule fixes
	;; 16bits avant la virgule 16 bits apres

	leti r1 0x5555
	leti r0 3
	call int2fix
	call multfx
	let r0 r2
	call fix2int
loop:	jump loop
	
.main
	
.include mult16.s
.include mult.s
.include div.s

	;; fait passer r0 d'entier a virgule fixe
	
int2fix:
	shift left r0 16
	return

	;; de virgule fixe a entier en arrondissant
	
fix2int:
	shift right r0 16
	jumpif nc end
	add2i r0 1	
end:	return

	;; la partie deucimale d'un nombre
radix:
	and2i r0 0x1111
	return

	;; multiplie r0 r1, deux vfixe, pas de gestion d'overflow
	;; {r0=A,r1=B,r0*r1<2**16}
	;; multfx
	;; {r2=A*B}
	;; 
	;; Philippe <3
	;; pas de registre conserve
multfx:
	push r7
	call mult16.s$mult32
	shift left r2 16
	shift right r3 16
	add2 r2 r3
	pop r7
	return

divfx:	return
	


.endmain
