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

		move $v1, $s6
	
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

	move $s5, $v1
	andi $s5, $s5, 0x01
	bne $s5, 0x01, Tile 	#if not revealed

	move $s5, $v1
	srl $s5, $s5, 1
	andi $s5, $s5, 0x01
	beq $s5, 0x01, printFlag

	default:

		move $s3, $v0 		#will have the address of the string to print
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
		
		jal printString

		j endPrintTile


	Tile:
		la $s3, tile
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3
	
		jal printString
	
		j endPrintTile

	printFlag:
		la $s3, marked
		move $a2, $a1
		move $a1, $a0
		move $a0, $s3

		jal printString

		j endPrintTile
	

	# printBomb:
	# 	la $s3, bomb
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



.kdata
	s1: .word 0
	s2: .word 0

# modifying our exception Handler here
.ktext 0x80000180
	sw $v0, s1 					# Reloading v0 and a0 registers
	sw $a0, s2

	mfc0 $k0, $13				# Cause Register values Stored
	andi $a0, $k0, 0x0800  		# Get the 11 byte value 
	srl $a0, $a0, 11			# Get the value stored at 11 to byte 1 position
	bgtz $a0, Keyboard
	 			# if value more than zero hence keyboard interuption happened
	# mfc0 $k0, $13
	# andi $a0, $k0, 0x8000 		# Get the 15 byte value to check if timer interrupt happening
	# srl $a0, $a0, 15			# shifting the value to the right to get the value at 15 position 
	# bgtz $a0, Timer 			# If value greater than zero then timer interrupt happened


Keyboard:
	lw $s3, 0xffff0004			# Checking what keyboard value was entered and storing it in s3
	beq $s3, 0x50, moveDown		# If value equal to 'q' then go to JumpM

	mtc0 $0, $13				# Clearing Cause Register
	lw $v0, s1 					# Restoring v0 and a0 values
	lw $a0, s2				
	eret						# escape to main program

moveDown:
	la $s0, cursorRow 		# Making s4 -ve cause in future if the s4 value is negative then it directly quits
	addi $s0, $s0, 1
	sw $s0, newCursorRow

	mtc0 $0, $13 
	lw $v0, s1
	lw $a0, s2

	eret

Timer:
	addi $t0, $t0, -1 			# decreasing the Second time by 1 so that when recomputes the entire value it computes it 1 second less value
	addi $s4, $s4, 1			# increasing value of s4 to make positive so in future if value greater than zero it computes the entire thing
	mtc0 $0, $13 			
	lw $v0, s1
	lw $a0, s2

	eret

.text
main:
	jal updateCursor
	# to enable interupt we need to enable status register
	# interupts are when press q or reach 00:00
	mfc0 $k0, $12   		# enabling Status Register
	ori $k0, 0x8801 		# initializing the 1st 11th and 15 th values
	mtc0 $k0, $12			# Clearing the Register

	# enable keyboard control
	lw $s2, 0xffff0000 		# Enabling the Keyboard Control
	ori $s2, $s2, 0x02
	sw $s2, 0xffff0000 