#####################################################################################
#	                       							    #
#	$s0 = dimensions of base array						    #
#	$s1 = size of base array						    #
#	$s2 = address of the element needed                  			    #
#	$s3 = length of the cube edge						    #
#	$s4 = size of cube edge ^ dimensions (number of elements)		    #
#	$s5 = size of cube edge squared to track # of elements in one dimension     #
#	$s6 = length of big cube - length of small cube				    #
#	$s7 = calculation for directions to the next plain 			    #
#										    #
#####################################################################################

.data
	newline: 	.asciiz "\n"
	space:		.asciiz " "

.text
	CubeStats:
		# make space on stack for 7 $s registers
		subu $sp, $sp, 4
		sw $fp, 0($sp)
		move $fp, $sp
		subu $sp, $sp, 36
		sw $s0, -4($fp)
		sw $s1, -8($fp)
		sw $s2, -12($fp)
		sw $s3, -16($fp)
		sw $s4, -20($fp)
		sw $s5, -24($fp)
		sw $s6, -28($fp)
		sw $s7, -32($fp)
		sw $ra, -36($fp)

		li $t6, 1

		# put $a0 to $a3 in $s1 to $s3
		move     $s0, $a0	        # $s0 <-- dimensions
		move     $s1, $a1		# $s1 <-- size of base array
		move     $s2, $a2	        # $s2 <-- address
		move     $s3, $a3		# $s3 <-- cube edge length

		# get power(cube edge, dimension) into $s4
		move     $a0, $s3	        # $a0 <-- cube edge length
		move     $a1, $s0	        # $a1 <-- dimension
		jal	 power			# call power(cube edge, dimension)
		move     $s4, $v0		# $s4 <-- power(size, dimension)

		# get power(cube edge, 2) into $s5
		move     $a0, $s3	        # $a0 <-- cube edge length
		li     	 $a1, 2	        	# $a1 <-- 2 for squared value
		jal	 power		        # numelems <-- power(cube egde, 2)
		move     $s5, $v0		# $s5 <-- power(cube edge, 2)

		# make $t1, $t2, $t3 counters from $s4, $s5, $s3 respectively to 0
		addi 	$t1, $s4, 0
		addi 	$t2, $s5, 0
		addi 	$t3, $s3, 0

		# $s6 <---- length of big cube minus length of small cube
		li 	$t4, 4
		sub 	$s6, $s1, $s3
		mul 	$s6, $s6, $t4

		# $s7 <---- directions to next plain
		li 	$t4, 4
		mul	$s7, $s1, $s1
		mul 	$s7, $s7, $t4

		sumloop:
			beqz	$t1, end	# if all elements are summed up, go to end
			beqz 	$t3, nextline	# if all elements in the line are summed, move to next
			beqz	$t2, nextplain	# if all elements in the plain are summed, move to next

			lw	$t4, 0($s2)	# $t4 <-- address

			#li $v0, 1
			#move $a0, $t4
			#syscall

			bgtz 	$t4, posfunc
			bltz	$t4, negfunc 

		posfunc:
			# used to sum up Total Positive Numbers
			lw  	$t0, totalPos
			add 	$t0, $t0, $t4
			sw	$t0, totalPos

			# used to increment Positive Numbers counter
			lw  	$t0, countPos
			addi 	$t0, $t0, 1
			sw	$t0, countPos

			j 	decrement

		negfunc:
			# used to sum up Total Negative Numbers
			lw  	$t0, totalNeg
			add 	$t0, $t0, $t4
			sw	$t0, totalNeg

			# used to increment Negative Numbers counter
			lw 	$t0, countNeg
			addi 	$t0, $t0, 1
			sw	$t0, countNeg

			j 	decrement

		decrement:
			# dereases each counter by 1 till it reaches 0
			addi	$t1, $t1, -1
			addi	$t2, $t2, -1
			addi	$t3, $t3, -1

			# moves on to the next integer address
			addi	$s2, $s2, 4

			j  	sumloop

		nextplain:
			# routes the pointer to the next plain for dimensions > 2
			# does this by using the intial address given
			move    $s2, $a2
			mul  	$t5, $s7, $t6
			add 	$s2, $s2, $t5

			addi 	$t6, $t6, 1
			addi 	$t2, $s5, 0

			j 	sumloop

		nextline:
			# adds 4*(length of big square - length of small square) to address
			add 	$s2, $s2, $s6
			addi 	$t3, $s3, 0

			j 	sumloop

		end:
			# get final values of counts and total from the main function
			lw 	$t0, countNeg
			lw 	$t1, countPos
			lw 	$t2, totalNeg
			lw 	$t3, totalPos

			#li $v0, 1
			#move $a0, $t0
			#syscall

			div 	$t2, $t0
			mflo 	$v0
			mfhi	$t7
			beqz	$t7, skipadd
			addi 	$v0, $v0, -1	# adds -1 to get floor of negative numbers average

		skipadd:
			div 	$t3, $t1
			mflo 	$v1

			beqz	$t0, makenegzero
			beqz	$t1, makeposzero

			j 		therest

		makenegzero:
			li 		$v0, 0
			j 		therest

		makeposzero:
			li 		$v1, 0
			j 		therest

		therest:
			lw $s0, -4($fp)
			lw $s1, -8($fp)
			lw $s2, -12($fp)
			lw $s3, -16($fp)
			lw $s4, -20($fp)
			lw $s5, -24($fp)
			lw $s6, -28($fp)
			lw $s7, -32($fp)
			lw $ra, -36($fp)
			addu $sp, $sp, 40
			lw $fp, -4($sp)

	jr $ra
