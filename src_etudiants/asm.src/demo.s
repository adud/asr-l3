; Ce programme s'étant mis à ne plus rien faire
; Que d'étranges actions qui ne ressemblent à rien
; Pour corriger, j'ai ajouté des commentaires
;     Tout en Alexandrin

.include graphic.s
.include aff.s
.include attact.s	

	leti r0 0b1110011100111000
	call graphic.s$clear_screen ; ainsi fut coloré l'écran d'un bleu profond...

	leti r0 0x620c0
	setctr a1 r0 ; ainsi fut aligné ce pointeur sur un texte
	leti r0 0b0001110011100111
	call graphic.s$clear_screen ; ainsi fut coloré l'écran d'un bleu profond...

    call get_text ; ainsi fut aligné ce pointeur sur les mots...
    setctr a1 r6

	leti r0 0x10000
	setctr a0 r0 ; tandis que son ami regardait vers l'écran
	
	call aff.s$wrtxt ; cet écran sur lequel fut affiché le verbe
	
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

	leti r6 10
loop:	leti r0 0
	
	leti r1 60
	leti r2 68
	leti r3 98
	leti r4 78
	
	push r6
    getctr a0 r6
	call graphic.s$fill
    setctr a0 r6
	pop r6
	
	push r0
	leti r0 250
	call attact.s$pause
	pop r0
	
	leti r0 0b111111100011001 ; just to have a pinkier pink.
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
	call attact.s$pause
	pop r0

	sub2i r6 1
	jumpif nz loop

fin:	jump fin

get_text:
    getctr pc r6
    add2i r6 24
    return
.const "Antonin et Alban sont fiers de vous presenter..."
