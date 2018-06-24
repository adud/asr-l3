
	call begin_screen
	
loop:	jump loop
.main	
	.include aff.s
	.include graphic.s
	.include attact.s
	.include drawr2.s

begin_screen:	
	push r7
	leti r1 80
	leti r2 92
	call drawr2.s$drawr2

	call get_starttext
	setctr a1 r6
	leti r0 0xffff
	leti r1 0x10000
	setctr a0 r1
	call aff.s$wrtxt

	call attact.s$wait_for_key
	leti r0 0
	call graphic.s$clear_screen

	
	call get_speech
	setctr a1 r6
	leti r4 15
	leti r0 0xffff
	call write_speech
	pop r7
	return

	;; if a1 points on $(r4) strings
	;; then write_speech will print
	;; theses strings one after one
	;; waiting a key to be pressed
	;; between two strings
	;; with the colour r0
write_speech:
	push r7
write_speech_mainloop:
	push r4
	push r0
	leti r3 0x10000
	setctr a0 r3
	call aff.s$wrtxt
	call attact.s$wait_for_key
	leti r0 0
	call graphic.s$clear_screen
	pop r0
	pop r4
	sub2i r4 1
	jumpif nz write_speech_mainloop
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

aff_lose_text:
	push r7
	call get_lose_text
	setctr a1 r6
	leti r0 0x3e0
	leti r1 0x10000
	setctr a0 r1
	call aff.s$wrtxt
	
	pop r7
	return
	
get_lose_text:
	getctr pc r6
	add2i r6 24
	return

lose_text:
	.const "Try again ?\n\r\n\r....^^....\n\r....vv....\n\r\n\r...Quit..."

get_win_text:
 	getctr pc r6
 	add2i r6 24
 	return
win_text:
 	.const "U t F L\n\rs h o u\n\re e r k\n\r. . c e\n\r. . e ."
 	.const "..?"
 	.const "L g\n\re o\n\rt"
 	.const "Red 5, you turned\n\roff your computer,\n\rwhat's wrong ?"
 	.const "Nothing, I'm all\n\rright"
	.const "..."
	.const " Congratulations !"
win_screen:
 	push r7
 	call get_win_text
 	setctr a1 r6
 	leti r4 7
 	leti r0 0x3e0
 	call write_speech
 	pop r7
 	return
	
 .endmain
