main:
	addi $t0, $zero, -5
	addi $t2, $zero, 2
	div $t0, $t2
	mfhi $t1
	li $v0, 1
	move $a0, $t1
	syscall
	jr $ra
