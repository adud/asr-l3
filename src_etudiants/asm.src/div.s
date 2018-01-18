	;;Division
	;; si r0=A, r1=B A,B < 2**30
	;; apres div: r2=A//B r0=A%B

	;; r3-6 conserves
	leti r0 10000		;stinit
	setctr sp r0
	
	leti r0 19886
	leti r1 212
	call div
end:	jump end

.main
div:	push r3
	leti r2 0
	let r3 r1
shiftl: ; on décale r3 vers la gauche jusqu'à que r3 soit plus grand que r0.
	shift left r3 1		
	jumpif c depassement
	cmp r0 r3
	jumpif ge shiftl
	jump mainloop
depassement:
	push r5		;avoir MSB dans r4 (indep arch)
	push r4		;j'ai besoin de Macros		
	leti r4 -1
	leti r5 -1
	shift right r4 1
	xor3 r4 r5 r4
	shift right r3 1
	add2 r3 r4
	pop r4
	pop r5
	
	sub2 r0 r3
	add2i r2 1
	
mainloop:
	shift right r3 1 ; par la suite, on décale r3 vers la droite a chq tour
	shift left r2 1	 ;inv : r0+r1*r2
	cmp r0 r3	 ;inv : r0 < r3
	jumpif lt cond	 ;nb bits lus <93
	sub2 r0 r3
	add2i r2 1
cond: ; On s'arrête quand r3 vaut moins de r1.
      ; Le bloc cond vérifie cette condition.
	cmp r1 r3
	jumpif neq mainloop

	pop r3
	return
.endmain
