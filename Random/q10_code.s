main:
	#to get the integer enter
	li $v0, 5
	syscall
	
	#to make the integer mask with the 1111 1111 number 
	addi $t0, $zero, 0x00FF
	
	and $t1, $v0, $t0 #byte one
	sll $t3, $t1, 24 #shifting the masked value obtained 
	sll $t0, $t0, 8 #shifting the 1111 1111 value
	
	and $t4, $v0, $t0 #masking the original value to 1111 1111 0000 0000
	sll $t4, $t4, 8 # shifting the 2 byte value in the flipped value
	or $t3, $t3, $t4
	sll $t0, $t0, 8 #shiftingthe 1111 1111

	and $t5, $v0, $t0
	sll $t5, $t5, 8
	or $t3, $t3, $t5
	sll $t0, $t0, 8

	and $t6, $v0, $t0
	sll $t6, $t6, 0
	
	or $t3, $t3, $t6
	
	srl $a0, $a0, 1
	or $a0, $a0, $t3
	
	li $v0, 1
	syscall
	
	li $v0,10
	syscall
