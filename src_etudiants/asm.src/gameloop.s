	.include x-wing-sprite.s
	.include attact.s
	.include pluie.s
	.include speech.s

	call speech.s$drawr2.s$mover2
	leti r0 0
	call pluie.s$graphic.s$clear_screen
	call speech.s$begin_screen

game_begin:
	leti r0 0
	call pluie.s$graphic.s$clear_screen
	leti r7 0 ; le nombre de blocs qui ont fini de passer
	leti r3 1 ; la ligne à laquelle est affichée le X-wing
	leti r4 1 ; la colonne à laquelle est affichée le X-wing

extern_forloop:

	push r7			;nombre de blocs deja passes
	leti r0 0x620c0 	;adresse d'un pseudo-aleatoire
	setctr a0 r0	
	readze a0 32 r0
	leti r1 9
	call pluie.s$div.s$div

	leti r1 3
	call pluie.s$div.s$div		; r0,r2 = coords bloc

	let r1 r0
	leti r0 0x140		;distance du bloc en int
	
intern_forloop: 		;the animation of one square
	push r0			;distance du bloc en int
	push r1 ; cx du bloc
	push r2 ; cy du bloc
	call pluie.s$fxrth16.s$int2fix
	
	;; dessin du cube
	push r0 ; distance du bloc en fix
	push r3	; cY du X-wing 
	push r4	; cX du Y-wing
	
	call pluie.s$calc_coords

	pop r4			; cX du Y-wing
	pop r3			; cY du X-wing
	pop r0			; distance du bloc en fix
	push r5			; coords des coins bas gauche du cube
	push r6			; longueur des deux carres du cube
	push r0			; distance du bloc en fix
	push r3			; cY du X-Wing
	push r4			; cX du Y-Wing
	push r0			; distance du bloc en fix
	
	leti r0 0xd0		; vert pale
	call pluie.s$draw_cube		

    ; on affiche le décor
	leti r0 0b11100000	; vert pale
	call pluie.s$draw_background

    ; on affiche le bloc
	pop r0			; distance du bloc en fix
	leti r1 0b11100000	; vert pale
	call pluie.s$hvlines

    ; on affiche le X-wing
	pop r4			; cX du X-Wing
	pop r3			; cY du X-Wing
	
   	call x-wing-sprite.s$react_key
	leti r0 0b111100000		; vert flash
	call x-wing-sprite.s$calc_xwing_coords
	
    push r3	 		; nvelles cY du X-Wing
    push r4			; nvelles cX du X-Wing

	call x-wing-sprite.s$x-wing.s$draw_xwing

	;; pause utilisateur
	leti r0 50
	call attact.s$pause
	
    ; on efface le cube
	pop r4			; cX du X-Wing
	pop r3			; cY du X-Wing
	pop r0			; distance du bloc en fix
	push r3			; cY du X-Wing
	push r4			; cX du X-Wing

	
	leti r1 0		; Noir
	call pluie.s$hvlines		; effacer les lignes

	    ; on efface le bloc
	pop r4			; cX du X-Wing
	pop r3			; cY du X-Wing
	pop r6			; longueur des carres du cube
	pop r5			; coords des coins bas gauche
	push r3			; cY du X-Wing
	push r4			; cX du X-Wing
	
	leti r0 0		; Noir
	call pluie.s$draw_cube		; efface le cube

    pop r4			; cX du X-wing
    pop r3			; cY du X-wing
	pop r2			; cx du cube
	pop r1			; cy du cube
	pop r0			; distance du bloc en INT
	pop r7			; nombre de blocs deja passes
	sub2i r0 8 ; le vaisseau avance d'une distance 8 + r7 à chaque fois
    sub2 r0 r7 ; ainsi, la vitesse augemente au fur et à mesure.
    push r7    ;nombre de blocs deja passes
	cmpi r0 -1
	jumpif sgt intern_forloop ;le bloc n'a pas atteint le vaissal


	pop r7			; le bloc est a la hauteur du vaissal
	add2i r7 1
    cmpi r7 30 ; on s'arrête au bout de 30 blocs
	jumpif ge you_won
    ; si (r1, r2) != (r3, r4), on rentre en collision avec le bloc et c'est
    ; la fin du jeu.
    cmp r1 r3
    jumpif neq you_lose
    cmp r2 r4
    jumpif neq you_lose
    jump extern_forloop
    
	;; si on a perdu

you_lose:
	leti r0 0
	call pluie.s$graphic.s$clear_screen
	leti r0 1000
	call speech.s$attact.s$pause
	call speech.s$aff_lose_text
yolo_loop:	
	leti r0 0x62051
	setctr a1 r0
	readze a1 1 r0
	cmpi r0 1
	jumpif eq end_game
	readze a1 1 r0
	cmpi r0 1
	jumpif eq game_begin
	jump yolo_loop
you_won:
	leti r0 0
	call pluie.s$graphic.s$clear_screen
	leti r0 1000
	call speech.s$attact.s$pause
	call speech.s$win_screen
end_game:
	leti r0 0
	call pluie.s$graphic.s$clear_screen
loop:	jump loop
