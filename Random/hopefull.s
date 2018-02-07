main:
	li $v0, 5
	syscall
	
	andi $t0, $zero, 0x00FF #t0  the mask no.
	
	and $t1, $v0, $t0 # getting the first byte
	sll $t1, $t1, 24
	
	li $s0, $t0
	sll $t0, $s0, 8
	and $t3, $v0, $t0 #giving me the scond byte
	sll $t3, $t3, 8
	
	sll $t0, $t0, 8
	and $t4, $v0, $t0  #giving me the third byte
	sll 
