	leti r0 100
	call fxrth16.s$int2fix
	call coords_square_dist

loop:	jump loop
	
.main
.include fxrth16.s
.include mult.s
	;; to avoid space loss (thx floflo)
	;; 32 bits is for 2 points :
	;; 8 bits per coordinate

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
