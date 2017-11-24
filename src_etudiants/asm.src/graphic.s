    leti r0 0x10000
    setctr sp r0 ; initialisiation du pointeur de pile
    leti r1 10
    leti r2 10
    leti r3 90
    leti r4 50
    leti r0 0b111110000000000
    call fill
    leti r0 0b11111
    leti r2 50
    leti r4 10
    call draw
    end: jump end
#main
clear_screen:
    push r1
    getctr a0 r1
    push r1 ; on met le premier élément de la pile en a0, en passant par r1.
    leti r1 0x10000
cls_loop:
    setctr a0 r1
    write a0 16 r0
    add2i r1 16
    cmpi r1 0x60000
    jumpif lt cls_loop
    pop r1 ; on place le premier élément de la pile en a0 en passant par r1.
    setctr a0 r1
    pop r1
    return
plot:
    ; r0 contient la couleur du pixel que l'on va afficher
    ; need some comment about r1
    ; need some comment about r2
    push r1
    push r2
    push r3
    getctr a0 r3
    push r3
    ; need some comment about this operation
    xor3i r2 r2 127

    ; on multiplie r? par 160 et on l'ajoute à r?
    let r3 r2
    shift left r2 2
    add2 r2 r3
    shift left r2 5
    add2 r1 r2

    ; on multiplie r? par 16 et on ajoute 0x10000
    shift left r1 4
    add2i r1 0x10000

    ; et on affiche le pixel d'adresse r? :
    setctr a0 r1
    write a0 16 r0
    pop r3
    setctr a0 r3
    pop r3
    pop r2
    pop r1
    return
fill:
    push r1
    push r2
    push r4
    push r5
    push r6
    push r7
    getctr a0 r5
    push r5
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
    pop r5
    setctr a0 r5
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
    ;; on suppose ici que y1 ≤ y2 et que |y2 - y1| ≤ x2 - x1
    push r1
    push r2
    push r4
    push r5
    push r6
    push r7

    cmp r2 r4
    jumpif gt some_label
    sub3 r5 r3 r1 ; r5 <- x2 - x1
    sub3 r6 r4 r2 ; r6 <- y2 - y1
    cmp r5 r6
    jumpif ge case1
    jump case2
some_label: ; need to find an explicit name...
    sub3 r5 r3 r1 ; r5 <- x2 - x1
    sub3 r6 r2 r4 ; r6 <- y1 - y2
    cmp r5 r6
    jumpif ge case3
    jump case4

case1:
    sub3 r5 r3 r1
    shift left r5 1 ; r5 contient 2 * dx
    sub3 r6 r1 r3   ; r6 contient -dx
    sub2 r4 r2      ; r4 contient 2 * dy
    shift left r4 1
draw_loop1: ; si y1 ≤ y2 et |y2 - y1| ≤ x2 - x1
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

case2:
case3:
    sub3 r5 r3 r1
    shift left r5 1 ; r5 contient 2 * dx
    sub3 r6 r1 r3   ; r6 contient -dx
    sub3 r4 r2 r4   ; r4 contient 2 * |dy|
    shift left r4 1
draw_loop3: ; si y2 < y1 et |y2 - y1| ≤ x2 - x1
    call plot
    ; on incrémente x, et on termine la boucle si x atteint sa valeur max.
    add2i r1 1 
    cmp r1 r3
    jumpif gt draw_endloop

    add2 r6 r4
    cmpi r6 0
    jumpif slt draw_loop3
    sub2i r2 1
    sub2 r6 r5
    jump draw_loop3

case4:
draw_endloop:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r2
    pop r1
    return 
#endmain
