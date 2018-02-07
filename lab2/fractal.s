
# The following format is required for all submissions in CMPUT 229
#
# The following copyright notice does not apply to this file
# It is included here because it should be included in all
# solutions submitted by students.
#
#----------------------------------------------------------------
#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2017 <student name>
#
# Unauthorized redistribution is forbidden in all circumstances. Use of this
# software without explicit authorization from the author or CMPUT 229
# Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# Assignment:           2
# Due Date:             October 10 2017
# Name:                 Siddhant Khanna
# Unix ID:              skhanna1
# Lecture Section:      A1
# Instructor:           Nelson Amaral
# Lab Section:          L3 (Monday 1400 - 1700)
# Teaching Assistant:   Joe Johnson
#---------------------------------------------------------------

#---------------------------------------------------------------
# The use of this program is to use create fractal from the 
# complex numbers given. If the complex number is greater than 
# 4 then print a specific symbol with a specific color for the 
# complex number. We use set_size function to create the size of
# the terminal. Then call map coords to map the terminal to the
# complex plane position and then call calculate_escape to 
# the symbol and color of the complex number at that position
# from the render function
#
# Register Usage:
#
#       
#   $a0 = the max number of iterations.
#   x_0: .double = Initial real value of the complex number
#   y_0: .double = Initial imaginary value of the complex number
#	v0 = 'has_escaped', 1 if the number escaped before the max number of iterations.
#   $v1 = The number of iterations the algorithm went through before 
#   		stopping. If the the max number of iterations was r
#           eached ($v0 = 0) then this value is the value of $a0
# 	$s3: for checking the iteration the complex number at
#   $f0: x0*x0 + y0*y0 <= 4
#   $f2: 2.x0
#   $f4: x_0
#	$f6: y_0
#	$f8: y0*y0
#	$f10: x0*x0 + y0*y0
#	$f12: storing x_0 for addition
#	$f14: y0*y0 - y0
#	$f16: for multiplying 2	
#	$f18: x0*x0 - y0*y0 (a^2 - b^2) 
#---------------------------------------------------------------


calculate_escape:

		addi $sp, $sp, -8 		#storing registers
		sw $ra, 0($sp)
		sw $s3, 4($sp)

		l.d $f4, x_0 		#x_0
		l.d $f6, y_0		#y_0

		addi $s3, $zero, 0 	#0

		li.d $f10, 4.0 		#for checking if escaped 4
		#cvt.d.w $f10, $f10
		li.d $f16, 2.0 		#for multiplying 2	
		#cvt.d.w $f16, $f16

		l.d $f12, x_0  		#storing x_0 for addition
		l.d $f14, y_0		#same for y_0
		
		li.d $f0, 0.0

	Loop:

		mul.d $f18, $f12, $f12 	#x0*x0
		mul.d $f8, $f14, $f14 	#y0*y0
		add.d $f0, $f18, $f8 	#x0*x0 + y0*y0

		c.le.d $f0, $f10 		# x0*x0 + y0*y0 <= 4
		bc1f Escaped

		mul.d $f2, $f12, $f16 	# 2.x0
		mul.d $f2, $f2, $f14 	# 2.x0.y0 - i value (2ab)
		sub.d $f18, $f18, $f8 	# x0*x0 - y0*y0 (a^2 - b^2) 

		add.d $f12, $f18, $f4 	# x0*x0 - y0*y0 + x0 (Real Side)
		add.d $f14, $f2, $f6 	# y0*y0 - y0
		
		addi $s3, $s3, 1 		#adding to show moving on to next iteration

		beq $s3, $a0, END 		#checking how many iterations happened
		

		j Loop

	END:
		li $v0, 0 			#if not escapesd give 0
		move $v1, $a0 		#send iterations
		lw $ra, 0($sp)
		lw $s3, 4($sp)
		addi $sp, $sp, 8
		jr $ra

	Escaped:
		li $v0, 1 		#escape send 1
		move $v1, $s3 	#send iterations not max
		lw $ra, 0($sp)
		lw $s3, 4($sp)
		addi $sp, $sp, 8
		jr $ra
		
#---------------------------------------------------------------
# For getting the size of the terminal
#
# Register Usage:
#   $f12 = maximum imaginary value being rendered, set max_i to this value.
#    $f14 = minimum imaginary value being rendered
#   $f16 = maximum real value being rendered
#    $f18 = minimum real value being rendered, set min_r to this value.
#    $a0 = number of rows in the screen
#    $a1 = number of columns in the screen
# 	max_i: max no of columns
# 	min_r: minimum no o frows
 #---------------------------------------------------------------
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


#---------------------------------------------------------------
# The use of this program is to use create fractal from the 
# complex numbers given. If the complex number is greater than 
# 4 then print a specific symbol with a specific color for the 
# complex number. We use set_size function to create the size of
# the terminal. Then call map coords to map the terminal to the
# complex plane position and then call calculate_escape to 
# the symbol and color of the complex number at that position
# from the render function
#
# Register Usage:
#
#       
#   $a0 = number of Rows in screen
#   $a1 = number of Columns in the screen
#   $a2 = max number of iterations
#	#s0 = nRows
#	$s1 = nColumns
#	$s2 = position of the column
#	$s3 = once row reaches end it Ends the program
#	$s4 = loading the color have here
#	$s5 = loading the symbol have here
#	$s6 = loading palettesize
#	$s7	= load the symbols
#---------------------------------------------------------------


render:
	addi $sp, $sp, -44 	#storing registers
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
	sw $a2, 40($sp)

	move $s0, $a0 #nRows
	move $s1, $a1 #nColumns

	li $s2, 0     #position of the column
	li $s3, 0 	  #position of the row

Loop3:

	beq $s3, $s1, End 	#once row reaches end it Ends the program

	Loop2:

		beq $s2, $s0, NextRow 	#once the column reaches end goes to the
								#next column

		move $a0, $s2			#position of the column
		move $a1, $s3 			#position of the row
		jal map_coords 			#calling the map coords

		s.d $f0, x_0 			#x_0 gets value for calc
		s.d $f2, y_0 			#same y_0
		#move $a0, $a2  			#maximum number of iterations		
		lw $a0, 40($sp)
		jal calculate_escape	#calling calculate escape

		li $s4, 0				#for checking if the complex numbers escaped
		bne $v0, $s4, MaxNotReached #if did not reach max
		beq $v0, $s4, MaxReached 	#If reached max iter
		

		Continue:

			move $a0, $s4 		#value for color we got from inSetColor/colors
			li $a1, 0 			
			jal setColor

			move $a0, $s5 		#giving arguments for string
			move $a1, $s2 		#position
			move $a2, $s3 		#position
			jal printString

			addi $s2, $s2, 1 		#adding 1 to move onto the next

	j Loop2

NextRow:
	addi $s3, $s3, 1 	#incrementing the row position
	li $s2, 0 			#Going back to pos 0 column in new row
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

	lw $ra, 0($sp) 			#done storing registers
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
