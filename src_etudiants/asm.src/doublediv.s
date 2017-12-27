	leti r0 0x9c060000
	leti r1 0x00000000

	leti r2 0x00000000
	leti r3 0x08000000

	;; call cmp2w
	 ;; call shl2w23
	call div2w
	
loop:	jump loop
	
.main
	
	;; comparaison sur deux mots non-signee :
	;; si r0@r1 et r2@r3 mots de taille (2*WS)
	;; applique l'ordre lexicographique sur les valeurs
	;; resultat dans les flags
	
cmp2w:	cmp r0 r2
	jumpif nz endc2w
	cmp r1 r3
endc2w:	return

	;; shift left de 1 sur 2 mots r2@r3
	;; r0:1,4:7 conserves
	;; cflag garanti, pas les autres
	
shl2w23:
	push r4
	leti r4 0
	shift left r2 1
	jumpif nc no_carry23
	leti r4 -1 
no_carry23:	
	shift left r3 1
	jumpif nc no_little_carry23
	add2i r2 1
no_little_carry23:
	shift left r4 1
	pop r4
	return

shl2w45:
	push r6
	leti r6 0
	shift left r4 1
	jumpif nc no_carry45
	leti r6 -1
no_carry45:
	shift left r5 1
	jumpif nc no_little_carry45
	add2i r4 1
no_little_carry45:
	shift left r6 1
	pop r6
	return


shr2w23b32:
	shift right r3 1
	shift right r2 1
	jumpif nc no_carry_right_23
	add2i r3 0x80000000 	;MSB in 32bits arch (I need macros)
no_carry_right_23:
	return

	
	;; effectue la soustraction de r0@r1 par r2@r3
	;; resultat dans r0 et r1
	;; flags non-garantis
	;; r4:7 conserves
sub2w:	sub2 r1 r3
	jumpif ge nxt
	sub2i r0 1
nxt:	sub2 r0 r2
	return

	;; on a tout pour faire la division
	;; division euclidienne :
	;; si r0@r1 = A, r2@r3 = B
	;; apres div2w : r0@r1 = A%B r4@r5 = A//B
	;; aucun registre conserve
div2w:
	push r7
	leti r4 0
	leti r5 0
	leti r6 0
align:
	;; deplace r2@r3 vers la droite pour r2@r3 > r0@r1
	;; nb de decalages stocke dans r6
	;; ne pas oublier le cas ou r2 depasse sur la gauche
	;; sinon entre dans une boucle infinie (== division par 0)
	add2i r6 1
	call shl2w23
	jumpif c depassement
	call cmp2w
	jumpif ge align
	jump mainloop

depassement:	
	call shr2w23b32
	add2i r2 0x80000000 	;MSB in 32bits arch
	call sub2w
	add2i r5 1
	sub2i r6 1
mainloop:
	call shr2w23b32
	call shl2w45

	call cmp2w
	jumpif lt cndar

	call sub2w
	add2i r5 1
	
cndar:	sub2i r6 1
	jumpif nz mainloop
lafin:	pop r7
	return
.endmain
