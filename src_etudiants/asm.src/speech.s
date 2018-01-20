	.include aff.s
	.include graphic.s
	.include attact.s
	.include drawr2.s

	call begin_screen
	
loop:	jump loop
	
begin_screen:	
	push r7
	leti r1 10
	leti r2 92
	call drawr2.s$drawr2

	call get_starttext
	setctr a1 r6
	leti r0 0xf0
	leti r1 0x10000
	setctr a0 r1
	call aff.s$wrtxt

	call wait_for_key
	leti r0 0
	call graphic.s$clear_screen

	leti r4 15
	call get_speech
	setctr a1 r6
text_mainloop:
	leti r0 0xf0
	leti r3 0x10000
	setctr a0 r3
	call aff.s$wrtxt
	call wait_for_key
	leti r0 0
	call graphic.s$clear_screen
	sub2i r4 1
	jumpif nz text_mainloop

	pop r7
	return
	
wait_for_key:
	push r7
	
wfk_loop:
	leti r2 0
	leti r1 0x62000
	setctr a0 r1
	readze a0 32 r1
	add2 r2 r1
	readze a0 32 r1
	add2 r2 r1
	readze a0 32 r1
	add2 r2 r1
	readze a0 32 r1
	add2 r2 r1
	jumpif z wfk_loop
	leti r1 0x62000
	leti r2 0
	write a0 32 r0
	write a0 32 r0
	write a0 32 r0
	write a0 32 r0
	leti r0 150
	call attact.s$pause

	pop r7
	return

get_speech:
    getctr pc r6
    add2i r6 24
    return
	
speech:
	.const "Red 5,\n\rwe've got a problem\n\r..."
	.const "Your stabilisators\n\rare dead"
	.const "Leave the trench !\n\rNow !"
	.const "No !\n\rI'm the last one\n\rthat can blow it up !"
	.const "R2,\n\rcan you fix this ?"
	.const "1001110101101001011101110101011101111101"
	.const "Segfault ? How ?"
	.const "Ok Red 5,\n\rwe have a solution"
	.const "We uploaded the map of the trench\n\ron your X-Wing"
	.const "You will see green\n\rcubes on your screen..."
	.const "You'll have to pass through it,\n\rand normally you \n\rwon't get crashed\n\ragainst a wall"
	.const "Copy that !\n\rI'm gonna destroy\n\rthis !"
	.const " . \n\rAnd Luke ?\n\r..."
	.const "Yes, Leia ?"
	.const "May the Force be\n\rwith you"

get_starttext:
    getctr pc r6
    add2i r6 24
    return
	
starttext:
	.const "Press any key\n\rto start"
.endmain
