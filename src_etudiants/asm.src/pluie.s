	;; un petit test graphique

	leti r7 0 ; le nombre de blocs qui ont fini de passer
    leti r3 1 ; la ligne à laquelle est affichée le X-wing
    leti r4 0 ; la colonne à laquelle est affichée le X-wing

extern_forloop:

	push r7
	leti r0 0x620c0 	;adress of the pseudo-random generator
	setctr a0 r0		;ca faisait longtemps...
	readze a0 32 r0
	leti r1 9
	call div.s$div

	leti r1 3
	call div.s$div

	let r1 r0
	leti r0 0x100
intern_forloop: 		;the animation of one square
	push r0
	push r1 ; cx du bloc
	push r2 ; cy du bloc
	call fxrth16.s$int2fix
	
    ; on affiche un cube :
	push r0 ; distance du bloc en fix
    push r3
    push r4
	call calc_coords
    pop r4
    pop r3
    pop r0
	push r5
	push r6
    push r0
    push r3
    push r4
    push r0
	leti r0 0b11100000
	call draw_cube

    ; on affiche le décor
	leti r0 0b11100000
	call draw_background

    ; on affiche le bloc
	pop r0			;distance du bloc en fix
	leti r1 0b11100000
	call hvlines

    ; on affiche le X-wing
    pop r4
    pop r3
    leti r0 0b111100000
    call calc_xwing_coords
    push r3
    push r4
    call x-wing.s$draw_xwing

	leti r0 60
	call attact.s$pause
	
    pop r4
    pop r3
    call react_key

    ; on efface le cube
	pop r0			;distance du bloc en fix
    push r3
    push r4
	leti r1 0
	call hvlines

    ; on efface le bloc
    pop r4
    pop r3
	pop r6
	pop r5
    push r3
    push r4
	leti r0 0
	call draw_cube

    pop r4
    pop r3
	pop r2
	pop r1
	pop r0			;distance du bloc en INT
    pop r7
	sub2i r0 8 ; le vaisseau avance d'une distance 8 + r7 à chaque fois
    sub2 r0 r7 ; ainsi, la vitesse augemente au fur et à mesure.
    push r7
	cmpi r0 -1
	jumpif sgt intern_forloop

	pop r7
	add2i r7 1
    cmpi r7 31
	jumpif lt extern_forloop
		
loop:	jump loop

	
.main
.include fxrth16.s
.include attact.s
.include graphic.s
.include mult.s
.include div.s
.include x-wing.s
	
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

calc_xwing_coords:
    ; r1 <- 43 * r3 + 17
    let r1 r3
    shift left r1 2
    add2 r1 r3
    shift left r1 2
    add2 r1 r3
    shift left r1 1
    add2 r1 r3
    add2i r1 17
    ; r2 <- 43 * r4 + 27
    let r2 r4
    shift left r2 2
    add2 r2 r4
    shift left r2 2
    add2 r2 r4
    shift left r2 1
    add2 r2 r4
    add2i r2 27
    return

; On regarde si une touche du clavier a été préssée.
; Si oui, on efface le X-wing et on change ses coordonnées.
react_key: 
    push r7
    ; on court-circuite tout :
    leti r0 0x6204f ; l'adresse du bit activé si on presse la touche droite
    setctr a1 r0
    readze a1 1 r0
    cmpi r0 1
    jumpif eq move_right
    readze a1 1 r0
    cmpi r0 1
    jumpif eq move_left
    readze a1 1 r0
    cmpi r0 1
    jumpif eq move_down
    readze a1 1 r0
    cmpi r0 1
    jumpif eq move_up
    ; aucune touche directionnelle n'a été préssée :
return:
    pop r7
    return

move_right:
    cmpi r3 2
    jumpif eq return ; si le X-wing se trouve déjà à droite, on ne le bouge pas
    leti r0 0
    push r3
    push r4
    call x-wing.s$draw_xwing ; on efface le X-wing
    pop r4
    pop r3
    add2i r3 1               ; et on change sa coordonée
    jump return
move_left:
    cmpi r3 0
    jumpif eq return
    leti r0 0
    push r3
    push r4
    call x-wing.s$draw_xwing
    pop r4
    pop r3
    sub2i r3 1
    jump return
move_down:
    jump return
move_up:
    jump return
.endmain
