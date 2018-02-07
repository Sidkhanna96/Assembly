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
	
	move $t0, $a1 #size
	move $t1, $a3 #edge
	
	sub $t2, $t0, $t1 # (size-edge)
	addi $s7, $zero, 4
	mult $t2, $s7
	mflo $t2
	
	mult $t0, $t0
	mflo $t0
	addi $s0, $zero, 4 
	mult $t0, $s0
	mflo $t0
	
	#Address of ->	
	move $s0, $a0 # dimension
	move $s1, $a1 # size
	move $s3, $a2 # corner
	move $s6, $a2 # corner 2
	move $s4, $a3 # edge
	
	addi $t3, $zero, 0
	addi $t5, $zero, 0
	addi $t6, $zero, 0
	addi $t7, $zero, 0
	addi $t8, $zero, 0
	addi $t9, $zero, 0
	
	addi $s5, $zero, 1
	
	
	Row:
		beq $t3, $t1, NextRow 	# t3(in row) counter is equal to t1 edge
		beq $t9, $t1, NextDim 	# t9(in nextrow) counter is equal to edge 
				     	# just to do those number of rows		
		lw $t4, 0($s3) 		#$t4 <-- the element at the indicated address
		bgtz $t4, Pos		#check if positive
		bltz $t4, Neg		# check if Negative
		beq $t4, 0, Zer		# check if zero
		
		
	Continue:
		addi $s3, $s3, 4 	# goes to the next element
		addi $t3, $t3, 1	#counts if taken the number of correct element
		j Row			# go back loop
	Pos:
		addi $t5, $t5, 1 	#no of positive elements
		add $t6, $t6, $t4 	# total positive
		j Continue
	Neg:
		add $t7, $t7, 1
		add $t8, $t8, $t4
		j Continue
	Zer:
		# Do Nothing
		# Blessed
		j Continue
		
	NextRow:	
		
		beq $s0, 1, Avg		#dim counter equal to 1 no need to do next row/dim
		add $s3, $s3, $t2	#t2 is size-edge * 4 -> goes to next row
		addi $t3, $zero, 0 	#makes the comparison t3-0 for reuse in Row
		addi $t9, $t9, 1	#count the number of rows
		j Row
		
	NextDim:
		beq $s5, $t1, Avg
		addi $s5, $s5, 1
		addi $t9, $zero, 0
		add $s6, $s6, $t0	# going to the next dimension
		move $s3, $s6		# putting the value to s3 as it has changed 
		j Row
	Avg:
		beqz $t5, PosAddOne
		j AvgContinue
	PosAddOne:
		add $t5, $zero, 1
		j AvgContinue
		
	AvgContinue:
		li $v0, 1
		add $a0, $zero, $t5
		syscall
		
		li $v0, 1
		add $a0, $zero, $t6
		syscall
		
		div $t6, $t5
		mflo $t6
		
		li $v0, 1
		add $a0, $zero, $t7
		syscall
		
		li $v0, 1
		add $a0, $zero, $t7
		syscall
		
		beqz $t7, NegAddOne
		j AvgContinue2
	NegAddOne:
		add $t7, $zero, 1
		j AvgContinue2
	
	AvgContinue2: 
		div $t8, $t7
		mflo $t8
		mfhi $t7 #remainder

		bltz $t7 , SubOne
		j Continue2
		
	SubOne:
	
		sub $t8, $t8, 1
		j Continue2
		
	Continue2:
		add $v0, $zero, $t8
		add $v1, $zero, $t6
	
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
