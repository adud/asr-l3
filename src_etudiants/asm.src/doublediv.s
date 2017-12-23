	leti r0 60
	leti r1 12

	leti r2 1
	leti r3 0x80000000

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
	;; flags non-garantis
	
shl2w23:
	shift left r2 1
	shift left r3 1
	jumpif nc eshl2w23
	add2i r2 1
eshl2w23:
	return

shl2w45:
	shift left r4 1
	shift left r5 1
	jumpif nc eshl2w45
	add2i r4 1
eshl2w45:
	return


shr2wb32:
	shift right r3 1
	shift right r2 1
	jumpif nc esr2wb32
	add2i r3 0x80000000
esr2wb32:	
	return
	;; effectue la soustraction de r0@r1 par r2@r3
	;; resultat dans r0 et r1
	;; flags non-garantis
	;; r4:7 conserves
sub2w:	sub2 r1 r3
	jumpif c dia		
	jumpif sgt nxt
	jumpif z nxt
dia:	sub2i r0 1
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
	;; deplace r2@r3 vers la droite pour r2@r3 >= r0@r1
	;; nb de decalages stocke dans r6
	add2i r6 1
	call shl2w23
	call cmp2w
	jumpif ge align

mainloop:
	call shr2wb32
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
