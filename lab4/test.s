#
# CMPUT 229 Public Materials License
# Version 1.1
#
# Copyright 2017 University of Alberta
# Copyright 2017 Austin Crapo
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. 
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
# 
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
######################
#
# Implementation of Minesweeper using GLIM
# 
# Implements the __start label, which gathers user input that defines
# the following information for the creation of the game board:
# - how many rows and columns the game board should have;
# - how many bombs the board should have;
# - what random seed to use when placing them.
#
# All these parameters are positive integers.
#
# It then places those bombs randomly, ensures that all tiles
# are in their 'covered' and 'unmarked' state, and prints the board
# to the terminal. It is at this point it then passes control
# over to the main method. Throughout this procedure it uses
# some student functions to achieve these results - to see which
# procedures require which student functions to be implemented
# please see the __start label header comment.
#
######################
.data
tile:
	.asciiz "█"
marked:
	.asciiz "●"
has0:
	.asciiz " "
has1:
	.asciiz "1"
has2:
	.asciiz "2"
has3:
	.asciiz "3"
has4:
	.asciiz "4"
has5:
	.asciiz "5"
has6:
	.asciiz "6"
has7:
	.asciiz "7"
has8:
	.asciiz "8"
bomb:
	.asciiz "∅"
prompt1:
	.asciiz "Number of rows for this session: "
prompt2:
	.asciiz "Number of columns for this session: "
prompt3:
	.asciiz "Random seed to use: "
prompt4:
	.asciiz "Number of bombs for this session: "
gameBoard:
	.align 2
	.space 800
gameRows:
	.space 4
gameCols:
	.space 4
totalBombs:
	.space 4
gameLost:
	.asciiz "You LOSE!"
gameWon:
	.asciiz "You WIN!"
	.align 2

.text
.globl __start
__start:
	########################################################################
	# The default exception handler has a __start label that SPIM looks for
	# when starting the execution of a program. In this custom exception
	# handler the code at this  __start label first sets up the game and
	# then calls the main function.
	#
	# This function performs the following tasks:
	#
	# - gathers, through MIPS syscalls, user input to define the size of
	#   the game board, the number of bombs, and the random seed that
	#   will be used to position the bombs on the board. All these input
	#   parameters are integer values.
	#
	# - clears all variables, using fillRand to place hidden bombs in
	#   random board positions.
	#   (hasBomb and setBomb must be implemented)
	#
	# - calls prepareBoard  to cover all the tiles on the board.
	#   (prepareBoard must be implemented)
	#
	# - prints the initial state of the board
	#   (printTile must be implemented)
	#
	# - passes control to main
	#
	# Depending on main's return value, the program will either quit,
	# or loop, repeating the entire above procedure.
	#
	# Register Usage:
	# $s0 = stores the number of Rows user has requested
	# $s1 = stores the number of Columns user has requested
	# $s2 = used as a row scanner when printing
	# $s3 = used as a column scanner when printing
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)         # Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi    $sp, $sp, -20		# Adjust stack to save variables
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)
	sw      $s2, -16($fp)
	sw      $s3, -20($fp)
	
	
	startGame:
	
	##read the display size
	#Rows
	li      $v0, 4
	la      $a0, prompt1
	syscall
	li      $v0, 5
	syscall
	move	$s0, $v0
	#Cols
	li      $v0, 4
	la      $a0, prompt2
	syscall
	li      $v0, 5
	syscall
	move	$s1, $v0
	
	#Set the relevant screen data
	la      $t0, gameRows
	sw      $s0, 0($t0)
	la      $t0, gameCols
	sw      $s1, 0($t0)
		
	#Read and set random seed
	li      $v0, 4
	la      $a0, prompt3
	syscall
	li      $v0, 5
	syscall
	move	$a0, $v0
	jal	randInitialize
	
	#Read and set the number of bombs
	li      $v0, 4
	la      $a0, prompt4
	syscall
	li      $v0, 5
	syscall
	la      $t0, totalBombs
	sw      $v0, 0($t0)
	
	
	
	#Clear the entire board and all cursor variables
	li      $t0, 0
	la      $t1, gameBoard
	addi	$t2, $t1, 800		# CONSTANT, the max size of the game board is 800 bytes
	loopClear:
		beq     $t1, $t2, lCend
		sw      $t0, 0($t1)
		addi	$t1, $t1, 4
		j	loopClear
	lCend:
	
	#Clear all the cursor vairables
	la      $t1, cursorRow
	sw      $zero, 0($t1)
	la      $t1, cursorCol
	sw      $zero, 0($t1)
	la      $t1, newCursorRow
	sw      $zero, 0($t1)
	la      $t1, newCursorCol
	sw      $zero, 0($t1)
		
	
	#Place bombs randomly
	move	$a0, $v0
	li      $a1, 1
	jal     fillRand
	
	
	
	
	#Start up the GLIM display
	addi	$a0, $s0, 1
	move	$a1, $s1
	jal     startGLIM
	
	#covers all the tiles in a board
	jal     prepareBoard
	
	#Print the entire board
	li      $s2, 0		#rows
	li      $s3, 0		#cols
	
	loopFill:
        beq     $s2, $s0, lFend	#if rows == gameRows; break
		move	$a0, $s2
		move	$a1, $s3
		jal     printTile
		lFcont:
		addi	$s3, $s3, 1
		bne     $s3, $s1, loopFill	#if cols != gameCols; continue
		addi	$s2, $s2, 1
		li      $s3, 0
		j       loopFill
	lFend:
	
	jal	main
	
	move        $s0, $v0


	#MUST BE CALLED BEFORE ENDING PROGRAM
	#Restores as much as it can and sets the window to a good size
	jal	endGLIM
	
	move    $v0, $s0
	bne     $v0, $zero, startGame
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	addi	$sp, $sp, 20
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	
	li      $v0, 10
	syscall


.data
cursorRow:
	.space 4
cursorCol:
	.space 4
newCursorRow:
	.space 4
newCursorCol:
	.space 4
.text
updateCursor:
	########################################################################
	# Compares the new cursor value to the current cursor value, then 
	# updates accordingly the screen. After this function is called, 
	# and cursorCol contain the current cursor coordinates.
	#
	# Does not operate on inputs, only the memory addresses
	# newCursorRow, newCursorCol, cursorRow, cursorCol
	#
	#
	# Register Usage
	# 
	# $s0 = newCursorRow storage
	# $s1 = newCursorCol storage
	# $s2 = cursorRow storage
	# $s3 = cursorCol storage
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)			# Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -20		# Adjust stack to save variables
	sw      $ra, -4($fp)		# Save $ra
	sw      $s0, -8($fp)		# Save $s0
	sw      $s1, -12($fp)		# Save $s1
	sw      $s2, -16($fp)		# Save $s2
	sw      $s3, -20($fp)
	
	la      $s0, newCursorRow
	la      $s1, newCursorCol
	la      $s2, cursorRow
	la      $s3, cursorCol
	
	#get the state of the old position
	lw      $a0, 0($s2)
	lw      $a1, 0($s3)
	jal     getTile
	
	#redraw the old position tile
	move	$a0, $v0
	lw      $a1, 0($s2)
	lw      $a2, 0($s3)
	jal     printString
	uColdDone:
	
	#update the cursor pointer position
	lw      $t0, 0($s0)
	sw      $t0, 0($s2)
	lw      $t0, 0($s1)
	sw      $t0, 0($s3)
	
	#set the color to show the cursor pointer
	li      $a0	9
	li      $a1	0
	jal     setColor
	li      $a0	14
	li      $a1	1
	jal     setColor
	
	#get the state of the new position
	lw      $a0, 0($s2)
	lw      $a1, 0($s3)
	jal     getTile
	
	#print the state of the new position with the pointer color
	move	$a0, $v0
	lw      $a1, 0($s2)
	lw      $a2, 0($s3)
	jal     printString
	
	#restore the color
	jal     restoreSettings
	
	
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	addi	$sp, $sp, 20
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra


.data
seeds:
	.word 0x75BD0F7, 0x4975CCA9, 0x75BCF8F, 0xBC11F3, 0x4975CDBF, 0x75BCEC3, 0xBC1095, 0x4975CEA1
	#The number of seeds in this list should be updated in the function
multiplier:
	.word 0xBE1761D
multiplicand:
	.word 0x0
.text
randInitialize:
	########################################################################
	# Initialize the random function to a specific value from a list
	# of suitable seeds. The seeds must be chosen as large primes because
	# this is using the linear congruence algorithm.
	# Since the seeds must be pre-chosen, we allocate a list and then
	# force the users' choices to fall into that list of seeds.
	# 
	# $a0 = seed
	#
	########################################################################
	la      $t0, seeds
	li      $t1, 7	#the number of seeds in the list, update if you add
	div     $a0, $t1
	mfhi	$a0
	sll     $a0, $a0, 2
	add     $t0, $t0, $a0
	lw      $t0, 0($t0)
	
	la      $t1, multiplicand
	sw      $t0, 0($t1)
	
	jr      $ra
	
randInt:
	########################################################################
	# Produces a random bit each time it is called. Uses a modulo to
	# determine a maximum value.
	#
	# $a0 = exclusive max value
	#
	# Returns
	# $v0 = x, where 0 <= x < $a0
 	#
	# Register Usage
	# $t0 = memory address multiplier
	# $t1 = memory address multiplicand
	# $t2 = value multiplier
	# $t3 = value multiplicand
	########################################################################
	la      $t0, multiplier
	la      $t1, multiplicand
	lw      $t2, 0($t0)
	lw      $t3, 0($t1)
	
	multu	$t2, $t3
	mfhi	$v0
	mflo	$t2
	sw      $t2, 0($t1)

	divu	$v0, $a0
	mfhi	$v0
	
	jr      $ra
	
fillRand:
	########################################################################
	# Randomly fills the board with the specified number of bombs. Moves
	# about the board in random directions waiting to get a 1 bit randomly
	# and then places the bomb, if the square already has a bomb, it will
	# make a decision based on it's "ensured" value. If "ensured" - it will
	# keep moving until it finds a place for the bomb, if not "ensured" it
	# will move on and the resulting board will have 1 less bomb than asked
	# for. Uses the student implemented functions hasBomb and setBomb to
	# properly achieve this result.
	# 
	# $a0 = # of desired bombs to fill the board with.
	# $a1 = 1 if "ensured", 0 if not "ensured"
	#
	# Register Usage
	# $s0 = row scanner
	# $s1 = column scanner
	# $s2 = gameRows storage
	# $s3 = gameCols storage
	# $s4 = Counter to 0 for how many bombs are left to place
	# $s5 = storage for $a1
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)			# Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -28		# Adjust stack to save variables
	sw      $ra, -4($fp)		# Save $ra
	sw      $s0, -8($fp)		# Save $s0
	sw      $s1, -12($fp)		# Save $s1
	sw      $s2, -16($fp)		# Save $s2
	sw      $s3, -20($fp)
	sw      $s4, -24($fp)
	sw      $s5, -28($fp)
	
	li      $s0, 0	#row
	li      $s1, 0	#col
	la      $s2, gameRows
	lw      $s2, 0($s2)	#gameRows
	la      $s3, gameCols
	lw      $s3, 0($s3)	#gameCols
	move	$s4, $a0	#bombsLeft
	move	$s5, $a1	#ensured
	fRloop:
        beq     $s4, $zero, fRlend	#if bombsLeft == 0; break
		move	$a0, $s2		#generate rand row
		jal     randInt
		move	$s0, $v0
		
		move	$a0, $s3		#generate rand col
		jal     randInt
		move	$s1, $v0

		fRlmoveEnd:
		#at this point we are at a new position, 
		#we now determine if we should set a bomb
		li      $a0, 2
		jal     randInt
		beq     $v0, $zero, fRlcont	#if rand == 0; continue
		#else; set bomb
		
		#first we check if a bomb is already there
		move	$a0, $s0
		move	$a1, $s1
		jal     hasBomb
		
		beq     $v0, $zero, fRlsetBomb	#if tile == bomb, then we need to check if we are ensured
		beq     $s5, $zero, fRlsetBomb	#if ensured
			j	fRlcont			#then continue because this bomb doesn't count
		fRlsetBomb:
		addi	$s4, $s4, -1
		move	$a0, $s0
		move	$a1, $s1
		jal	setBomb
		
		fRlcont:
		j       fRloop
	fRlend:
	
	
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	lw      $s4, -24($fp)
	lw      $s5, -28($fp)
	addi	$sp, $sp, 28
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	
##############################################################################
#					START OF GLIM
##############################################################################
######################
#Author: Austin Crapo
#Date: June 2017
#Version: 2017.6.30
#
#
# Does not support being run in a tab; Requires a separate window.
#
# Currently printing to negative values does not print. Printing to
# offscreen pixels in the positive directions prints to last pixel
# available on the screen in that direction.
#
#This is a graphics library, supporting drawing pixels, 
# and some basic primitives
#
# High Level documentation is provided in the index.html file.
# Per-method documentation is provided in the block comment 
# following each function definition
######################
.data
.align 2
clearScreenCmd:
	.byte 0x1b, 0x5b, 0x32, 0x4a, 0x00
.text
clearScreen:
	########################################################################
	# Uses xfce4-terminal escape sequence to clear the screen
	#
	# Register Usage
	# Overwrites $v0 and $a0 during operation
	########################################################################
	li      $v0, 4
	la      $a0, clearScreenCmd
	syscall
	
	jr	$ra

.data
setCstring:
	.byte 0x1b, 0x5b, 0x30, 0x30, 0x30, 0x3b, 0x30, 0x30, 0x30, 0x48, 0x00
.text
setCursor:
	########################################################################
	#Moves the cursor to the specified location on the screen. Max location
	# is 3 digits for row number, and 3 digits for column number. (row, col)
	#
	# $a0 = row number to move to
	# $a1 = col number to move to
	#
	# Register Usage
	# Overwrites $v0 and $a0 during operation
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)		# Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -12		# Adjust stack to save variables
	sw      $ra, -4($fp)		# Save $ra
	#skip $s0, this could be cleaned up
	sw      $s1, -8($fp)
	sw      $s2, -12($fp)
	
	#The control sequence we need is "\x1b[$a1;$a2H" where "\x1b"
	#is xfce4-terminal's method of passing the hex value for the ESC key.
	#This moves the cursor to the position, where we can then print.
	
	#The command is preset in memory, with triple zeros as placeholders
	#for the char coords. We translate the args to decimal chars and edit
	# the command string, then print
	
	move	$s1, $a0
	move	$s2, $a1
	
	li      $t0, 0x30	#'0' in ascii, we add according to the number
	#separate the three digits of the passed in number
	#1's = x%10
	#10's = x%100 - x%10
	#100's = x - x$100
	
	# NOTE: we add 1 to each coordinate because we want (0,0) to be the top
	# left corner of the screen, but most terminals define (1,1) as top left
	#ROW
	addi	$a0, $s1, 1
	la      $t2, setCstring
	jal     intToChar
	lb      $t0, 0($v0)
	sb      $t0, 4($t2)
	lb      $t0, 1($v0)
	sb      $t0, 3($t2)
	lb      $t0, 2($v0)
	sb      $t0, 2($t2)
	
	#COL
	addi	$a0, $s2, 1
	la      $t2, setCstring
	jal     intToChar
	lb      $t0, 0($v0)
	sb      $t0, 8($t2)
	lb      $t0, 1($v0)
	sb      $t0, 7($t2)
	lb      $t0, 2($v0)
	sb      $t0, 6($t2)

	#move the cursor
	li      $v0, 4
	la      $a0, setCstring
	syscall
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s1, -8($fp)
	lw      $s2, -12($fp)
	addi	$sp, $sp, 12
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	
	jr      $ra

.text
printString:
	########################################################################
	# Prints the specified null-terminated string started at the
	# specified location to the string and then continues until
	# the end of the string, according to the printing preferences of your
	# terminal (standard terminals print left to right, top to bottom).
	#
	# It is not screen aware. Therefore, paramaters that would print a character
	# off screen have undefined effects on your terminal window. For most
	# terminals the cursor will wrap around to the next row and continue
	# printing. If you have hit the bottom of the terminal window,
	# the xfce4-terminal window default behavior is to scroll the window 
	# down. This can offset your screen without you knowing and is 
	# dangerous since it is undetectable.
	#
	# The most likely use of this
	# function is to print characters. The function expects a string
	# prints so that it can support the printing of escape character sequences
	# around the character. Escape character sequences enable fancy effects.
	#
	# Some other
	# terminals may treat the boundaries of the terminal window different.
	# For example, some may not wrap or scroll. It is up to the user to
	# test their terminal window to finde the default behaviour.
	#
	# printString is built for xfce4-terminal.
	# Position (0, 0) is defined as the top left of the terminal.
	#
	# $a0 = address of string to print
	# $a1 = integer value 0-999, row to print to (y position)
	# $a2 = integer value 0-999, col to print to (x position)
	#
	# Register Usage
	# $t0 - $t3, $t7-$t9 = temp storage of bytes and values
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)         # Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -8		# Adjust stack to save variables
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	
	move	$s0, $a0
	
	move	$a0, $a1
	move	$a1, $a2
	jal     setCursor
	
	#print the char
	li      $v0, 4
	move	$a0, $s0
	syscall
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	addi	$sp, $sp, 8
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra

batchPrint:
	########################################################################
	# A batch is a list of print jobs. The print jobs are in the format
	# below, and will be printed from start to finish. This function does
	# some basic optimization of color printing (eg. color changing codes
	# are not printed if they do not need to be), but if the list constantly
	# changes color and is not sorted by color, you may notice flickering.
	#
	# List format:
	# Each element contains the following words in order together
	# half words unsigned:[row] [col]
	# bytes unsigned:     [printing code] [foreground color] [background color] 
	#			    [empty] 
	# word: [address of string to print here]
	# total = 3 words
	#
	# The batch must be ended with the halfword sentinel: 0xFFFF
	#
	# Valid Printing codes:
	# 0 = skip printing
	# 1 = standard print, default terminal settings
	# 2 = print using foreground color
	# 3 = print using background color
	# 4 = print using all colors
	# 
	# xfce4-terminal supports the 256 color lookup table assignment, 
	# see the index for a list of color codes.
	#
	# The payload of each job in the list is the address of a string. 
	# Escape sequences for prettier or bolded printing supported by your
	# terminal can be included in the strings. However, including such 
	# escape sequences can effect not just this print, but also future 
	# prints for other GLIM methods.
	#
	# $a0 = address of batch list to print
	#
	# Register Usage
	# $s0 = scanner for the list
	# $s1 = store row info
	# $s2 = store column info
	# $s3 = store print code info
	# $s6 = temporary color info storage accross calls
	# $s7 = temporary color info storage accross calls
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -28		
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)
	sw      $s2, -16($fp)
	sw      $s3, -20($fp)
	sw      $s6, -24($fp)
	sw      $s7, -28($fp)
	
	#store the last known colors, to avoid un-needed printing
	li      $s6, -1		#lastFG = -1
	li      $s7, -1		#lastBG = -1
	
	
	move	$s0, $a0		#scanner = list
	#for item in list
	bPscan:
		#extract row and col to vars
		lhu     $s1, 0($s0)		#row
		lhu     $s2, 2($s0)		#col
		
		#if row is 0xFFFF: break
		li      $t0, 0xFFFF
		beq     $s1, $t0, bPsend
		
		#extract printing code
		lbu     $s3, 4($s0)		#print code
		
		#skip if printing code is 0
		beq     $s3, $zero, bPscont
		
		#print to match printing code if needed
		#if standard print, make sure to have clear color
		li      $t0, 1		#if pcode == 1
		beq     $s3, $t0, bPscCend
		bPsclearColor:
			li      $t0, -1	#if lastFG != -1
			bne     $s6, $t0, bPscCreset
			bne     $s7, $t0, bPscCreset	#OR lastBG != -1:
			j       bPscCend
			bPscCreset:
				jal     restoreSettings
				li      $s6, -1
				li      $s7, -1
		bPscCend:

		#change foreground color if needed
		li      $t0, 2		#if pcode == 2 or pcode == 4
		beq     $s3, $t0, bPFGColor
		li      $t0, 4
		beq     $s3, $t0, bPFGColor
		j       bPFCend
		bPFGColor:
			lbu     $t0, 5($s0)
			beq     $t0, $s6, bPFCend	#if color != lastFG
				move	$s6, $t0	#store to lastFG
				move	$a0, $t0	#set as FG color
				li      $a1, 1
				jal     setColor
		bPFCend:
		
		#change background color if needed
		li      $t0, 3		#if pcode == 2 or pcode == 4
		beq     $s3, $t0, bPBGColor
		li      $t0, 4
		beq     $s3, $t0, bPBGColor
		j       bPBCend
		bPBGColor:
			lbu     $t0, 6($s0)
			beq     $t0, $s7, bPBCend	#if color != lastBG
				move	$s7, $t0	#store to lastBG
				move	$a0, $t0	#set as BG color
				li      $a1, 0
				jal     setColor
		bPBCend:
		
		
		#then print string to (row, col)
		lw      $a0, 8($s0)
		move	$a1, $s1
		move	$a2, $s2
		jal     printString
		
		bPscont:
		addi	$s0, $s0, 12
		j       bPscan
	bPsend:

	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	lw      $s6, -24($fp)
	lw      $s7, -28($fp)
	addi	$sp, $sp, 28
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	
.data
.align 2
intToCharSpace:
	.space	4	#storing 4 bytes, only using 3, because of spacing.
.text
intToChar:
	########################################################################
	# Given an int x where 0 <= x <= 999, converts the integer into 3 bytes,
	# which are the character representation of the int. If the integer
	# requires larger than 3 chars to represent, only the 3 least 
	# significant digits will be converted.
	#
	# $a0 = integer to convert
	#
	# Return Values:
	# $v0 = address of the bytes, in the following order, 1's, 10's, 100's
	#
	# Register Usage
	# $t0-$t9 = temporary value storage
	########################################################################
	li	$t0, 0x30	#'0' in ascii, we add according to the number
	#separate the three digits of the passed in number
	#1's = x%10
	#10's = x%100 - x%10
	#100's = x - x$100
	la      $v0, intToCharSpace
	#ones
	li      $t1, 10
	div     $a0, $t1
	mfhi	$t7			#x%10
	add     $t1, $t0, $t7	#byte = 0x30 + x%10
	sb      $t1, 0($v0)
	#tens
	li      $t1, 100
	div     $a0, $t1
	mfhi	$t8			#x%100
	sub     $t1, $t8, $t7	#byte = 0x30 + (x%100 - x%10)/10
	li      $t3, 10
	div     $t1, $t3
	mflo	$t1
	add     $t1, $t0, $t1
	sb      $t1, 1($v0)
	#100s
	li      $t1, 1000
	div     $a0, $t1
	mfhi	$t9			#x%1000
	sub     $t1, $t9, $t8	#byte = 0x30 + (x%1000 - x%100)/100
	li      $t3, 100
	div     $t1, $t3
	mflo	$t1
	add     $t1, $t0, $t1
	sb      $t1, 2($v0)
	jr      $ra
	
.data
.align 2
setFGorBG:
	.byte 0x1b, 0x5b, 0x34, 0x38, 0x3b, 0x35, 0x3b, 0x30, 0x30, 0x30, 0x6d, 0x00
.text
setColor:
	########################################################################
	# Prints the escape sequence that sets the color of the text to the
	# color specified.
	# 
	# xfce4-terminal supports the 256 color lookup table assignment, 
	# see the index for a list of color codes.
	#
	#
	# $a0 = color code (see index)
	# $a1 = 0 if setting background, 1 if setting foreground
	#
	# Register Usage
	# $s0 = temporary arguement storage accross calls
	# $s1 = temporary arguement storage accross calls
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -12		
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)

	move	$s0, $a0
	move	$s1, $a1

	jal     intToChar		#get the digits of the color code to print
	
	move	$a0, $s0
	move	$a1, $s1
	
	la      $t0, setFGorBG
	lb      $t1, 0($v0)		#alter the string to print
	sb      $t1, 9($t0)
	lb      $t1, 1($v0)
	sb      $t1, 8($t0)
	lb      $t1, 2($v0)
	sb      $t1, 7($t0)
	
	beq     $a1, $zero, sCsetBG	#set the code to print FG or BG
		#setting FG
		li      $t1, 0x33
		j       sCset
	sCsetBG:
		li      $t1, 0x34
	sCset:
		sb      $t1, 2($t0)
	
	li      $v0, 4
	move	$a0, $t0
	syscall
		
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	addi	$sp, $sp, 12
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

.data
.align 2
rSstring:
	.byte 0x1b, 0x5b, 0x30, 0x6d, 0x00
.text
restoreSettings:
	########################################################################
	# Prints the escape sequence that restores all default color settings to
	# the terminal
	#
	# Register Usage
	# NA
	########################################################################
	la      $a0, rSstring
	li      $v0, 4
	syscall
	
	jr      $ra

.text
startGLIM:
	########################################################################
	# Sets up the display in order to provide
	# a stable environment. Call endGLIM when program is finished to return
	# to as many defaults and stable settings as possible.
	# Unfortunately screen size changes are not code-reversible, so endGLIM
	# will only return the screen to the hardcoded value of 24x80.
	#
	#
	# $a0 = number of rows to set the screen to
	# $a1 = number of cols to set the screen to
	#
	# Register Usage
	# NA
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -4		
	sw      $ra, -4($fp)
	
	jal     setDisplaySize
	jal     restoreSettings
	jal     clearScreen
	jal     hideCursor
	
	#Stack Restore
	lw      $ra, -4($fp)
	addi	$sp, $sp, 4
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	

.text
endGLIM:
	########################################################################
	# Reverts to default as many settings as it can, meant to end a program
	# that was started with startGLIM. The default terminal window in
	# xfce4-terminal is 24x80, so this is the assumed default we want to
	# return to.
	#
	# Register Usage
	# NA
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -4		
	sw      $ra, -4($fp)
	
	li      $a0, 24
	li      $a1, 80
	jal     setDisplaySize
	jal     restoreSettings
	jal     clearScreen
	jal     showCursor
	li      $a0, 0
	li      $a1, 0
	jal     setCursor
	
	#Stack Restore
	lw      $ra, -4($fp)
	addi	$sp, $sp, 4
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	
.data
.align 2
hCstring:
	.byte 0x1b, 0x5b, 0x3f, 0x32, 0x35, 0x6c, 0x00
.text
hideCursor:
	########################################################################
	# Prints the escape sequence that hides the cursor
	#
	# Register Usage
	# NA
	########################################################################
	la      $a0, hCstring
	li      $v0, 4
	syscall
	
	jr      $ra

.data
.align 2
sCstring:
	.byte 0x1b, 0x5b, 0x3f, 0x32, 0x35, 0x68, 0x00
.text
showCursor:
	########################################################################
	#Prints the escape sequence that restores the cursor visibility
	#
	# Register Usage
	# NA
	########################################################################
	la      $a0, sCstring
	li      $v0, 4
	syscall
	jr      $ra

.data
.align 2
sDSstring:
	.byte 0x1b, 0x5b, 0x38, 0x3b, 0x30, 0x30, 0x30, 0x3b, 0x30, 0x30, 0x30, 0x74 0x00
.text
setDisplaySize:
	########################################################################
	# Prints the escape sequence that changes the size of the display to 
	# match the parameters passed. The number of rows and cols are 
	# ints x and y s.t.:
	# 0<=x,y<=999
	#
	# $a0 = number of rows
	# $a1 = number of columns
	#
	# Register Usage
	# $s0 = temporary $a0 storage
	# $s1 = temporary $a1 storage
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -12		
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	#rows
	jal     intToChar		#get the digits of the params to print
	
	la      $t0, sDSstring
	lb      $t1, 0($v0)		#alter the string to print
	sb      $t1, 6($t0)
	lb      $t1, 1($v0)
	sb      $t1, 5($t0)
	lb      $t1, 2($v0)
	sb      $t1, 4($t0)
	
	#cols
	move	$a0, $s1
	jal     intToChar		#get the digits of the params to print
	
	la      $t0, sDSstring
	lb      $t1, 0($v0)		#alter the string to print
	sb      $t1, 10($t0)
	lb      $t1, 1($v0)
	sb      $t1, 9($t0)
	lb      $t1, 2($v0)
	sb      $t1, 8($t0)
	
	li      $v0, 4
	move	$a0, $t0
	syscall
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	addi	$sp, $sp, 12
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
##############################################################################
#					END OF GLIM
##############################################################################	
##############################################################################
#				STUDENT CODE BELOW THIS LINE
##############################################################################
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