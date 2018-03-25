	;; attente active (c'est le mal (aka Fenêtre))
	;; fait une pause de n ms, r0=n
pause:	
	push r1
	push r2
	push r3
	push r4			;sauvegarde a1
	getctr a1 r4
	leti r3 0x62080
	setctr a1 r3
	readze a1 64 r1		;r1 := debut tps pause
	setctr a1 r3

lpi:
	readze a1 64 r2
	setctr a1 r3
	sub2 r2 r1
	cmp r2 r0
	jumpif slt lpi
	setctr a1 r4
	pop r4
	pop r3
	pop r2
	pop r1
	return


	;; wait_for_key
	;; wait for a key to be pressed
	;; r3-6 unchanged

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
	write a0 32 r2
	write a0 32 r2
	write a0 32 r2
	write a0 32 r2
	leti r0 150
	call pause

	pop r7
	return
