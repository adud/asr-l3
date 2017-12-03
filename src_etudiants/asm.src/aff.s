	;; leti r0 0x62080		
	;; setctr a1 r0
	;; leti r0 0x10000
	;; setctr a0 r0
	;; setctr sp r0		;initstack
		
	
	;; leti r0 0b1111100000111110
	;; call wrtxt

	leti r0 0x10000
	setctr sp r0
	
	leti r0 -1
	leti r1 2
	leti r2 0
	leti r3 60
	
	call putchar
	
loop:	jump loop

#main
#include div.s
	;; Ecrire un texte :
	;; a0 pointe vers l'ecran (est le crayon)
	;; a1 pointe vers le début de la chaine de car en memoire
	;; r0 couleur de texte

	;; au long de l'execution :
	;; r1 contient le caractere a ecrire
	;; r2 r3 r4 r5 detruits par prchr
	;; r6 contient la pos sur la ligne
	;; (evite des divisions par 160...)

wrtxt:	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	let r3 r0		;tout ca pour initialiser r6...

	getctr a0 r0
	sub2i r0 0x10000
	leti r1 160
	push r7
	call div.s$div
	pop r7
	let r6 r0
	
	let r0 r3		;initialisation terminee
	
	
wh:	readze a1 8 r1
	cmpi r1 0		;NUL
	jumpif z out
	
	cmpi r1 0xd 		;CR
	jumpif nz ncr
	getctr a0 r2
	sub2 r2 r6
	setctr a0 r2
	leti r6 0
	jump wh
	
ncr:	cmpi r1 0xa		;LF
	jumpif nz nlf		;MS-DOS like
	getctr a0 r2		;CR is a CR and LF is a LF
	add2i r2 0x5000
	setctr a0 r2
	jump wh

nlf:	cmpi r6 0xa00		;prend en cpte l'arrivee
	jumpif nz ecr		;en bout de ligne
	getctr a0 r2		;effectue CR + LF
	sub2 r2 r6
	leti r6 0
	add2i r2 0x5000
	setctr a0 r2
	
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
	pop r1
	return

;;FIN wrtxt
	
	;;va ecrire le code ascii de r1 en a0
	;; couleur r0 
prchr:	push r1
	push r2
	push r3
	push r4
	push r5
	getctr a1 r4		;r4 va juste conserver a1
	shift left r1 3
	add2i r1 0x60000
	setctr a1 r1
	;; n'a plus besoin de r1

	leti r2 8
for1:
	readze a1 8 r1
	leti r3 8
for2:
	shift right r1 1
	jumpif c else
	getctr a0 r5
	add2i r5 0x10
	setctr a0 r5
	jump fi
else:	write a0 16 r0
fi:	
	sub2i r3 1
	jumpif nz for2

	getctr a1 r1
	add2i r1 0x3f8		;largeur de la bibli -8
	setctr a1 r1

	getctr a0 r1
	add2i r1 0x980		;(WIDTH-8) * 16
	setctr a0 r1		;descend d'une ligne revient de 8pix
	
	sub2i r2 1
	jumpif nz for1

	getctr a0 r1
	sub2i r1 0x4f80
	setctr a0 r1

	setctr a1 r4
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	return
	;;FIN prchr 
	
putchar:
	;; ecrit le caractere dont:
	;;  - la couleur est r0
	;;  - les coordonnees sont r1,r2
	;;  - le code ascii est r3
	;;
	push r1
	push r2
	push r3
	push r4
	getctr a0 r4
	push r4
	leti r4 120
	sub3 r2 r4 r2
	let r4 r2	;repondre aux spec du prof
	shift left r4 2
	add2 r4 r2
	shift left r4 5
	add2 r4 r1
	shift left r4 4
	add2i r4 0x10000
	setctr a0 r4
	let r1 r3
	push r7
	call prchr
	pop r7
	pop r4
	setctr a0 r4
	pop r4
	pop r3
	pop r2
	pop r1
	return

	;; FIN putchar
#endmain
