	leti r0 19886
	leti r1 212
	call div
end:
	jump end
div:
	leti r2 0
	let r3 r1
shiftl: ; on décale r3 vers la gauche jusqu'à que r3 soit plus grand que r0.
	shift left r3 1
	cmp r0 r3
	jumpif ge shiftl
mainloop:
	shift right r3 1 ; par la suite, on décale r3 vers la gauche à chaque tour
	shift left r2 1
	cmp r0 r3
	jumpif lt cond
	sub2 r0 r3
	add2i r2 1
cond: ; On s'arrête quand r3 est revenu à la valeur de r1.
      ; Le bloc cond vérifie si cette condition est vérifiée.
	cmp r1 r3
	jumpif neq mainloop
	return
