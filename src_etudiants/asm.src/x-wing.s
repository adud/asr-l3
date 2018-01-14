    leti r0 0x100
    leti r1 50
    leti r2 50
    call draw_xwing
endloop:
    jump endloop

get_xwing_ptr:
    getctr pc r6
    add2i r6 24
    return
.const 520 0xC004010018C00A028018FE0AFA83F807FF8FFF00003F07E0000007FF00000001FC0000003FFFE00007FFFFFF00FE0AFA83F8C00A028018C004010018

; expérimentation :
; (r1, r2) sont les coordonnées de la case en bas à gauche du X-wing
; r0 est la couleur du X-wing.
draw_xwing:
    push r7
    call get_xwing_ptr
    setctr a1 r6
    ; l'image est composée de 13 lignes. r1 varie de r1+12 à r1.

    ; r3 <- 0x10000 + (16 * (160 * (127 - r2) + r1))
    ; r3 pointe vers la case de l'écran associée au pixel (r1, r2)
    xor3i r2 r2 127
    let r3 r2
    shift left r3 2
    add2 r3 r2
    shift left r3 5
    add2 r3 r1
    shift left r3 4
    add2i r3 0x10000

    leti r6 13
forloop:
    ; une ligne est composée de 40 bits.
    ; on lit 32 bits en r4, 8 en r5, on affiche les 8 bits de r5 puis les 32
    ; bits de r4. À chaque fois, on commence par les bits de poids faible.
    readze a1 32 r4
    readze a1 8 r5
    let r7 r3

whileloop1:
    shift right r5 1
    jumpif nc dont_plot1
    setctr a0 r3
    write a0 16 r0
dont_plot1:
    add2i r3 16 ; on passe au pixel suivant
    cmpi r5 0
    jumpif neq whileloop1

    add3i r3 r7 128 ; après avoir affiché jusqu'à 8 pixel, on incrément r3 de
                    ; 8 * 16.
whileloop2:
    shift right r4 1
    jumpif nc dont_plot2
    setctr a0 r3
    write a0 16 r0
dont_plot2:
    add2i r3 16
    cmpi r4 0
    jumpif neq whileloop2

    ; on passe à la ligne suivante, on doit ajouter à la valeur de r3 de début
    ; de boucle 160*16 = 2560
    add3i r3 r7 2560
    sub2i r6 1
    cmpi r6 0
    jumpif neq forloop

    xor3i r2 r2 127 ; on remet r2 à sa valeur initiale.
    pop r7
    return
