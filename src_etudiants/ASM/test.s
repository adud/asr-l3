	leti r0 0x10000
	setctr a0 r0

	leti r0 0b1111100000000000
	leti r1 0b0000011111000000
	leti r2 66		;'B'
	
	;; va ecrire le code ascii de r2
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

	leti r2 66
loop:	jump loop
; juste pour tester le préprocesseur :
#include mult.s
