main:

	li $v0, 5 #load immediate user inputed integer
	syscall

	move $t0, $v0 # move user integer v0 into register t0

	andi $t1, $t0, 0x000000FF # mask 0th byte and store in register $t1
	andi $t2, $t0, 0x0000FF00 # mask 1st byte and store in register $t2
	srl $t3, $t0, 16 # shift right 2nd and 3rd bytes by 16 bits, will occupy positions of original 0th and 1st byte resepectively
	andi $t4, $t3, 0x000000FF # mask 2nd byte (technically in 0th byte spot) and store in register $t4
	andi $t5, $t3, 0x0000FF00 # mask 3rd byte (technically in 1ST byte spot) and store in register $t5

	srl $t6, $t5, 8 # shift masked byte 3 into original position of byte 0 
	srl $t7, $t4, 8 # shift masked byte 2 into original position of byte 1
	or $t8, $t7, $t6 # or two registers and store them in t8, or byte 2 n byte 3

	sll $t6, $t2, 8 # shift masked byte 1 into original position of byte 2
	sll $t7, $t1, 24 # shift masked byte 0 into original position of byte 3
	or $t9, $t7, $t6 # or two registers and store them in t9, or byte 1 n byte 2
	or $t9, $t9, $t8 # or two registers and store them in t9

	li $v0, 1 # load the print_int syscall
	move $a0, $t9
	syscall
	
	li $v0, 10
	syscall

	
