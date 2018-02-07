.data
	x_0: .double 0.4
	y_0: .double 0.5
.text
	
	main:
	addi $a0, $zero, 20
	#addi $v0, $zero, 13
	#addi $v1, $zero, 13
	jal calculate_escape
	li $v0 10
	syscall

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
		li.d $f0, 0.0

	Loop:

		beq $t8, $a0, END 		#checking how many iterations happened
		#addi $t8, $t8, 1 		#adding to show moving on to next iteration

		mul.d $f18, $f12, $f12 	#x0*x0
		mul.d $f8, $f14, $f14 	#y0*y0
		add.d $f0, $f18, $f8 	# x0*x0 + y0*y0

		c.lt.d $f0, $f10 		# x0*x0 + y0*y0 <= 4
		bc1f Escaped
	
		mul.d $f2, $f12, $f16 		# 2.x0
		mul.d $f2, $f2, $f14 	# 2.x0.y0 - i value (2ab)
		sub.d $f18, $f18, $f8 	# x0*x0 - y0*y0 (a^2 - b^2) 


		add.d $f12, $f18, $f4 	# x0*x0 - y0*y0 + x0 (Real Side)
		add.d $f14, $f2, $f6 	# y0*y0 - y0

		addi $t8, $t8, 1 		#adding to show moving on to next iteration

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