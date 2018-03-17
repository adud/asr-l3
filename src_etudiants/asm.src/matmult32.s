	.main
	.include mult.s
	;; matrice n*p : n*p cases consécutives de taille A(ici 32)
	;; les p premières lignes sont la ligne 1, les p suivantes 2…
	
	;; multipliaction de matrices :
	;; r0 r1 r2 r3 r4 r5 r6 r7
	;; @0 @1 ?? n  p  q  @2
	;; écrit dans @2 la matrice produit de la matrice
	;; n*p en @0 et la matrice p*q en @1
	;; appel non-terminal ! besoin push/pop r7

	;; principe : conserver les constantes utiles sur la pile (A pour Arch)
	;; +-------+
	;; |   n   | Ces constantes serviront à réinitialiser les
	;; |  npA  | compteurs de boucle et déplacer les pointeurs
	;; |  nqA  |
	;; |   p   | une multiplication étant TRÈS coûteuse, on ne fait
	;; |  pqA  | ces opérations qu'une fois
	;; | (q-1)A|

	;; @0 et @1 sont stockées dans a0 et a1, @2 dans r6

	;; les constantes 5, 32 = 2**5, 96=3*32 dépendent de l'architecture 
	;; initialisation de la pile

	setctr a0 r0
	setctr a1 r1
	push r3			;n

	let r1 r4
	push r7	
	call mult.s$mult
	pop r7
	shift left r2 5		;log A
	push r2			;npA
	
	let r1 r3
	push r7
	call mult.s$mult
	pop r7
	shift left r2 5		;log A
	push r2			;nqA

	push r4			;p
	
	let r0 r4
	push r7
	call mult.s$mult
	pop r7
	shift left r2 5		;log A
	push r2			;pqA

	sub2i r1 1
	shift left r2 5		;log A
	push r1			;(q-1)A
	
columns_loop:	
lines_loop:
scalar_prod_loop:
	readze a0 32 r0
	readze a1 32 r1
	push r7
	call mult.s$multsum

	getctr a1 r0
	pop r1			;(q-1)A
	push r1
	add2 r0 r1
	setctr a1 r0
	sub2i r4 1
	jumpif nz scalar_prod_loop

	getctr a1 r0
	setctr a1 r6
	write a1 32 r2

	pop r1			;(q-1)A
	add2 r6 r1
	add2i r6 32
	pop r2			;pqA

	sub2 r0 r2
	setctr a1 r0

	pop r4			;p
	push r4
	push r2			;pqA
	push r1			;(q-1)A

	sub2i r3 1
	jumpif nz lines_loop

	add2i r0 32
	setctr a1 r0
	
	getctr sp r0
	add2i r0 96
	setctr sp r0

	pop r1			;nqA
	sub2 r6 r1

	getctr a0 r3
	pop r2			;npA

	sub2 r3 r2
	setctr a0 r3
	pop r3			;n
	push r3
	push r2
	push r1
	sub2i r0 96
	setctr sp r0

	sub2i r5 1
	jumpif nz columns_loop

	return
	
	.endmain
