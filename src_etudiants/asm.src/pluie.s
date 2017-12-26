	leti r0 500
forloop:
	push r0
	call fxrth16.s$int2fix
	call coords_square_dist
	let r5 r1
	let r1 r0
	let r2 r0
	let r3 r0
	let r4 r0
	add2 r3 r5
	add2 r4 r5
	leti r0 -1
	call graphic.s$fill
	leti r0 20
	call pause
	leti r0 0
	call graphic.s$fill
	pop r0
	sub2i r0 1
	jumpif nz forloop
	
loop:	jump loop
	
.main
.include fxrth16.s
.include mult.s
.include graphic.s 

	;; coords_square_dist
	
	;; if r0 contains the distance of the block
	;; db, in fixed-point
	;; after coords_square_dist :
	;; r1 contains int b : the value of the two coords of
	;; bottom left corner of the bottom left square
	;; r2 contains int a-b : the length of a square
	;; see ggb file

	;; ds will be fixed as 73.0 until we have macros
	;; K as 42
coords_square_dist:
	push r7
	let r2 r0		;r2 is db
	add2i r0 0x490000
	shift left r0 1 
	push r0			;2*(db+ds) on the stack
	
	leti r0 42		;42 means K
	call fxrth16.s$int2fix
	let r1 r0
	let r0 r2
	call fxrth16.s$multfix
	pop r1			;2*(db+ds)
	let r0 r2
	call fxrth16.s$divfix
	push r2			;cdis on the stack
	leti r0 3
	call fxrth16.s$int2fix
	let r1 r2
	call fxrth16.s$multfix	;r2 is b
	pop r1			;cdis
	push r2			;b on the stack
	leti r0 2		
	call fxrth16.s$int2fix
	call fxrth16.s$multfix
	leti r0 42		;42 is K I *really* need macros
	call fxrth16.s$int2fix
	sub2 r0 r2
	call fxrth16.s$fix2int
	let r1 r0
	pop r0 			;b
	call fxrth16.s$fix2int
	pop r7
	return

.endmain

pause:	push r1
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
