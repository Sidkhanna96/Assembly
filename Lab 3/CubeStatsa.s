#---------------------------------------------------------------
# Assignment:           3
# Due Date:             October 31, 2016
# Name:                 Siddhant Khanna
# Unix ID:              skhanna1
# Lecture Section:      A1
# Instructor:           Jose Nelson Amaral
# Lab Section:          Lab D06(Thursday5-8)
# Teaching Assistant:   Shantong Zhang
#---------------------------------------------------------------


#---------------------------------------------------------------
# This Subroutine recieves a position/corner, dimension, size and edge of an Multi-dimensional array; It computes the range and average of
# certain elements of the multi dimensional. This subroutine achieves this by using stack pointer and frame pointer of stacks in order to 
# use the s registers. The Subroutine first checks the element for whether it is positive negative or zero and accordingly adds the value
# to that corresponding register However, if the value of the element is zero then the subroutine simply skips it. Next it moves onto the 
# next element of the array till it reaches the required edge length of the array. Next after evaluating the values of the first row and 
# moving on to the next element the subroutine moves to the next row and similarly it moves onto the next dimension until it reaches the 
# the length equivalent of that array. The subroutine aim is to calculate the average of the K - Dimensions.
#
# Register Usage:
#	$a0: Dimension of array.
#	$a1: Size of the base array.
#	$a2: Corner/Address of the base element.
#	$a3: Edge of the cube of the array.
#	$s0: Contain the dimension element of argument $a0/ also used to mult 4 to $t0.
#	$s1: Contain the size argument of $a1.
#	$s2: total number of elements to be accessed.
#	$s3: contain corner $a2 register. used to access element.
#	$s4: containes the edge of argument $s2.
#	$s5: Counter for number of elements to be accessed. Starts at 0.
#	$s6: Contain $a2 i.e corner value. This register value is never changed and always points to the first element
#	$s7: multiplying 4 to $t2
#	$t0: contained size/ later multiplyed by itself so that can have as many elements as the difference between the next dimension and #		the current dimension element of the same address
#	$t1: t1 edge of the array
#	$t2: size - edge value -> in order to skip the number of elements required to skip in the next row
#	$t3: counter 0 for next row/ counter for calculating the total number of elements we need loops condition.
#	$t4: contains the current element value.
#	$t5: counter 0 for counting number of positive elements.
#	$t6: sum of all the postive elements needed.
#	$t7: counter 0 for total number of negative elements in the multi dimensional array.
#	$t8: sum of all the negative elements.
#	$t9: counter to check if we should move onto the next dimension.
#       $v0: returns the negative value of the avg of the elements in a multi dimensional array
# 	$v1: returns the postive value floor avg of the elements in a multi dimensional array
#---------------------------------------------------------------


#subroutine begins
CubeStats:
	#invoking stacks for in order for the subroutine to access s registers
	subu $sp, $sp, 4	# decrease stack pointer memory adress by 4
	sw $fp, 0($sp)		# place the frame pointer at the top
	move $fp, $sp
	subu $sp, $sp, 36	# create space for all the s registers in the stack memory
	
	# placing all the s register elements in the stack using fram pointer
	# saving registers in order to use them in the future
	sw $s0, -4($fp)
	sw $s1, -8($fp)
	sw $s2, -12($fp)
	sw $s3, -16($fp)
	sw $s4, -20($fp)
	sw $s5,	-24($fp)
	sw $s6, -28($fp)
	sw $s7, -32($fp)
	sw $ra, -36($fp)
	
	move $t0, $a1 #getting the size of the multi dimensional array
	move $t1, $a3 #getting the edge of the multi dimensional array
	
	sub $t2, $t0, $t1 	# (size-edge) stored in t2 for enabling to skip number of elements in a row
	addi $s7, $zero, 4
	mult $t2, $s7
	mflo $t2		# multiplied the total elements to skip by 4 and putting it in t2 in order to move by that many elements in
				# in memory
	
	mult $t0, $t0		# obatining the total number of elements in one of the dimension of k-dimensional array 
	mflo $t0	
	addi $s0, $zero, 4 
	mult $t0, $s0
	mflo $t0		# multiplying the total number of elements in a dimension by 4
	
	#Address of ->	
	move $s0, $a0 # dimension
	move $s1, $a1 # size
	move $s3, $a2 # corner
	move $s6, $a2 # corner 2
	move $s4, $a3 # edge
	
	
	addi $s2, $zero, 1
	addi $t3, $zero, 0
	
	#getting total number of elements i.e if edge is 3 and dimension is 4 -> 3^4 number of elements would be accessed
	Power:	
		beq $t3, $s0, Next	# if the counter is equal to the dimension it will move on to the rest of the code
		mult $s2, $s4		# trying to compute the power here -> edge multiplied by itself and the loop only ends if it has been ran a total of the value of dimension
		mflo $s2		
		addi $t3, $t3, 1	#counter
		j Power

	Next:
		
	
		#counter and sum initializers
		addi $t3, $zero, 0
		addi $t5, $zero, 0
		addi $t6, $zero, 0
		addi $t7, $zero, 0
		addi $t8, $zero, 0
		addi $t9, $zero, 0
	
		addi $s5, $zero, 0
	
	
		Row:
			beq $t3, $t1, NextRow 	# t3(in row) counter is equal to t1 edge then move onto next row
			beq $t9, $t1, NextDim 	# t9(in nextrow) counter is equal to edge then the column length has been traversed and hence
						# we should move onto the next dimension	
			lw $t4, 0($s3)	 	#$t4 <-- putting the element value at the indicated address into $t4
			
		
			bgtz $t4, Pos		# check if element at current position is positive
			bltz $t4, Neg		# check if element at current position is Negative
			beq $t4, 0, Zer		# check if element at current position is zero
			
			
		Continue:
			addi $s5, $s5, 1
			addi $s3, $s3, 4 	# goes to the next element
			addi $t3, $t3, 1	# increases by 1 to move onto next element and hence check if the number of elements selected is 
						# equal to edge 
			j Row			# go back loop
		Pos:
			addi $t5, $t5, 1 	# no of positive elements
			add $t6, $t6, $t4 	# total positive sum elements
			j Continue
		Neg:
			add $t7, $t7, 1		# no of negative elements
			add $t8, $t8, $t4	# total -ve sum elements
			j Continue
		Zer:
			# Do Nothing in this label as zero is not counted
			# Blessed
			j Continue
		
		NextRow:	
		
			beq $s0, 1, Avg		# dim given is equal to 1 no need to do next row or dimension hence just compute the average
			add $s3, $s3, $t2	# t2 is size-edge * 4 -> goes to next row
			addi $t3, $zero, 0 	# makes the comparison t3= 0 for reuse in Row to only take the elements equal to the edge specified
			addi $t9, $t9, 1	# count the number of rows accessed not exceed the edge
			j Row
		
		NextDim:
			beq $s5, $s2, Avg	# moves onto calculating the average if the elements accessed is equal to the total number of elements needed which is equal to $s2
			addi $t9, $zero, 0	# resetting the row counter
			add $s6, $s6, $t0	# going to the next dimension by adding the total number of elements present in a dimension of 							# the multi dimensional arreay so we can access the element at the same postion of the begining
						# element in the next dimension
			move $s3, $s6		# putting the value to s3 as s3 is the  register used to access the values
			j Row
		Avg:
			beqz $t5, PosAddOne	# if counter is equal to zero since we cant divide by zero hence move to posaddone
			j AvgContinue		# if not zero then just calculate the avg
		PosAddOne:
			add $t5, $zero, 1	# here assign the counter value to 1 in order to not get division 0/0 
			j AvgContinue
		
		AvgContinue:
			div $t6, $t5		# calculating the positive average of all the postive number of multi dimensional array
						# since division gives floor by default we dont have to worry about it.
			mflo $t6
			beqz $t7, NegAddOne	# checking if counter for negative sum is 0 if so we cannot divide by 0 hence move to NegAddOne
			j AvgContinue2
		NegAddOne:
			add $t7, $zero, 1	# adds one to counter in order to have 0/1 to prevent the program from giving garbage values.
			j AvgContinue2
	
		AvgContinue2: 
			div $t8, $t7		# get the negative average
			mflo $t8
			mfhi $t7 #remainder	

			bltz $t7 , SubOne	# if the division of sum of negative gives remainder other than 0 we need to calculate the floor
						# in order to do so we subtract 1 to it for getting the floor value
			j Continue2
		
		SubOne:
	
			sub $t8, $t8, 1		# subtracting the quotient we got from the division of avg with 1 in order to get the floor
						# of the negative numbers sum
			j Continue2
		
		Continue2:
			add $v0, $zero, $t8	# printing the negative number in $v0
			add $v1, $zero, $t6	# printing the positive number in $v1
			
		# restoring the elements of the s registers.
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
		lw $fp, -4($sp)			# fp present below sp
		jr $ra				# return statement
