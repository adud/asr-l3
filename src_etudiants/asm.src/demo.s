; Ce programme s'étant mis à ne plus rien faire
; Que d'étranges actions qui ne ressemblent à rien
; Pour corriger, j'ai ajouté des commentaires
;     Tout en Alexandrin

	leti r0 0b1110011100111000
	call graphic.s$clear_screen ; ainsi fut coloré l'écran d'un bleu profond...

	leti r0 0x620c0
	setctr a1 r0 ; ainsi fut aligné ce pointeur sur l'horloge...

	leti r0 0x10000
	setctr a0 r0 ; tandis que son ami regardait vers l'écran
	
	call aff.s$wrtxt ; cet écran sur lequel fut affiché un texte
	
	leti r5 20
	leti r0 -1

	leti r1 3
	let r2 r1
	leti r3 60
	leti r4 64
	
flp:	
    getctr a0 r6 ; saving a0
    call graphic.s$draw
    setctr a0 r6
	add2i r1 8
	add2i r3 2
	shift left r0 1
	sub2i r5 1
	jumpif nz flp

loop:	leti r0 0
	
	leti r1 60
	leti r2 68
	leti r3 98
	leti r4 78

    getctr a0 r6
	call graphic.s$fill ; Ainsi tout se barra en sucette ici-même.
    setctr a0 r6

	push r0
	leti r0 250
	call pause
	pop r0
	
	leti r0 0b100110001111111 ; just to have a pinkier pink.
	leti r1 67
	leti r2 69
	leti r3 70
	call aff.s$putchar

	add2i r1 8
	leti r3 51
	call aff.s$putchar

	add2i r1 8
	leti r3 68
	call aff.s$putchar

	push r0
	leti r0 200
	call pause
	pop r0

	call loop

	;;fait une pause de n ms, r0 = n
pause:	push r1
	push r2
	push r3
	push r4			;sauvegarde a1
	getctr a1 r4
	leti r3 0x62080
	setctr a1 r3
	readze a1 64 r1		;r1 := debut tps pause
	setctr a1 r3

lpi:
	readze a1 64 r2
	setctr a1 r3
	sub2 r2 r1
	cmp r2 r0
	jumpif slt lpi
	setctr a1 r4
	pop r4
	pop r3
	pop r2
	pop r1
	return
	
#include graphic.s
	
#include aff.s
