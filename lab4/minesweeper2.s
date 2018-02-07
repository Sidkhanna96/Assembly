#
# CMPUT 229 Student Submission License
# Version 1.0
#
# Copyright 2017 Siddhant Khanna
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
#          skhanna1@ualberta.ca
#


#########################################################################
	#Going through all the tiles and checking their first bit of
	# each byte to see if equal to 1, if it is then it is 
	# has a bomb
	#
	# Register Usage:
	# $s0 = getting the column values and then the row value
	# $s1 = storing the product of row time max column / Has the current
	# tile position
	# $s2 = has the row position
	# $s3 = checking if it is Bomb
	########################################################################
.text
hasBomb:
	addi $sp, $sp, -20 		#Saving Registers
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
	beq $s3, 0x01, isBomb	#checking if it is a bomb
	li $v0, 0

	j endHasBomb

	isBomb:
		li $v0, 1
	
		j endHasBomb

	endHasBomb:				#loading Registersr
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		addi $sp, $sp, 20

		jr $ra

#########################################################################
	# Setting bombs to tile, get the arguments for the tile position
	# calculate the position and then set the first bit 
	# to 1 of the tile
	#
	# Register Usage:
	# $s0 = getting the column values and then the row value
	# $s1 = storing the product of row time max column / Has the current
	# tile position
	# $s2 = has the row position
	# $s3 = setting its bomb
	########################################################################
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
	addi $sp, $sp, 20 		#loading Registers

	jr $ra

#########################################################################
	#Calculating the number of bombs around a tile, if it is not a 
	# bomb goes through each row near the selected tile
	# goes one step back and one step forward to 
	# check if it has a bomb
	#
	# Register Usage:
	# $s0 = getting the column values and then the row value
	# $s1 = storing the product of row time max column / Has the current
	# tile position
	# $s2 = has the row position
	# $s3 = checking if it is Bomb
	# $s7 = flag for checking if it has a bomb
	# $s6 = total number of bombs arounf the tile counter
	########################################################################

.text
prepareBoard:
	addi $sp, $sp, -36 	#saving Registers
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

#########################################################################
	# Get the state of the tile from the bits value
	# If not of the lower 4 bits have any value then 
	# we check if it has a bomb near it or not
	#
	# Register Usage:
	# $s0 = getting the column values and then the row value
	# $s1 = storing the product of row time max column / Has the current
	# tile position
	# $s2 = has the row position
	# $s7 = checking the bit 1 value
	# $v0 = returns the address of the string to be printed
	########################################################################
.text
getTile:
	addi $sp, $sp, -36 	#saving the registers
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

	lb $s4, 0($s1)

	lb $s7, 0($s1) 		#Has the byte value

	#getting the second and third bit is it revealed/flag
	move $s6, $s7
	sra $s6, $s6, 1 		#has the bit 1

	sra $s7, $s6, 1 		#bit 2
	andi $s7, $s7, 0x01 	#getting the flag value
	beq $s7, 1, flag 		#if value is equal to 1 print flag

	andi $s6, $s6, 0x01 	#checking the second bit value to check if it is a bomb
	beq $s6, 0, Tile

	andi $s7, $s4, 0x01    	#checking bit 1 value to see if a bomb
	beq $s7, 0x01, addrBomb	
	sra $s4, $s4, 4		#get the top part of the bits to see the number of bombs around it
	
 							
	beq $s4, 0x00, addr0	#Checking with the bit value for the top most 
	beq $s4, 0x01, addr1	#bits to see what values they have
	beq $s4, 0x02, addr2 	#this checks the number of bombs around a specific tile
	beq $s4, 0x03, addr3
	beq $s4, 0x04, addr4
	beq $s4, 0x05, addr5
	beq $s4, 0x06, addr6
	beq $s4, 0x07, addr7
	beq $s4, 0x08, addr8

	#checking what type of tile to print
	flag:  
		la $v0, marked 
		j endGetTile

	#print Tile
	Tile:
		la $v0, tile
		j endGetTile

	# print bomb
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
		addi $sp, $sp, 36 		#loading back Registers

		jr $ra


#########################################################################
	#Get the tile state and string address of the tile to be printed
	# from get tile
	#
	# Register Usage:
	# $a0 = string address
	# $a1 = row position
	# $a2 = column position
	# $v0 = String address 
	########################################################################
.text
printTile:
	addi $sp, $sp, -28
	sw $ra, 0($sp) 				#saving the registers
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)

	jal getTile


	default:

		move $s3, $v0 		#will have the address of the string to print
		move $a2, $a1 		#passing the arguments for printString
		move $a1, $a0
		move $a0, $s3
		
		jal printString 	#calling the printString function to print the values

		j endPrintTile
	

	endPrintTile:
		lw $ra, 0($sp)
		lw $s0, 4($sp) 		#loading the registers
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		addi $sp, $sp, 28
	
		jr $ra



#########################################################################
	#Gives the keyboard numbers and letters its functionality
	# enable interupts and in ktext and kdata and see if a 
	# keyboard interupt happen or not. We also calculate time.
	#
	# Register Usage:
	# $s0 = getting the column values and then the row value
	# $s1 = storing the product of row time max column / Has the current
	# tile position
	# $s2 = has the row position
	# $s3 = checking if it is Bomb
	# $t0- $t9 = registers used to store temporary values and assign value 
	# to flags
	########################################################################

.data
	.align 2
	digit1: .space 1
	.align 2
	digit2: .space 1
	.align 2
	digit3: .space 1
	.align 2
	digit1_2: .space 1
	.align 2
	digit2_2: .space 1
	.align 2
	digit3_2: .space 1

	.align 2
	flag1: .space 1
	.align 2
	skip: .space 1
	.align 2
	flag2: .space 2
	.align 2
	count: .space 4
	.align 2
	flag3: .space 4
.text
main:
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

	jal updateCursor 			#updating the cursor position

	# la $t5, gameRows
	# lw $t5, 0($t5)
	# la $t4, gameCols
	# lw $t4, 0($t4)
	# la $t6, totalBombs
	# lw $t6, 0($t6)

	# mult $t5, $t4
	# mflo $t5
	# sub $t6, $t5,$t6

	# beq $t6,  

	# to enable interupt we need to enable status register
	# interupts are when press q or reach 00:00
	mfc0 $k0, $12   		# enabling Status Register
	ori $k0, 0x0801 		# initializing the 1st and 15 th values
	mtc0 $k0, $12			# Clearing the Register

	# enable keyboard control
	lw $s2, 0xffff0000 		# Enabling the Keyboard Control
	ori $s2, $s2, 0x02
	sw $s2, 0xffff0000 	

	la $t9, flag3 			#if 1 second is passed it means the flag3 value is changed
	lw $t9, 0($t9)			#and we need to update the timer
	beq $t9, 1, changeTime


#checking what the keyboard value clicked is equal to what value
here: 
	beq $s0, 0x71, exit
	beq $s0, 0x72, reset
	beq $s0, 0x32, moveDown
	beq $s0, 0x34, moveLeft
	beq $s0, 0x36, moveRight
	beq $s0, 0x38, moveUp
	beq $s0, 0x37, markFlag
	beq $s0, 0x35, reveal
	j here				# stay here forever

exit:

	lw $ra, 0($sp)
	lw $s0, 4($sp) 			#loadingg theregisters back
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $s7, 32($sp)
	addi $sp, $sp, 36

	li $v0, 0				# exit,if it ever comes here 
	jr $ra 					#this situation occurs when the users clicks q

reset:
	# mfc0 $k0, $12   		# enabling Status Register
	# andi $k0, 0x0000 		# initializing the 1st and 15 th values
	# mtc0 $k0, $12			# Clearing the Register	

	la $t7, skip 			#when user selects r reset happens
	li $t8, 0
	sw $t8, 0($t7)

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp) 			#storing the stacks
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	lw $sp, 32($sp)
	addi $sp, $sp, 36

	li $v0, 1
	jr $ra	

reveal:
	la $t5, flag1 			#if the value of flag is 5 it means that the user
	lb $t6, 0($t5) 			#clicked the 5 keypad for the first time and hence we should
	beq $t6, 5, continueNormal	 #instantiate the counter otherwise go normal route

	# li $t5, 1

	mfc0 $k0, $12   		# enabling Status Register
	ori $k0, 0x8001 		# initializing the 1st and 15 th values
	mtc0 $k0, $12

	li $t8, 0    			#initializing the $9 registers
	mtc0 $t8, $9

	li $t8, 100 			#counter stops when equal to this value
	mtc0 $t8, $11

	la $t7, flag1 			#indicating that 5 has been pressed and hence will not go through 
	li $t8, 5 				#this again
	sb $t8, 0($t7) 
	# li $t7, 1
	j calculateTime 		#calculate how much time to give to the user

continueNormal:

	la $t7, skip 		#indicating that if the user lost then they cant reveal the tile
	lw $t7, 0($t7)
	beq $t7, 1, moveDown

	li $s0, 1
	la $s3, gameCols	#Max Col (addr)
	lw $s4, 0($s3)		#Max Col(9) (value)

	lw $s1, cursorRow
	lw $s2, cursorCol

	#Getting the position of the tile
	mult $s1, $s4		#row*columnSize(3*9)
	mflo $s3
	add $s3, $s3, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s3	#Tile position in the board

	#####putting the reveal ########
	lb $s2, 0($s1)
	ori $s2, 0x02
	#checking if it is a bomb
	andi $s6, $s2, 0x01
	bne $s6, 0x01, doNothing

code:	
	#this situation occurs when the user clicks on the bomb
	la $a1, gameRows 
	lw $a1, 0($a1)
	li $a2, 0
	la $a0, gameLost
	jal printString

	#Revealing the clicked tile
	sb $s2, 0($s1)
	
	#This is flag indicating that marked and reveal cannot be accessed again
	la $t7, skip
	li $t8, 1
	sb $t8, 0($t7)
	j main

doNothing:
	#if still playing the user reveal function performs its task
	# sb $s2, 0($s1)
	# move $s7, $s1
	# andi $s4, $s2, 0xF0
	# # beq $s4, 0x00, expandLeft
	# j main
	lb $s6, 0($s1) 			#Exiting the recursion and printing the last numbered value of
	ori $s6, 0x02 			#the tile
	sb $s6, 0($s1)
	j main

# expandLeft:
# 	beq $s1, 0, ending 			#For Expanding towards the left when the user clicks 
# 	addi $s1, $s1, -1 			#on a empty valued tile

# 	lb $s5, 0($s1) 				#has the byte of this address

# 	andi $s6, $s5, 0xF0 		#Checking how many bombs this tile has
# 	bgt $s6, 0x00, endLastVal
# 	lb $s6, 0($s1) 				#if it has no bombs the recursion keeps on moving
# 	ori $s6, 0x02 				#until we find a tile which has a number in it and then stops
# 	sb $s6, 0($s1)
# 	j expandLeft

# endLastVal:
# 	lb $s6, 0($s1) 			#Exiting the recursion and printing the last numbered value of
# 	ori $s6, 0x02 			#the tile
# 	sb $s6, 0($s1)

# 	move $s1, $s7
# ending:
# 	j expandRight 	#Performing the same task for the right side of empty tile

# expandRight:
# 	la $t6, gameCols 			#checking if the top 4 bits of the tile 
# 	lw $t6, 0($t6) 				#are in zero or not
# 	beq $s1, $t6, ending2
 
# 	addi $s1, $s1, 1 			#move to the tile next to it

# 	lb $s5, 0($s1) 				#has the byte of this address


# 	andi $s6, $s5, 0xF0 		#checking the top 4 bits
# 	bgt $s6, 0x00, endLastVal2 	
# 	lb $s6, 0($s1) 				# the value is passed hence it is empty
# 	ori $s6, 0x02
# 	sb $s6, 0($s1)
# 	j expandRight 				#recursion for right side of the tile

# endLastVal2:
# 	lb $s6, 0($s1) 		#printing the last tile of the recursion
# 	ori $s6, 0x02 		#this is either the last tile or a tile with some value in it
# 	sb $s6, 0($s1)
# 	move $s1, $s7

# ending2:
	
	j main 			#back to program


markFlag:
	
	la $t7, skip 			#skip this fucntion functionality if the user clicked on a bomvb
	lw $t7, 0($t7)
	beq $t7, 1, moveDown

	li $s0, 1
	la $s3, gameCols	#Max Col (addr)
	lw $s4, 0($s3)		#Max Col(9) (value)

	lw $s1, cursorRow
	lw $s2, cursorCol

	#Getting the position of the tile
	mult $s1, $s4		#row*columnSize(3*9)
	mflo $s3
	add $s3, $s3, $s2	#row*columnSize + col (3*9+4)

	la $s1, gameBoard 	#Get the address of the board
	
	add $s1, $s1, $s3	#Tile position in the board

	#####putting the flag ########
	lb $s2, 0($s1) 				#putting a 1 on the 3rd bit of the lower bits of the byte of tile
	andi $s7, $s2, 0x04  		#indicating it is flagged
	bne $s7, 0x04, createFlag 	#giving the functionality of unflagging a tile
	andi $s2, $s2, 0xfb
	sb $s2, 0($s1)
	j main

createFlag:
	lb $s2, 0($s1) 			#creating a flag if the tile is not already flagged
	ori $s2, $s2, 0x04
	sb $s2, 0($s1)
	# j timer
	j main

moveDown: 	
	li $s0, 1 				#giving the user the functionality of moving up
	lw $s1, cursorRow 		#getting the current poisition
	addi $s1, $s1, 1 		#decrementing the position of row to move down

	la $s2, gameRows 		
	lw $s2, 0($s2)
	addi $s2, $s2, -1
	bgt $s1, $s2, subtract 	#if the cursor reached the end do not call update cursor

	sw $s1, newCursorRow 	#calling update cursor to indicate its value
	jal updateCursor
	j here

moveUp:
	li $s0, 1 				#giving the user the functionality to move up
	lw $s1, cursorRow
	addi $s1, $s1, -1

	bltz $s1, addition 		#checking if not reached the top of the gameboard

	sw $s1, newCursorRow 	#updating the cursor
	jal updateCursor
	j here

moveLeft:
	li $s0, 1 				#giving the user the functionalitu to move left
	lw $s1, cursorCol
	addi $s1, $s1, -1

	bltz $s1, addition 		#checking if havent reached the end of the gameboard

	sw $s1, newCursorCol
	jal updateCursor
	j here

moveRight:
	li $s0, 1 				#giving the user the funcitonaltu to move to the right
	lw $s1, cursorCol
	addi $s1, $s1, 1
 
	la $s2, gameCols 			#checking if did not reach the end of right
	lw $s2, 0($s2)
	addi $s2, $s2, -1
	bgt $s1, $s2, subtract

	sw $s1, newCursorCol 		#updating the cursor
	jal updateCursor
	j here

subtract:
	addi $s1, $s1, -1 		#preventing the cursor from going of the board
	j here

addition:
	addi $s1, $s1, 1 #preventing the cursor from going of the board
	j here

calculateTime:
	#Calculating the timer
	la $s4, totalBombs		#total bombs
	lw $s4, 0($s4)
	la $s5, gameCols 		#calculating the time the user will get 
	lw $s5, 0($s5) 			#given the formula
	la $s6, gameRows
	lw $s6, 0($s6)

	mult $s5, $s6
	mflo $s5				#total number of tile
	sub $s5, $s5, $s4		#Empty tiles total

	li $s6, 888
	mult $s6, $s4
	mflo $s6 				#bombs * 888
	div $s6, $s5			#(bombs * 888)/E
	mflo $s6				

	bgt $s6, 5, max
	li $s6, 5

max:
	blt $s6, 999, elseVal 		#calculating time
	li $s6, 999

elseVal:
	la $t8, count 		#calculating time and pasting it into a flag
	sw $s6, 0($t8) 
	j timer

timer:
	li $t9, 0
	move $a0, $s6 				#Print the timer for the very first time
	jal intToChar
	
	lb $s5, 0($v0)
	lb $s6, 1($v0)
	lb $s7, 2($v0)

	dig1: 						#print the first digit seperately
		la $a1, gameRows 		#after calling intto char because doesn't work
		lw $a1, 0($a1) 			#for wentire number
		li $a2, 0

		la $t6, digit1
		sw $s7, 0($t6)
		move $a0, $t6
		jal printString

	dig2:
		la $a1, gameRows 		#print the second digit seperately
		lw $a1, 0($a1)			#after calling intto char because doesn't work
		li $a2, 1 				#for wentire number

		la $t6, digit2
		sw $s6, 0($t6)
		move $a0, $t6
		jal printString

	dig3:
		la $a1, gameRows 	#print the third digit seperately
		lw $a1, 0($a1) 		#after calling intto char because doesn't work
		li $a2, 2 			#for wentire number

		la $t6, digit3
		sw $s5, 0($t6)
		move $a0, $t6
		jal printString
	j continueNormal

changeTime:
 							
	la $t9, flag3 			#this updates the value
	li $t8, 0 				#this is the same as the timer function but
	sw $t8, 0($t9)

	la $t8, count 			#storing in the flag for updating after 1 second
	lw $s6, 0($t8)


	bgtz $s6, cont

	la $a1, gameRows 		#printing the number 
 	lw $a1, 0($a1)
 	li $a2, 0
 	la $a0, gameLost
 	jal printString

 	#change the 5 and 7 value
 	la $t7, skip
 	li $t8, 1
 	sb $t8, 0($t7)
 	j main

cont:

	move $a0, $s6
	jal intToChar 		#continuationg of changetime 
	
	lb $s5, 0($v0) 		#printing the digits seperately
	lb $s6, 1($v0)
	lb $s7, 2($v0)

	dig1_2: 			#printitng the first digit
		la $a1, gameRows
		lw $a1, 0($a1)
		li $a2, 0

		la $t6, digit1_2
		sw $s7, 0($t6)
		move $a0, $t6
		jal printString

	dig2_2: 			#printing the second digit
		la $a1, gameRows
		lw $a1, 0($a1)
		li $a2, 1

		la $t6, digit2_2
		sw $s6, 0($t6)
		move $a0, $t6
		jal printString

	dig3_2:
		la $a1, gameRows 	#printing the third digit
		lw $a1, 0($a1)
		li $a2, 2

		la $t6, digit3_2
		sw $s5, 0($t6)
		move $a0, $t6
		jal printString

	j main



.kdata
	s1: .word 0
	s2: .word 0
	s3: .word 0

# modifying our exception Handler here
.ktext 0x80000180
	sw $v0, s1 					# Reloading v0 and a0 registers
	sw $a0, s2

	mfc0 $k0, $13				# Cause Register values Stored
	andi $a0, $k0, 0x0800  		# Get the 11 byte value 
	srl $a0, $a0, 11			# Get the value stored at 11 to byte 1 position
	bgtz $a0, Keyboard
	 			# if value more than zero hence keyboard interuption happened

	mfc0 $k0, $13
	andi $a0, $k0, 0x8000 		# Get the 15 byte value to check if timer interrupt happening
	srl $a0, $a0, 15			# shifting the value to the right to get the value at 15 position 
	bgtz $a0, Timing 			# If value greater than zero then timer interrupt happened

Keyboard:
	lw $s0, 0xffff0004			# Checking what keyboard value was entered and storing it in s3

	mtc0 $0, $13				# Clearing Cause Register
	lw $v0, s1 					# Restoring v0 and a0 values
	lw $a0, s2				
	eret						# escape to main program

Timing:
	li $t8, 0
	mtc0 $t8, $9

	la $t9, flag3
	li $s4, 1
	sw $s4, 0($t9)

	la $s6, count
	lw $s7, 0($s6)
	addi $s7, $s7, -1 			#decreasing the number we got
	sw $s7, 0($s6)

	mtc0 $0, $13				# Clearing Cause Register
	lw $v0, s1 					# Restoring v0 and a0 values
	lw $a0, s2				
	eret						# escape to main program