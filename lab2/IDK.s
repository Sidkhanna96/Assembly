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

	move $s0, $a0 #nRows
	move $s1, $a1 #nColumns

	li $s2, 0     #position of the column
	li $s3, 0 	  #position of the row

Loop3:

	beq $s3, $s1, End 	#once row reaches end it Ends the program

	Loop2:
		addi $s2, $s2, 1 		#adding 1 to move onto the next 
		beq $s2, $s0, NextRow 	#once the column reaches end goes to the
								#next column
		move $a0, $s2			#position of the column
		move $a1, $s3 			#position of the row
		jal map_coords 			#calling the map coords

		s.d $f0, x_0 			#x_0 gets value for calc
		s.d $f2, y_0 			#same y_0
		move $a0, $a2  			#maximum number of iterations		
		jal calculate_escape	#calling calculate escape

		li $s4, 0				#for checking if the complex numbers escaped
		beq $v0, $s4, MaxReached 	#If reached max iter
		bne $v0, $s4, MaxNotReached #if did not reach max

		Continue:

			move $a0, $s4 		#value for color we got from inSetColor/colors
			li $a1, 0 			
			jal setColor

			move $a0, $s5
			move $a1, $s2
			move $a2, $s3
			jal printString


		j Loop2

	NextRow:
		li $s2, 0 			#Going back to pos 0 column in new row
		addi $s3, $s3, 1 	#incrementing the row position
		j Loop3 			

	MaxReached:
		lb $s4, inSetColor  	#loading the color have here
		la $s5, inSetSymbol 	#loading the symbol have here
		j Continue


	MaxNotReached:
		#position = iterations%paletteSize
		lw $s6, paletteSize 	#loading palettesize
		div $v1, $s6 			#dividing the iteration value 
		mfhi $s6 				#modulo

		la $s7, colors 			#calling colors for escaped
		add $s5, $s6, $s7 		#adding to find the correct color
		lbu $s4, 0($s5) 		#get the color to print in s4

		la $s7, symbols 		#load the symbols
		sll $s6, $s6, 1 		#shifting by 1
		add $s5, $s6, $s7 		#getting the value

		j Continue


	End:

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
