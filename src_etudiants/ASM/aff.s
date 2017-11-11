	leti r0 0x68000
	setctr a1 r0
	
	leti r0 0x10000
	setctr a0 r0
	leti r6 0
	
	setctr sp r0		;init stack

	leti r0 0b0000000000000000
	leti r1 0b0000000000111110

	;; Ecrire un texte :
	;; a0 pointe vers l'ecran (est le crayon)
	;; a1 pointe vers la place du mot en memoire
	;; r0 couleur de fond
	;; r1 couleur du texte
	;; r2 contient le caractere a ecrire
	;; r3 r4 r5 sont detruits par prchr
	;; r6 contient la pos sur la ligne
	;; (evite des divisions par 160...)

wh:	readze a1 8 r2
	cmpi r2 0		;NUL
	jumpif z out
	
	cmpi r2 0xd 		;CR
	jumpif nz ncr
	getctr a0 r3
	sub2 r3 r6
	setctr a0 r3
	leti r6 0
	jump wh
	
ncr:	cmpi r2 0xa		;LF
	jumpif nz nlf		;MS-DOS like
	getctr a0 r3		;CR is a CR and LF is a LF
	add2i r3 0x5000
	setctr a0 r3
	jump wh

nlf:	cmpi r6 0xa00		;prend en cpte l'arrivee
	jumpif nz ecr		;en bout de ligne
	getctr a0 r3
	sub2 r3 r6
	leti r6 0
	add2i r3 0x5000
	setctr a0 r3
ecr:	call prchr
	add2i r6 0x80
	jump wh
out:	jump out
	
	
prchr:	;; va ecrire le code ascii de r2
	;; couleur r0 fond r1
	getctr a1 r5
	shift left r2 3
	add2i r2 0x60000
	setctr a1 r2
	;; n'a plus besoin de r2

	leti r3 8
for1:
	readze a1 8 r2
	leti r4 8
for2:
	shift right r2 1
	jumpif c else
	write a0 16 r0
	jump fi
else:	write a0 16 r1
fi:	
	sub2i r4 1
	jumpif nz for2

	getctr a1 r2
	add2i r2 0x3f8		;largeur de la bibli -8
	setctr a1 r2

	getctr a0 r2
	add2i r2 0x980		;(WIDTH-8) * 16
	setctr a0 r2		;descend d'une ligne revient de 8pix
	
	sub2i r3 1
	jumpif nz for1

	getctr a0 r2
	sub2i r2 0x4f80
	setctr a0 r2

	setctr a1 r5
	return
