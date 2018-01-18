; On regarde si une touche du clavier a été préssée.
; Si oui, on efface le X-wing et on change ses coordonnées.
	;; si r3 r4 contiennent les coordonnees cx et cy
	;; du X-Wing, les met a jour en fonction de
	;; la touche pressee
	;; redessine le X-Wing SSI il a bouge
	;; registres 5-6 conserves

.main
.include x-wing.s
	;; si r3 & r4 sont les coords du X-Wing :
	;; en sortie : r1 & r2 sont les coords de son image
	;; r056 conserves
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
break:
    pop r7
    return

move_right:
    call cancel_last_read_bit
    cmpi r3 2
    jumpif eq break ; si le X-wing se trouve déjà à droite, on ne le bouge pas
    leti r0 0
    call calc_xwing_coords
    push r3
    push r4
    call x-wing.s$draw_xwing ; on efface le X-wing
    pop r4
    pop r3
    add2i r3 1               ; et on change sa coordonée
    jump break
move_left:
    call cancel_last_read_bit
    cmpi r3 0
    jumpif eq break
    leti r0 0
    call calc_xwing_coords
    push r3
    push r4
    call x-wing.s$draw_xwing
    pop r4
    pop r3
    sub2i r3 1
    jump break
move_down:
    call cancel_last_read_bit
    cmpi r4 0
    jumpif eq break
    leti r0 0
    call calc_xwing_coords
    push r3
    push r4
    call x-wing.s$draw_xwing
    pop r4
    pop r3
    sub2i r4 1
    jump break
move_up:
    call cancel_last_read_bit
    cmpi r4 2
    jumpif eq break
    leti r0 0
    call calc_xwing_coords
    push r3
    push r4
    call x-wing.s$draw_xwing
    pop r4
    pop r3
    add2i r4 1
    jump break

; effacement du dernier bit lu avec le compteur a1. Cela permet qu'une fois
; que l'on a vu qu'une touche du clavier avait été préssée, on met le bit
; correspondant un mémoire à 0 de façon à ne pas relire la même entrée.
	;; conservation des registres r1-6
	;; et de tous les pointeurs
cancel_last_read_bit:
    getctr a1 r0
    sub2i r0 1
    setctr a1 r0
    leti r0 0
    write a1 1 r0
    return

.endmain
