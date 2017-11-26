	leti r0 0b1110011100111000
	call graphic.s$clear_screen

	leti r0 0x62080
	setctr a1 r0

	leti r0 0x10000
	setctr a0 r0
	
	call aff.s$wrtxt
	
	leti r5 20
	leti r0 -1

	leti r1 3
	let r2 r1
	leti r3 60
	leti r4 64
	
flp:	call graphic.s$draw
	add2i r1 8
	add2i r3 2
	shift left r0 1
	sub2i r5 1
	jumpif nz flp

loop:	leti r0 0
	
	leti r1 60
	leti r2 68
	leti r3 98
	leti r4 78

	call graphic.s$fill

	call attact
	
	leti r0 0b100110001111111 ; just to have a pinkier pink.
	leti r1 67
	leti r2 69
	leti r3 70
	call aff.s$putchar

	add2i r1 8
	leti r3 51
	call aff.s$putchar

	add2i r1 8
	leti r3 68
	call aff.s$putchar

	call attact

	call loop
	
attact: leti r5 0x200000
lpi:	sub2i r5 1
	jumpif nz lpi
	return
	
#include graphic.s
	
#include aff.s
