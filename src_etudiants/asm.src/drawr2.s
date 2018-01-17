	leti r1 5
	leti r2 60
	call drawr2
	
loop:	jump loop

	
	.main
	;; draws r2d2 at r1 r2 (topleft corner)
	.include pictr2.s

drawr2:	push r7
	xor3i r2 r2 127
	let r3 r2
    	shift left r3 2
	add2 r3 r2
	shift left r3 5
	add2 r3 r1
	shift left r3 4
	add2i r3 0x10000
	setctr a0 r3		;a0 pointe sur l'ecran
	call pictr2.s$get_ptr
	setctr a1 r6		;a1 vers le droide

	leti r1 57
forloop1:
	leti r2 44
forloop2:	
	readze a1 16 r0
	write a0 16 r0
	sub2i r2 1
	jumpif nz forloop2

	add2i r3 2560 		;retour a la ligne
	setctr a0 r3

	sub2i r1 1
	jumpif nz forloop1
	pop r7
	return
	
	.endmain
