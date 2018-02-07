.text
CubeStats:
	subu $sp, $sp, 4
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 36
	sw $s0, -4($fp)
	sw $s1, -8($fp)
	sw $s2, -12($fp)
	sw $s3, -16($fp)
	sw $s4, -20($fp)
	sw $s5,	-24($fp)
	sw $s6, -28($fp)
	sw $s7, -32($fp)
	sw $ra, -36($fp)
	
	lw $s1, 0($a1)
	lw $s, 0()
	sub $t9, $s1, $s4 # Get the number of elements to skip (size - edge)
	add $s1 , $  
	mult $t1, $t9, $s1 # (size-edge)*size
	
	move $s0, $a0 # dimension
	move $s1, $a1 # size
	move $s3, $a2 # corner
	move $s4, $a3 # edge
	 
	
	addi $t0, $zero, 0
	addi $t2, $zero, 0
	addi $t6, $zero, 0
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $s5, $zero, 0
	
	lw $t3, 0($s0) #dimension
	lw $t4, 0($s4) #edge
	
	Row:
		beq $t0, $t4, NextRow # 0 - edge 
		lw $t5, 0($s3) # $t5 <-- The element at the indicated address
		addi $t0, $t0, 1
		addi $s3, $s3, 4
		j CheckNum
	
	CheckNum:
		bgtz $t5, Pos
		beqz $t5, Zero
		bltz $t5, Neg

	Pos:
		addi $t6, $t6, 1
		add $t2, $t2, $t5
		j Row

	Neg:
		addi $t7, $t7, 1
		add $t8, $t8, $t5
		j Row
		
	NextRow:
		addi $s5, $s5, 1
		mult $t9, $t9, 4
		add $s3, $s3, $t9
		addi $t0, $zero,0
		beq $s5, $t4, NextDim
		j Row
	
	NextDim:
		addi $s5, $zero, 0
		
		
		
	lw $s0, -4($fp)
	lw $s1, -8($fp)
	lw $s2, -12($fp)
	lw $s3, -16($fp)
	lw $s4, -20($fp)
	lw $s5,	-24($fp)
	lw $s6, -28($fp)
	lw $s7, -32($fp)
	lw $ra, -36($fp)
	addu $sp, $sp, 40
	lw $fp, -4($sp)
	jr $ra
