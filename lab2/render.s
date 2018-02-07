.data

.text

render:
	
	addi $sp, $sp, -44
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)
	sw $t8, 36($sp)
	sw $t9, 40($sp)



	add $s0, $zero, $a0 	#nRows
	add $s1, $zero, $a1 	#nCols

	add $s2, $zero, 0 		#Check Rows
	add $s3, $zero, 0		#Check Cols

Continue:

	beq $s3, $s1, Rows 		# on col 1 = 5 (End)
	
	add $a0, $zero, $s2  	#row position
	add $a1, $zero, $s3 	#column position

	jal map_coords			#send the values to map_coords of row position and column position
	
	addi $s3, $s3, 1 		# next column


	move $a0, $a2 	#$a0 has the max iteration to send to calculate escape
	
	s.d $f0, x_0			#~~~~~~~~Do I need to define the x_0 
	s.d $f2, y_0 			#storing value for y_0 as the imaginary value that
							#we got from map_coords
	
	jal calculate_escape 	

	addi $s4, $zero, 0
	beq $v0, $s4, MaxReached 	#Check if not escaped
	bne $v0, $s4, MaxNotReached

	#~~~~~~maybe jump to something~~~~~~`

Continue2:
	
	move $a0, $s4
	li $a0, 0
	jal setColor

	move $a0, $s5
	move $a1, $s2
	move $a2, $s3
	jal printString
	j END

Rows:
	beq $s2, $s0, END 	#Reached the last Row

	addi $s3, $zero, 0 	#setting column back to 0 for new row

	addi $s2, $s2, 1 	#next Row
	j Continue

MaxReached:
	lb $s4, inSetColor 		
	lb $s5, inSetSymbol
	j Continue2

MaxNotReached:
	#postion = $a2/paletteSize
	lw $s6, paletteSize #~~~~~la ? since done in line 89 -> NOPE
	div $v1, $s6 	#dividing the maximum number of iterations with palettesize
	mfhi $s3 		#storing the remainder

	la $s7, colors 	#~~~~~~~~~~~~did address here for some reason -> lb? - NOPE
	add $t8, $s7, $s3 #~~~~~~~should I change my t register ?
	lbu $s4, 0($t8)

	la $t9, symbols
	add $s6, $t9, $s3
	la $s5, 0($s6)
	j Continue2


END:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	lw $t8, 36($sp)
	lw $t9, 40($sp)
	addi $sp, $sp, 44

	jr $ra