.text
getTile:
	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	lbu $s0, 0($a0) 		#Row byte(3)
						#(Because Gameboard is Stored as byte array)
	
	lbu $s2, 0($a1)			#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s0	#Tile position

	la $s3, tile

	lw $v0, 0($s3)

.text
hasBomb:
	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	lbu $s0, 0($a0) 		#Row byte(3)
						#(Because Gameboard is Stored as byte array)
	
	lbu $s2, 0($a1)			#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s0	#Tile position
	
	#check if it is a Bomb
	andi $s1, $s1, 0x01		#getting the first bit
	beq $s1, 0x01, isBomb	
	li $v0, 0
	jr $ra

	isBomb:
		li $v0, 1
		jr $ra

.text
setBomb:
	#sets the tile to be a bomb
	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	lbu $s0, 0($a0) 		#Row byte(3)
						#(Because Gameboard is Stored as byte array)
	
	lbu $s2, 0($a1)			#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s0	#Tile position

	#setting it to a bomb (unrevealed ?)
	lbu $s3, 0x01 		#loading byte to s3
	sb $s1, 0($s3)		#putting the byte 1 at the position

	jr $ra

prepareBoard:
	jr $ra

printTile:
	#5x9
	#Get the Max Column
	la $s0, gameCols	#Max Col (addr)
	lw $s1, 0($s0)		#Max Col(9) (value)

	#Get the row/col values
	lbu $s0, 0($a0) 		#Row byte(3)
						#(Because Gameboard is Stored as byte array)
	
	lbu $s2, 0($a1)			#column byte position(4)

	#Getting the position of the tile
	mult $s0, $s1		#row*columnSize(3*9)
	mflo $s0
	add $s0, $s0, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board

	#Printing Tile
	
	la $s3, tile

	lw $a0, 0($s3)
	move $a2, $a1
	move $a1, $a0
	

.data

.kdata
	s1: .word 0
	s2: .word 0

# modifying our exception Handler here -> determine if keyboard or timer interrupt
.ktext 0x80000180
	move $k1, $at		#no idea what it does
	
	sw $v0, s1 			# Reloading v0 and a0 registers
	sw $a0, s2

	mfc0 $k0, $13				#Readinf from cause register to see the cause of problem
	andi $a0, $k0, 0x0800  		# Get the 11 byte value 
	srl $a0, $a0, 11			# Get the value stored at 11 to byte 1 position
	bgtz $a0, Keyboard
	 			# if value more than zero hence keyboard interuption happened

	mfc0 $k0, $13
	andi $a0, $k0, 0x8000 		# Get the 15 byte value to check if timer interrupt happening
	srl $a0, $a0, 15			# shifting the value to the right to get the value at 15 position 
	bgtz $a0, Timer 			# If value greater than zero then timer interrupt happened

keyboard:
	lw $s3, 0xffff0004			# Checking what keyboard value was entered and storing it in s3
	beq $s3, 0x71, quit		# If value equal to 'q' then go to JumpM
	beq $s3, 0x38, moveUp

	mtc0 $0, $13				# Clearing Cause Register
	lw $v0, s1 					# Restoring v0 and a0 values
	lw $a0, s2				
	
	eret						# escape to main program

moveUp:
	la $s1, cursorRow
	addi $s2, $s1, -1
	la $s0, newCursorRow
	sb $s2, 0($s0)

	mtc0 $0, $13 
	lw $v0, s1
	lw $a0, s2

	eret

quit:
	#Later - set the value of the timer to negative to abort the program

Timer:
	#later


.text
.globl __start
__start:

	#To enable Status Register interrupt($12) -> keyboard / timer
	mfc0 $k0, $12   		# enabling Status Register
	ori $k0, 0x8801 		# initializing the 1st 11th and 15th values
	mtc0 $k0, $12			# Clearing the Register

	# enable keyboard control
	lw $s2, 0xffff0000 		# Enabling the Keyboard Control
	ori $s2, $s2, 0x02
	sw $s2, 0xffff0000 