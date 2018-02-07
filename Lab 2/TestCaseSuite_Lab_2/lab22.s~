disassembleBranch:

	lw $t0, 0($a0) 
	
	#total 32 bits
	addi $t1, $zero, 0xff000000 #masking number
	add $a0, $t1, $zero
	li $v0, 1
	syscall
	
	#Mask to get OPcode
	#and $t2, $t0, $t1
	#srl $t2, $t2, 26
	
	#Mask to get Reg S
	#srl $t1, $t1, 4
	#and $t3, $t0, $t1
	#sll $t3, $t3, 6
	#srl $t3, $t3, 27
	
	#Mask to get Reg T
	#srl $t1, $t1, 4
	#and $t4, $t0, $t1
	#sll $t4, $t4, 11
	#srl $t4, $t4, 27
	
	#Mask to get Offset
	#addi $t1, $zero, 0xffff
	#and $t5, $t0, $t1
	
	#checking for beq and stuff
	#beq $t2, 1, CheckRegT
	#beq $t2, 4, beq
	#beq $t2, 5, bne
	#beq $t2, 6, blez
	#beq $t2, 7, bgtz
	
	#CheckRegT:
	#beq $t4,1,bgez
	#beq $t4,17,bgezal
	#beq $t4,0,bltz
	#beq $t4,16,bltzal
	
	#RegS Value add $ and then decimal value and (,)
	
	#RegT Value add $ and then decimal value and (,)
	
	#
	
	
	jr $ra
	
	#add $a0, $t1, $zero
	#li $v0, 1
	#syscall
