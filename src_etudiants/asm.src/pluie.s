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
	;; r1,r2 contain the values a,b in integer
	;; see ggb file

	;; ds will be fixed as 73.0 until we have macros
	;; K as 42
coords_square_dist:
	push r7
	let r2 r0		;r2 is db
	add2i r0 0x490000
	shift left r0 1 
	push r0		;2*(db+ds) stored on the stack

	leti r0 42
	call fxrth16.s$int2fix
	let r1 r0
	let r0 r2
	call fxrth16.s$multfix
	pop r1
	let r0 r2
	call fxrth16.s$divfix	;r2 is cdis
	pop r7
	return
.endmain
