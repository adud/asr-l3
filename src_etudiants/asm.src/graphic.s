    leti r0 0x10000
    setctr sp r0 ; initialisiation du pointeur de pile
    leti r0 0b11111
    leti r1 0
    leti r2 0
    leti r3 80
    leti r4 40
    call plot
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
    ; r1 contient la ligne (0 en haut, 128 en bas) du pixel
    ; r2 contient la colonne (0 à gauche, 159 à droite) du pixel
    push r1
    push r2
    push r3
    getctr a0 r3
    push r3
    ; Les lignes sont "inversées" par rapport à ce que fait la SDL. Ainsi,
    ; on commence par effectuer r1 <- 127 - r1
    xor3i r1 r1 127

    ; on multiplie r1 par 160 et on l'ajoute à r2
    let r3 r1
    shift left r1 2
    add2 r1 r3
    shift left r1 5
    add2 r2 r1

    ; on multiplie r2 par 16 et on ajoute 0x10000
    shift left r2 4
    add2i r2 0x10000

    ; et on affiche le pixel d'adresse r2 :
    setctr a0 r2
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
    push r3
    push r5
    push r6
    push r7
    getctr a0 r5
    push r5
    let r7 r2
    ; de même que pour plot, on effectue les opérations :
    ; r1 <- 127 - r1
    ; r3 <- 127 - r3
    ; ainsi, puisque r1 ≤ r3 est supposé vrai à l'entrée de l'algorithme, on
    ; a désormais r1 ≥ r3.
    xor3i r1 r1 127
    xor3i r3 r3 127

    ; première « boucle for » : r1 varie par valeurs décroissantes jusqu'à r3.
fill_iter_raw:
    cmp r1 r3
    jumpif lt fill_iter_raw_exit

    ; r5 <- 160*r1
    let r5 r1
    shift left r5 2
    add2 r5 r1
    shift left r5 5

    ; deuxième « boucle for » : r2 varie par valeurs décroissantes jusqu'à r4.
fill_iter_col:
    cmp r2 r4
    jumpif gt fill_iter_col_exit

    ; r6 <- 16*(r5 + r2) + 0x10000
    let r6 r5
    add2 r6 r2
    shift left r6 4 
    add2i r6 0x10000
    setctr a0 r6
    write a0 16 r0
    add2i r2 1
    jump fill_iter_col

fill_iter_col_exit:
    let r2 r7
    sub2i r1 1
    jump fill_iter_raw

fill_iter_raw_exit:
    pop r5
    setctr a0 r5
    pop r7
    pop r6
    pop r5
    pop r3
    pop r2
    pop r1
    return
draw:
    ;; r1, r2, r3, r4 contiennent x1, y1, x2, y2
    ;; on cherche à tracer la droite allant de (x1, y1) à (x2, y2)
    ;; on suppose ici que x1 ≤ x2, y1 ≤ y2 et que y2 - y1 ≤ x2 - x1
    push r1
    push r2
    push r4
    push r5
    push r6
    push r7

    sub3 r5 r3 r1 ; r5 contient dx = x2 - x1
    sub2 r4 r2
    shift left r4 1 ; r4 contient dy = 2 * (y2 - y1)
    leti r6 0
draw_loop:
    call plot
    ; on incrémente x, et on termine la boucle si x atteint sa valeur max.
    add2i r1 1 
    cmp r1 r3
    jumpif gt draw_endloop

    add2 r6 r4
    cmp r6 r3
    jumpif lt draw_loop
    ;; si r6 >= r3, 
    add2i r2 1
    sub2 r6 r3
    sub2 r6 r3
    jump draw_loop
draw_endloop:
    pop r7
    pop r6
    pop r5
    pop r4
    pop r2
    pop r1
    return 
#endmain
