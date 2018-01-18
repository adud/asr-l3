	;; un petit test graphique 

	leti r7 0 ; le nombre de blocs qui ont fini de passer
    leti r3 1 ; la ligne à laquelle est affichée le X-wing
    leti r4 1 ; la colonne à laquelle est affichée le X-wing

extern_forloop:

	push r7			;nombre de blocs deja passes
	leti r0 0x620c0 	;adresse d'un pseudo-aleatoire
	setctr a0 r0	
	readze a0 32 r0
	leti r1 9
	call div.s$div

	leti r1 3
	call div.s$div		; r0,r2 = coords bloc

	let r1 r0
	leti r0 0x140		;distance du bloc en int
	
intern_forloop: 		;the animation of one square
	push r0			;distance du bloc en int
	push r1 ; cx du bloc
	push r2 ; cy du bloc
	call fxrth16.s$int2fix
	
	;; dessin du cube
	push r0 ; distance du bloc en fix
	push r3	; cY du X-wing 
	push r4	; cX du Y-wing
	
	call calc_coords

	pop r4			; cX du Y-wing
	pop r3			; cY du X-wing
	pop r0			; distance du bloc en fix
	push r5			; coords des coins bas gauche du cube
	push r6			; longueur des deux carres du cube
	push r0			; distance du bloc en fix
	push r3			; cY du X-Wing
	push r4			; cX du Y-Wing
	push r0			; distance du bloc en fix
	
	leti r0 0b11100000	; vert pale
	call draw_cube		

    ; on affiche le décor
	leti r0 0b11100000	; vert pale
	call draw_background

    ; on affiche le bloc
	pop r0			; distance du bloc en fix
	leti r1 0b11100000	; vert pale
	call hvlines

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
	call hvlines		; effacer les lignes

	    ; on efface le bloc
	pop r4			; cX du X-Wing
	pop r3			; cY du X-Wing
	pop r6			; longueur des carres du cube
	pop r5			; coords des coins bas gauche
	push r3			; cY du X-Wing
	push r4			; cX du X-Wing
	
	leti r0 0		; Noir
	call draw_cube		; efface le cube

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
	jumpif ge endloop
    ; si (r1, r2) != (r3, r4), on rentre en collision avec le bloc et c'est
    ; la fin du jeu.
    cmp r1 r3
    jumpif neq endloop
    cmp r2 r4
    jumpif neq endloop
    jump extern_forloop
    
endloop:    jump endloop

	
.main
.include fxrth16.s
.include attact.s
.include graphic.s
.include mult.s
.include div.s
.include x-wing-sprite.s
	
	;; coords_square_dist
	
	;; if r0 contains the distance of the block
	;; db, in fixed-point
	;; after coords_square_dist :
	;; r1 contains int b : the value of the two coords of
	;; bottom left corner of the bottom left square
	;; r2 contains int l : the length of a square
	;; see ggb file

	;; ds will be fixed as 73.0 until we have macros
	;; K as 42

	;; works fine until r0=0x6180000 then calculation overflow
coords_square_dist:
	push r7
	let r2 r0		;r2 is db
	add2i r0 0x490000	;79.0 = ds
	shift left r0 1 
	push r0			;2*(db+ds) on the stack
	
	leti r1 0x2a0000	;0x2a0000 means K as float
	let r0 r2
	call fxrth16.s$multfix
	pop r1			;2*(db+ds)
	let r0 r2
	call fxrth16.s$divfix
	push r2			;cdis on the stack
	leti r0 0x30000		;this 3.0
	let r1 r2
	call fxrth16.s$multfix	;r2 is b
	pop r1			;cdis
	push r2			;b on the stack
	leti r0 0x20000		;2.0
	call fxrth16.s$multfix
	leti r0 0x2a0000	;42.0 is K I *really* need macros
	sub2 r0 r2		;K - 2*cdis = l
	call fxrth16.s$fix2int
	let r1 r0
	pop r0			;b
	call fxrth16.s$fix2int
	pop r7
	return

	;; calc_coords : if r0 contains the distance between cube & screen
	;; r1 r2 its position on the screen

	;; after calc_coords :
	
	;; r5 contains the coordinates :
	;; dlf.x.e24 + dlb.x.e16 + dlf.y.e8 + dlb.y
	;; where dlf is down left front
	;; r6 contains the length of the squares :
	;; front_square_length.e8 + back_square_length
	
calc_coords:
	push r7
	push r2			;cy
	push r1			;cx
	push r0			;d
	call coords_square_dist	
	pop r4			;d
	push r0			;b
	push r1			;l
	leti r0 0x2a0000	;K float once again
	add2 r0 r4
	call coords_square_dist	;			         +----+
	pop r6		;l					 | cy |	
	pop r5		;b       reg :  b' l' . . . b l . stack: | cx |
	;; free space : as coordinates <= 256, one can concatenate
	;; four coords in the same register : ri = c3e24 + c2e16 + c1e8 + c0
	;; avoid lots of pop & push
	shift left r5 8
	add2 r5 r0
	shift left r6 8
	add2 r6 r1		;reg : . . . . . be8+b' le8+l' . stack idem

	let r4 r5
	let r1 r6
	pop r0			;cx
	call mult.s$mult
	add2 r5 r2
	shift left r5 16
	let r1 r6
	pop r0			;cy ;empty stack
	call mult.s$mult
	add2 r5 r2
	add2 r5 r4
	pop r7
	return

	
	;; if r5 contains the coordinates :
	;; dlf.x.e24 + dlb.x.e16 + dlf.y.e8 + dlb.y
	;; where dlf is down left front
	;; if r6 contains the length of the squares :
	;; front_square_length.e8 + back_square_length
	;;
	;; draw_cube connects the squares ((dlf.x,dlf.y),front_square_length)
	;; ((dlb.x,dlb.y),back_square_length) to form a prism

draw_cube:	
	push r7
	push r6
	add2i r5 0x11110101	;an offset used to center cubes
	add2 r6 r5		;dl ul (down-left up-left)
	call draw_3_vertices
	let r5 r6
	pop r6
	push r6
	shift left r6 16
	add2 r6 r5		;ul ur
	call draw_3_vertices
	let r5 r6
	pop r6
	push r6
	sub3 r6 r5 r6		;ur dr
	call draw_3_vertices
	let r5 r6
	pop r6
	shift left r6 16
	sub3 r6 r5 r6
	call draw_3_vertices

	pop r7

	return
	
	;; in draw_cube the 12 vertices are drawn by pack of 3
	;; Draws the lines with the colour in r0
	;; r5 & r6 are side squares of the cube
draw_3_vertices:
	push r7
	;; depth line
	and3i r1 r5 0xff000000
	shift right r1 24
	and3i r2 r5 0x0000ff00
	shift right r2 8
	and3i r3 r5 0x00ff0000
	shift right r3 16
	and3i r4 r5 0x000000ff
	call graphic.s$draw
	;; front line
	and3i r3 r6 0xff000000
	shift right r3 24
	and3i r4 r6 0x0000ff00
	shift right r4 8
	call graphic.s$draw
	;; back line
	and3i r1 r5 0x00ff0000
	shift right r1 16
	and3i r2 r5 0x000000ff
	and3i r3 r6 0x00ff0000
	shift right r3 16
	and3i r4 r6 0x000000ff
	call graphic.s$draw

	pop r7
	return

draw_background:
	push r7
	leti r1 0x11		;always an offset
	leti r2 0x1		;to center the picture on the screen
	add3i r3 r1 126 	;3*K
	let r4 r2
	call graphic.s$draw

	sub2i r3 126
	add2i r4 126
	call graphic.s$draw
	add2i r3 126
	add2i r1 126
	call graphic.s$draw
	sub2i r1 126
	
	call graphic.s$draw
	;add2i r2 42 		;42 is K
	;sub2i r4 42
	;call graphic.s$draw
	;add2i r2 42 		;42 is K
	;sub2i r4 42
	;call graphic.s$draw
	;add2i r2 42 		;42 is K
	;sub2i r4 42
    add2i r2 63
    sub2i r4 63
    call graphic.s$draw
    add2i r2 63
    sub2i r4 63
	call graphic.s$draw
	add2i r1 63
	sub2i r2 63
	;sub2i r3 42
	;call graphic.s$draw
	;sub2i r3 42
	;call graphic.s$draw
    sub2i r3 63
    call graphic.s$draw

	pop r7
	return
	;; implement moving horizontal & vertical lines
	;; if r0 contains a distance from screen
	;; r1 a colour
	;; draws lines on the walls & the ground at this distance

	;; with the colour r1
hvlines:
	push r7
	push r1
	call coords_square_dist
	let r2 r1
	shift left r1 1
	add3 r5 r1 r2 		;r5 contains 3*l
	let r1 r0
	pop r0
	add3i r2 r1 1
	add2i r1 17
	let r3 r1
	let r4 r2

	add2 r4 r5
	call graphic.s$draw
	add2 r3 r5
	add2 r1 r5
	call graphic.s$draw

	sub2 r3 r5
	sub2 r4 r5
	call graphic.s$draw

    ;add2 r2 r5
    ;add2 r4 r5
    ;call graphic.s$draw ; drawing the 4th line

	pop r7
	return

