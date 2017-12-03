    leti r0 0x10000
    setctr sp r0 ; initialisiation du pointeur de pile
    
    leti r0 0b100110001111111
    leti r1 56
    leti r2 56
    leti r3 72
    leti r4 72
    call fill
    ; tests : on va tracer une jolie étoile en utilisant plein de couleurs !
    leti r1 63
    leti r2 63
    ; branche 1:
    leti r3 0
    leti r4 0
    leti r0 0b11111
    call draw
    ; branche 2:
    leti r3 63
    leti r0 0b1111100000
    call draw
    ; branche 3:
    leti r3 159
    leti r0 0b111110000000000
    call draw
    ; branche 4:
    leti r4 63
    leti r0 0b000001111111111
    call draw
    ; branche 5
    leti r4 127
    leti r0 0b111110000011111
    call draw
    ; branche 6
    leti r3 63
    leti r0 0b111111111100000
    call draw
    ; branche 7
    leti r3 0
    leti r0 0b111111111111111
    call draw
    ; branche 8:
    leti r4 63
    leti r0 0b001110011100111
    call draw

    end: jump end
#main
clear_screen:
	push r1
	getctr a0 r1
	push r1 ; on met le premier élément de la pile en a0, en passant par r1.
	push r2

	let r2 r0
	shift left r0 16
	or2 r0 r2
	
	leti r2 0x2800 		;nb de pixels
	leti r1 0x10000
	setctr a0 r1
cls_loop:
	write a0 32 r0
	sub2i r2 1
	jumpif nz cls_loop
	pop r2
	pop r1 ; on place le premier élément de la pile en a0 en passant par r1.
	setctr a0 r1
	pop r1
	and2i r0 0xff
	return

plot:
    ; r0 contient la couleur du pixel que l'on va afficher
    ; (r1, r2) contiennent les coordonées du pixel à afficher.
    push r3

    ; r2 <- 127 - r2
    xor3i r2 r2 127

    ; r3 <- 160 * r2 + r1
    let r3 r2
    shift left r3 2
    add2 r3 r2
    shift left r3 5
    add2 r3 r1

    ; on multiplie r2 par 16 et on ajoute 0x10000
    shift left r3 4
    add2i r3 0x10000

    ; et on affiche le pixel d'adresse r2 :
    setctr a0 r3
    write a0 16 r0
    ; on remet r2 à sa valeur initiale
    xor3i r2 r2 127 ; on remet r2 à sa valeur initiale
    pop r3
    return
fill:
    push r1
    push r2
    push r4
    push r5
    push r6
    push r7
    let r7 r1
    ; de même que pour plot, on effectue les opérations :
    ; r2 <- 127 - r2
    ; r4 <- 127 - r4
    ; ainsi, puisque r2 ≤ r4 est supposé vrai à l'entrée de l'algorithme, on
    ; a désormais r2 ≥ r4.
    xor3i r2 r2 127
    xor3i r4 r4 127

    ; première « boucle for » : r2 varie par valeurs décroissantes jusqu'à r4.
fill_iter_raw:
    cmp r2 r4
    jumpif lt fill_iter_raw_exit

    ; r5 <- 160*r2
    let r5 r2
    shift left r5 2
    add2 r5 r2
    shift left r5 5

    ; deuxième « boucle for » : r1 varie par valeurs décroissantes jusqu'à r3.
fill_iter_col:
    cmp r1 r3
    jumpif gt fill_iter_col_exit

    ; r6 <- 16*(r5 + r1) + 0x10000
    let r6 r5
    add2 r6 r1
    shift left r6 4 
    add2i r6 0x10000
    setctr a0 r6
    write a0 16 r0
    add2i r1 1
    jump fill_iter_col

fill_iter_col_exit:
    let r1 r7
    sub2i r2 1
    jump fill_iter_raw

fill_iter_raw_exit:
    ; pop r5
    ; setctr a0 r5
    pop r7
    pop r6
    pop r5
    pop r4
    pop r2
    pop r1
    return

draw:
    ;; r1, r2, r3, r4 contiennent x1, y1, x2, y2
    ;; on cherche à tracer la droite allant de (x1, y1) à (x2, y2)
    ;; on suppose ici que x1 ≤ x2.
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7

    ; pour diminuer le nombre de cas à disjoindre, on fait en sorte que x1 ≤ x2
    ; si x1 > x2, on échange (x1, y1) avec (x2, y2)
    cmp r3 r1
    jumpif ge no_swap
    let r5 r1
    let r1 r3
    let r3 r5
    let r5 r2
    let r2 r4
    let r4 r5

no_swap:
    cmp r2 r4
    jumpif gt y1_gt_y2
    ; si y1 ≤ y2 :
    sub3 r5 r3 r1 ; r5 <- x2 - x1
    sub3 r6 r4 r2 ; r6 <- y2 - y1
    cmp r5 r6
    jumpif ge case1
    jump case2
y1_gt_y2:
    sub3 r5 r3 r1 ; r5 <- x2 - x1
    sub3 r6 r2 r4 ; r6 <- y1 - y2
    cmp r5 r6
    jumpif ge case3
    jump case4

case1: ; si y1 ≤ y2 et |y2 - y1| ≤ x2 - x1
    sub3 r5 r3 r1
    shift left r5 1 ; r5 contient 2 * dx
    sub3 r6 r1 r3   ; r6 contient -dx
    sub2 r4 r2      ; r4 contient 2 * dy
    shift left r4 1
draw_loop1:
    call plot
    ; on incrémente x, et on termine la boucle si x atteint sa valeur max.
    add2i r1 1 
    cmp r1 r3
    jumpif gt draw_endloop

    add2 r6 r4
    cmpi r6 0
    jumpif slt draw_loop1
    ;; si r6 >= r5
    add2i r2 1
    sub2 r6 r5
    jump draw_loop1

case2: ; si y1 ≤ y2 et x2 - x1 ≤ y2 - y1
    sub3 r5 r4 r2
    shift left r5 1 ; r5 contient 2 * dy
    sub3 r6 r2 r4   ; r6 contient -dy
    sub2 r3 r1      ; r4 contient 2 * dx
    shift left r3 1
draw_loop2:
    call plot
    ; on incrémente y, et on termine la boucle si y atteint sa valeur max.
    add2i r2 1 
    cmp r2 r4
    jumpif gt draw_endloop

    add2 r6 r3
    cmpi r6 0
    jumpif slt draw_loop2
    add2i r1 1
    sub2 r6 r5
    jump draw_loop2

case3:
    sub3 r5 r3 r1
    shift left r5 1 ; r5 contient 2 * dx
    sub3 r6 r1 r3   ; r6 contient -dx
    sub2 r4 r2      ; r4 contient 2 * dy
    shift left r4 1
draw_loop3: ; si y2 < y1 et |y2 - y1| ≤ x2 - x1
    call plot
    ; on incrémente x, et on termine la boucle si x atteint sa valeur max.
    add2i r1 1 
    cmp r1 r3
    jumpif gt draw_endloop

    sub2 r6 r4
    cmpi r6 0
    jumpif slt draw_loop3
    sub2i r2 1
    sub2 r6 r5
    jump draw_loop3

case4: ; si y1 > y2 et x2 - x1 ≤ |y2 - y1|
    sub3 r5 r4 r2
    shift left r5 1 ; r5 contient 2 * dy
    sub3 r6 r2 r4   ; r6 contient -dy
    sub2 r3 r1      ; r4 contient 2 * dx
    shift left r3 1
draw_loop4:
    call plot
    ; on décrémente y, et on termine la boucle si y atteint sa valeur min.
    sub2i r2 1 
    cmp r2 r4
    jumpif slt draw_endloop ; si y1 = 0, l'algo s'arrête quand y2 = -1. Il faut
                            ; alors effectuer une comparaison signée.

    sub2 r6 r3
    cmpi r6 0
    jumpif sgt draw_loop4
    add2i r1 1
    sub2 r6 r5
    jump draw_loop4

draw_endloop:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    return 
#endmain
