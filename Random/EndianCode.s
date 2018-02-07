main:

	li $v0, 5 #load immediate value -> used for read_int
	syscall
	
	addi $t0, $zero, 0x00FF #t0: masking no.
	
	and $t1, $v0, $t0 #will get the byte 1 from no. in byte 4 place
	sll $t2, $t1, 24 #shift byte 1 to left
	sll $t0, $t0, 8 #shift the mask no to the left for getting byte 2
	
	and $t1, $v0, $t0 #will get the byte 2 from no. in byte 3 place
	sll $t1, $t1, 8 # will get the byte 2 shifted towards left
	or $t2, $t2, $t1 #will put the byte 2 into the original register
	sll $t0, $t0, 8 #shift the mask no to left for getting byte 3
	
	and $t1, $v0, $t0 #will get the byte 3
	srl $t1, $t1, 8 #will get the byte 3 to the right in byte 2 place
	or $t2, $t2, $t1 # will put the byte 3 into the original register
	sll $t0, $t0, 8 #shift the mask no to the left for getting byte 4
	
	and $t1, $v0, $t0 #will get the byte 4
	srl $t1, $t1, 24 # will shift the byte 4 to the right in byte 1 place
	or $t2, $t2, $t1 #will put the byte in the original register
	
	li $v0, 1
	syscall
	
