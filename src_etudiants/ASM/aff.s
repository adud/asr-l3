	leti r0 0x68000		
	setctr a1 r0
	leti r0 0x10000
	setctr a0 r0
	setctr sp r0		;initstack
		
	
	leti r0 0b0000000000000000
	leti r1 0b0000000000111110

	call write

	;; leti r0 10000
	;; setctr sp r0
	
	;; leti r0 -1
	;; leti r1 0
	;; leti r2 0
	;; leti r3 47
	
	;; call putchar

loop:	jump loop
	
	;; Ecrire un texte :
	;; a0 pointe vers l'ecran (est le crayon)
	;; a1 pointe vers le début de la chaine de car en memoire
	;; r0 couleur de fond
	;; r1 couleur du texte

	;; au long de l'execution :
	;; r2 contient le caractere a ecrire
	;; r3 r4 r5 sont detruits par prchr
	;; r6 contient la pos sur la ligne
	;; (evite des divisions par 160...)

#main
write:	push r2
	push r3
	push r4
	push r5
	push r6

	let r3 r0		;tout ca pour initialiser r6...
	let r4 r1

	getctr a0 r0
	sub2i r0 0x10000
	leti r1 160
	push r7
	call div.s$div
	pop r7
	let r6 r0
	
	let r0 r3
	let r1 r4		;initialisation terminee
	
	
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
	
ecr:	push r7
	call prchr
	pop r7
	add2i r6 0x80
	jump wh

out:	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	return

	;; FINAL
	;;va ecrire le code ascii de r2
	;; couleur r0 fond r1
prchr:	getctr a1 r5		
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

putchar:
	let r4 r1	;repondre aux spec du prof
	shift left r4 2
	add2 r4 r1
	shift left r4 5
	add2 r4 r2
	shift left r4 4
	add2i r4 0x10000
	setctr a0 r4
	let r1 r0
	leti r0 0
	let r2 r3
	push r7
	call prchr
	pop r7
	return
#include div.s
#endmain
