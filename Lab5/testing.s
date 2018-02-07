odd_series:
	addi $t0, $0, 0
	addi $v0, $0, 0
	blez $a0, DONE

LOOP:
	andi $t2, $t0, 0x1
	bne $t2, $0, ODD
	add $v0, $v0, $t0
	j REINIT

ODD:
	add $v0, $v0, 1

REINIT:
	add $t0, $t0, 1
	slt $t4, $t0, $a0
	bne $t4, $0, LOOP
	#blt $t0, $a0, LOOP

DONE:
	jr $ra
