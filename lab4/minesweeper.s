.text
hasBomb:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	move $s0, $a0 		#Row byte(3)
							#(Because Gameboard is Stored as byte array)
	
	move $s2, $a1			#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s0	#Tile position in the board
	
	####### Check if Bomb ###########
	#check if it is a Bomb
	andi $s3, $s1, 0x01		#getting the first bit
	beq $s3, 0x01, isBomb	
	li $v0, 0

	j endHasBomb

	isBomb:
		li $v0, 1
	
		j endHasBomb

	endHasBomb:	
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		addi $sp, $sp, 20

		jr $ra


.text
setBomb:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	#sets the tile to be a bomb
	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	move $s0, $a0 		#Row byte(3)
							#(Because Gameboard is Stored as byte array)
	
	move $s2, $a1			#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s0	#Tile position in the board

	#######Setting Up Bombs ###########

	#setting it to a bomb (unrevealed ?)
	li $s3, 0x01 		#loading byte to s3
	sb $s3, 0($s1)		#putting the byte 1 at the position

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20

	jr $ra


.text
prepareBoard:
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


	la $s0, gameRows	#Address of Row value
	lw $s1, 0($s0)		#No of Rows (20)

	la $s2, gameCols 	#Address of columns
	lw $s3, 0($s2)		#No of Columns (40)

	mult $s3, $s1		#Column*Row
	mflo $s2			#value (20*40)

	la $s0, gameBoard 	#Get the address of gameBoard
	move $s5, $s0		#s5 also have address

	add $s2, $s0, $s2	#adding to the beginning addres of gameboard to get the end of the board

	li $s6, 0

	loop:
		beq $s0, $s2, endPrepareBoard	#Check if reached end of gameboard
		lb $s4, 0($s0)					#loading byte value at the current tile
		li $s7, 0						#flag for checking previous and next row
		move $s1, $s0					#get the current tile in s1
		bne $s4, 0x01, checkBomb 		#checking if tile byte value is bomb
		j ContinueLoop 					#move to next tile if current tile is bomb

	ContinueLoop:					
		
		li $s6, 0						#reinitializing the total number of bombs around that tile
		addi $s0, $s0, 1				#move to next tile (since s0 has the address of current tile position)
		j loop

	######Checking If Bomb around the number#######
	checkBomb:		

		beq $s7, 0, goBackRow 			#check the previous row
		beq $s7, 1, goFrontRow
		beq $s7, 2, goOriginalPos
		beq $s7, 3, endCheckBomb

	goBackRow:
		addi $s7, $s7, 1				#initialize for Front Row

	 	sub $s0, $s0, $s3 				#subtract number of columns to go to previous row

		blt $s0, $s5, goFrontRow		#if value is less than the beginning address then go front row
		
		j continue 						#perform the previous columnn and next column computation

	goFrontRow:
		add $s0, $s0, $s3				#adding next column to back to original position
		addi $s7, $s7, 1 	
		
		add $s0, $s0, $s3 				#next Row

		bgt $s0, $s2, goOriginalPos 	#address greater than final address

		j continue

	goOriginalPos:
		sub $s0, $s0, $s3				#getting back to position original

		addi $s7, $s7, 1 	
		
		j continue


	continue:

		lb $s4, 0($s0)		#checking if middle position has a bomb
		bne $s4, 0x01, continue1

		addi $s6, $s6, 1	#increment the number of bomb around the tile

		j continue1

	continue1:

	 	addi $s0, $s0, -1	#checking left position has a bomb
	
	 	lb $s4, 0($s0)
	  	bne $s4, 0x01, continue2

		addi $s6, $s6, 1

		j continue2

	continue2:

		addi $s0, $s0, 1	#getting back to middle position

	  	addi $s0, $s0, 1	#going to the right position

	  	lb $s4, 0($s0)
	  	bne $s4, 0x01, continue3

	  	addi $s6, $s6, 1
	  	j continue3
	 	
	continue3:

		addi $s0, $s0, -1	#getting back to the middle position

		j checkBomb


	endCheckBomb:

		lb $s7, 0($s1) 		#has the byte value of current address

		sra $s7, $s7, 4		#shifts left to get the top 4 bits
		add $s7, $s7, $s6 	#adding the number of bombs around the current value to byte
		sll $s7, $s7, 4		#shifting it back to make it 8 bits

		sb $s7, 0($s1) 		#store the value we got for the total number of bombs into the current tile

		j ContinueLoop

	endPrepareBoard:
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
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)


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
	lb $s4, 0($s1)
	beq $s4, 0x01, printBomb
	
	sra $s4, $s4, 4		#get the top part of the bits to see the number of bombs around it


	beq $s4, 0x00, print0
	beq $s4, 0x01, print1
	beq $s4, 0x02, print2
	beq $s4, 0x03, print3
	beq $s4, 0x04, print4
	beq $s4, 0x05, print5
	beq $s4, 0x06, print6
	beq $s4, 0x07, print7
	beq $s4, 0x08, print8
	

	la $s3, tile
	move $a2, $a1
	move $a1, $a0
	move $a0, $s3
	
	jal printString
	
	j endPrintTile

	printBomb:
		la $s3, bomb
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print0:
		sll $s4, $s4, 4
		la $s3, has0
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print1:
		sll $s4, $s4, 4
		la $s3, has1
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print2:
		sll $s4, $s4, 4
		la $s3, has2
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print3:
		sll $s4, $s4, 4
		la $s3, has3
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print4:
		sll $s4, $s4, 4
		la $s3, has4
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print5:
		sll $s4, $s4, 4
		la $s3, has5
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print6:
		sll $s4, $s4, 4
		la $s3, has6
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print7:
		sll $s4, $s4, 4
		la $s3, has7
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	print8:
		sll $s4, $s4, 4
		la $s3, has8
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString

		j endPrintTile

	endPrintTile:
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		addi $sp, $sp, 24
	
		jr $ra

