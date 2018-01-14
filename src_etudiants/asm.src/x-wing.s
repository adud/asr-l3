    leti r
    leti r1 50
    leti r2 50
    call draw_xwing
endloop:
    jump endloop

.include graphic.s

get_xwing_ptr:
    getctr pc r6
    add2i r6 24
    return
.const 520 0xC004010018C00A028018FE0AFA83F807FF8FFF00003F07E0000007FF00000001FC0000003FFFE00007FFFFFF00FE0AFA83F8C00A028018C004010018

; expérimentation :
; (r1, r2) sont les coordonnées de la case en bas à gauche du X-wing
; r0 est la couleur
draw_xwing:
    push r7
    call get_xwing_ptr
    setctr a1 r6
    let r3 r1
    ; l'image est composée de 13 lignes. r1 varie de r1+12 à r1.
    sub3i r6 r2 1
    add2i r2 12

forloop:
    ; une ligne est composée de 40 bits.
    ; on lit 32 bits en r4, 8 en r5, on affiche les 8 bits de r5 puis les 32
    ; bits de r4. À chaque fois, on commence par les bits de poids faible.
    readze a1 32 r4
    readze a1 8 r5

    let r1 r3
whileloop1:
    shift right r5 1
    jumpif nc dont_plot1
    call graphic.s$plot
dont_plot1:
    add2i r1 1
    cmpi r5 0
    jumpif neq whileloop1

    add3i r1 r3 8
whileloop2:
    shift right r4 1
    jumpif nc dont_plot2
    call graphic.s$plot
dont_plot2:
    add2i r1 1
    cmpi r4 0
    jumpif neq whileloop2

    sub2i r2 1
    cmp r2 r6
    jumpif neq forloop
    pop r7
    return
