	leti r0 0x0fff
	leti r1 0x1001
	call mult16
end:
	jump end
mult16:
	leti r4 0 ; si r1 dépasse de 16 bits, les bits restants sont stockés en r4
	leti r2 0 ; r2 contient les bits de poids fort du résultat
	leti r3 0 ; r3 contient les bits de poids faible du résultat
mainloop: 
	shift right r0 1
	jumpif nc skip
	add2 r3 r1
	add2 r2 r4
	and3i r5 r3 0x10000 ; Si r3 tient sur 17 bits, on retire ce qui
	jumpif z skip       ; dépasse des 16 bits de r3 et on incrément r2
	and2i r3 0xffff
	add2i r2 1
skip:
	shift left r1 1
	shift left r4 1
	and3i r5 r1 0x10000
	jumpif z cond   ; si r1 tient sur 17 bits, on retire ce qui dépasse et on 
	and2i r1 0xffff ; incrémente r4.
	add2i r4 1
cond:
	cmpi r0 0
	jumpif nz mainloop
	return
