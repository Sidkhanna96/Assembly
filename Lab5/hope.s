.text
getControlFlow:

	la $t0, 0($a0)
	li $t1, 0	# $t1 has number of instructions
	
Loop:
	addi $t1, $t1, 1
	addi $t2, $t0, 4
	bne $t2, 0xffffffff, Loop 
	
	sw $a0, $t1
	li $v0, 9
	syscall
	
	la $t3, 0($v0)
	
	beq $t2, 1, Continue	#bgez, bgezal
	beq $t2, 4, Continue	#
	beq $t2, 5, Continue	#Check if OPcode is equal to 5
	beq $t2, 6, Continue	#check if OPcode is equal to 6
	beq $t2, 7, Continue	
	
Exit:
	jr $ra
