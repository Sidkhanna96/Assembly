.text
getTile:
	addi $sp, $sp, -36
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	sw $s7, 32($sp)


	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	move $s0, $a0		#Row byte(3)
						#(Because Gameboard is Stored as byte array)
	
	move $s2, $a1		#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s0	#Tile position in the board

	#####Printing the bombs########

	lb $s7, 0($s1) 		#Has the byte value

	#getting the second and third bit is it revealed/flag
	move $s6, $s7
	srl $s6, $s6, 1

	srl $s6, $s6, 1
	andi $s6, $s6, 0x01
	beq $s6, 0, Tile

	lb $s4, 0($s1)
	beq $s4, 0x01, addrBomb	
	sra $s4, $s4, 4		#get the top part of the bits to see the number of bombs around it

	beq $s4, 0x00, addr0
	beq $s4, 0x01, addr1
	beq $s4, 0x02, addr2
	beq $s4, 0x03, addr3
	beq $s4, 0x04, addr4
	beq $s4, 0x05, addr5
	beq $s4, 0x06, addr6
	beq $s4, 0x07, addr7
	beq $s4, 0x08, addr8

	Tile:
		la $v0, tile
		j endGetTile

	addrBomb:
		la $v0, bomb
		j endGetTile

	addr0:
		la $v0, has0
		j endGetTile
	addr1:
		la $v0, has1
		j endGetTile
	addr2:
		la $v0, has2
		j endGetTile
	addr3:
		la $v0, has3
		j endGetTile
	addr4:
		la $v0, has4
		j endGetTile
	addr5:
		la $v0, has5
		j endGetTile
	addr6:
		la $v0, has6
		j endGetTile
	addr7:
		la $v0, has7
		j endGetTile
	addr8:
		la $v0, has8
		j endGetTile

	endGetTile:

		# move $v1, $s6
	
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra


.text
printTile:
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	jal getTile

	# move $s5, $v1
	# andi $s5, $s5, 0x01
	# bne $s5, 0x01, Tile 	#if not revealed

	# move $s5, $v1
	# srl $s5, $s5, 1
	# andi $s5, $s5, 0x01
	# beq $s5, 0x01, printFlag

	default:

		move $s3, $v0 		#will have the address of the string to print
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
		
		jal printString

		j endPrintTile


	# Tile:
	# 	la $s3, tile
	# 	move $a2, $a1
	# 	move $a1, $a0
	# 	move $a0, $s3
	
	# 	jal printString
	
	# 	j endPrintTile

	# printFlag:
	# 	la $s3, marked
	# 	move $a2, $a1
	# 	move $a1, $a0
	# 	move $a0, $s3

	# 	jal printString

	# 	j endPrintTile
	

	endPrintTile:
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		addi $sp, $sp, 28
	
		jr $ra
