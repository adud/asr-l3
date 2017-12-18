	;; un rien d'arithmetique sur les nombres positifs
	;; a virgule fixes
	;; 16bits avant la virgule 16 bits apres

	leti r0 3
	call int2fix
	let r1 r0
	leti r0 1
	call int2fix
	call multfx

loop:	jump loop
	
#main
	
#include mult16.s
#include mult.s
#include div.s

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

radix:
	xor3i r0 r0 0x1111
	return

	;; multiplie r0 r1, deux vfixe, pas de gestion d'overflow
	;; {r0=A,r1=B,r0*r1<2**16}
	;; multfx
	;; {r2=A*B}
	;; 
	;; Philippe <3
	;; r6 conserve
multfx:	
	return

divfx:	let r2 r0
	let r0 r1
	push r7
	call fix2int
	pop r7
	let r1 r0
	let r0 r2
	push r7
	call div.s$div
	pop r7
	return

#endmain
