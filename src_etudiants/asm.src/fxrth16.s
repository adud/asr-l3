	;; un rien d'arithmetique sur les nombres positifs
	;; a virgule fixes
	;; 16bits avant la virgule 16 bits apres

	leti r0 3
	call int2fix
	let r1 r0
	leti r0 10
	call int2fix
	call divfix
	leti r0 3
	call int2fix
	let r1 r0
	let r0 r2
	call multfix
	
loop:	jump loop
	
.main
	
.include mult16.s
.include mult.s
.include doublediv.s
	
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
multfix:
	push r7
	call mult16.s$mult32
	shift left r2 16
	shift right r3 16
	add2 r2 r3
	pop r7
	return

	;; divise r0 par r1, pas de gestion de l'overflow
	;; {r0=A,r1=B,r0*r1<2**16}
	;; divfx
	;; {r2=A/B}
	;; aucun registre conserve
divfix:	push r7
	let r3 r1
	leti r1 0
	call doublediv.s$div2w
	shift right r5 16
	shift left r4 16
	let r2 r5
	add2 r2 r4
	pop r7
	return
.endmain
