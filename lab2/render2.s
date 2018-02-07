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

	move $s0, $a0 #nRows
	move $s1, $a1 #nColumns

	li $s2, 0     #position of the row
	li $s3, 0 	  #position of the column


Loop3:

	beq $s2, $s0, End

	Loop2:
		beq $s3, $s1, NextRow 


		move $a0, $s2
		move $a1, $s3
		jal map_coords

		s.d $f0, x_0 #~~~why not mov.d
		s.d $f2, y_0
		move $a0, $a2 
		jal calculate_escape

		addi $s3, $s3, 1

		li $s4, 0
		beq $v0, $s4, MaxReached
		bne $v0, $s4, MaxNotReached

		Continue:

			move $a0, $s4
			li $a1, 0
			jal setColor

			move $a0, $s5
			move $a1, $s2
			move $a2, $s3
			jal printString
			j End

		j Loop2

	NextRow:
		addi $s2, $s2, 1
		j Loop3

	MaxReached:
		lb $s4, inSetColor  	#maybe do address
		lb $s5, inSetSymbol
		j Continue


	MaxNotReached:
		#position = iterations%paletteSize
		lw $s6, paletteSize
		div $v1, $s6
		mfhi $s6

		la $s7, colors
		add $t9, $s6, $s7
		lbu $s4, 0($t9)

		la $s7, symbols
		add $t9, $s6, $s7
		la $s5, 0($t9)

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