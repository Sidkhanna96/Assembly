
set_size:  

	s.d $f12, max_i 	#does this erase the values in f12 ?		
	s.d $f18, min_r 	#does this erase the values in f12 ?		

	mov.d $f4, $f14 		#min_i
	mov.d $f6, $f16 		#max_r

	sub.d $f4, $f12, $f4 	#max_i - min_i 	@reusing register
	sub.d $f6, $f6, $f18 	#max_r - min_r 	@reusing register

	mtc1 $a0, $f8 			#storing the nRows in f register
	cvt.d.w $f8, $f8  		#converting to float nRows
	mtc1 $a1, $f10 
	cvt.d.w $f10, $f10 		#converting to float nCols

	div.d $f8, $f4, $f8 	#max_i - min_i/nRows
	div.d $f10, $f6, $f10 	#max_r - min_r/nCols

	s.d $f8, step_i
	s.d $f10, step_r

	jr $ra

calculate_escape:

		addi $sp, $sp, -8
		sw $ra, 0($sp)
		sw $t8, 4($sp)

		l.d $f4, x_0 		#x_0
		l.d $f6, y_0		#y_0

		addi $t8, $zero, 0 	#0

		li.d $f10, 4.0 		#for checking if escaped 4
		#cvt.d.w $f10, $f10
		li.d $f16, 2.0 		#for multiplying 2	
		#cvt.d.w $f16, $f16

		l.d $f12, x_0
		l.d $f14, y_0

	Loop:

		beq $t8, $a0, END 		#checking how many iterations happened
		addi $t8, $t8, 1 		#adding to show moving on to next iteration

		mul.d $f18, $f12, $f12 	#x0*x0
		mul.d $f8, $f14, $f14 	#y0*y0
		add.d $f0, $f18, $f8 	# x0*x0 + y0*y0

		c.le.d $f0, $f10 		# x0*x0 + y0*y0 <= 4
		bc1f Escaped
	
		mul.d $f2, $f12, $f16 		# 2.x0
		mul.d $f2, $f2, $f14 	# 2.x0.y0 - i value (2ab)
		sub.d $f18, $f18, $f8 	# x0*x0 - y0*y0 (a^2 - b^2) 


		add.d $f12, $f18, $f4 	# x0*x0 - y0*y0 + x0 (Real Side)
		add.d $f14, $f2, $f6 	# y0*y0 - y0

		j Loop

	END:
		li $v0, 0
		move $v1, $a0
		j END2

	Escaped:
		li $v0, 1
		move $v1, $t8
		j END2

	END2:
		lw $ra, 0($sp)
		lw $t8, 4($sp)
		addi $sp, $sp, 8
		jr $ra
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

	j END3
	#~~~~~~maybe jump to something~~~~~~`

Continue2:
	
	move $a0, $s4
	li $a0, 0
	jal setColor

	move $a0, $s5
	move $a1, $s2
	move $a2, $s3
	jal printString
	j END3

Rows:
	beq $s2, $s0, END3 	#Reached the last Row

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
	lb $s4, 0($t8)

	la $t9, symbols
	add $s6, $t9, $s3
	la $s5, 0($s6)
	j Continue2


END3:

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