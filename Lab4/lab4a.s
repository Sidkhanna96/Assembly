#---------------------------------------------------------------
# Assignment:           4
# Due Date:             November 18, 2016
# Name:                 Alden Tan
# Unix ID:              aet
# Lecture Section:      A1
# Instructor:           Jose Nelson Amaral
# Lab Section:          D03 (Wednesday 1400 - 1650)
# Teaching Assistant:   Wanxin Gao
#---------------------------------------------------------------

#---------------------------------------------------------------
# This is the code for an interrupt handler and the main.
#
# Upon starting, the prompt "Seconds=" will display on screen
# and allow the user to enter digits proceeding to show them
# on screen. When the user presses enter a countdown timer will
# begin displaying in the following format: "mm:ss". The timer
# will update in-place and not keep printing across the line
# or down lines, as specified in the assignment. When "q" is 
# pressed or when the timer reaches 00:00, the application
# will quit as specified in the assignment. For all other 
# key presses, nothing will happen.
#---------------------------------------------------------------

.kdata
	s1: .word 0
	s2: .word 0

.ktext 0x80000180

	sw $v0 s1 # Reload a0 and v0
	sw $a0 s2
	
	li $v0,1 
	addi $a0, $zero, 1
	syscall
	
	mfc0 $k0 $13 # Get the cause register
	#andi $a0 $k0 0x0800
	#bgtz $a0 KEYBOARD
	andi $a0 $k0 0x8000
	bgtz $a0 TIMER
	lw $a0 0xffff0000  # Check the keyboard status
	andi $a0 $a0 0x01
	bnez $a0 KEYBOARD	

KEYBOARD:
	lw $s2 0xffff0004 # check if "q" is pressed 
	beq $s2 113 QUIT
	
	lw $v0 s1 #Restore other registers
	lw $a0 s2

	mtc0 $0 $13 # Clear Cause register
	
	eret

QUIT:
	addi $s0 $s0 -100 #make $s0 -100
	lw $v0 s1 #Restore other registers
	lw $a0 s2

	mtc0 $0 $13 # Clear Cause register
	
	eret

TIMER:
	addi $s0 $s0 1 #add 1 to $s0
	addi $t1 $t1 -1

	lw $v0 s1 #Restore other registers
	lw $a0 s2

	mtc0 $0 $13 # Clear Cause register
	
	eret
	
.data
	prompt: .asciiz "Seconds="

.text

	.globl __start
__start:

	mfc0 $k0 $12
	ori $k0 $k0 0x8001 #enable timer interrupt
	mtc0 $k0 $12

	lw    $t0 0xffff0000  # Enable Keyboard interrupts
	ori   $t0 $t0 0x02
	sw    $t0 0xffff0000

	li $v0 4 #printing "Seconds="
	la $a0 prompt
	syscall	

	li $v0 5 #taking the input number and storing it
	syscall
	add $t1 $v0 $zero

	j CLOCK

BACKSPACE1:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 BACKSPACE1 #checking if it's set or not
	sw $t9 0xffff000C #if display is ready, save to data register

BACKSPACE2:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 BACKSPACE2 #checking if it's set or not
	sw $t9 0xffff000C #if display is ready, save to data register

BACKSPACE3:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 BACKSPACE3 #checking if it's set or not
	sw $t9 0xffff000C #if display is ready, save to data register

BACKSPACE4:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 BACKSPACE4 #checking if it's set or not
	sw $t9 0xffff000C #if display is ready, save to data register

BACKSPACE5:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 BACKSPACE5 #checking if it's set or not
	sw $t9 0xffff000C #if display is ready, save to data register

CLOCK:	
	beq $t1 0 END
	addi $t9 $zero 60

	div $t1 $t9
	mflo $t2 #minutes
	mfhi $t5 #seconds
	
	addi $t9 $zero 10

	div $t2 $t9
	mflo $t2 #minutes first digit
	addi $t2 $t2 48 #ascii conversion
	mfhi $t3 #minutes second digit
	addi $t3 $t3 48 #ascii conversion
	
	addi $t4 $zero 58 #colon

	div $t5 $t9
	mflo $t5 #seconds first digit
	addi $t5 $t5 48 #ascii conversion
	mfhi $t6 #seconds second digit
	addi $t6 $t6 48 #ascii conversion

POLL1:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 POLL1 #checking if it's set or not
	sw $t2 0xffff000C #if display is ready, save to data register

POLL2:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 POLL2 #checking if it's set or not
	sw $t3 0xffff000C #if display is ready, save to data register

POLL3:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 POLL3 #checking if it's set or not
	sw $t4 0xffff000C #if display is ready, save to data register

POLL4:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 POLL4 #checking if it's set or not
	sw $t5 0xffff000C #if display is ready, save to data register

POLL5:
	lw $t7 0xffff0008 #getting the display control register
	andi $t7 $t7 0x01 #getting the 0 bit
	beqz $t7 POLL5 #checking if it's set or not
	sw $t6 0xffff000C #if display is ready, save to data register

	addi $t9 $zero 8 #ascii for backspace
	
	addi $t0 $zero 100 #set timer to 1 second
	mtc0 $t0 $11
	addi $t0 $zero 0 #start timer
	mtc0 $t0 $9

	addi $s0 $zero 0 #make $s0 = 0

LOOP:
	bltz $s0 END #if $s0 < 0 then q has been pressed or timer ended
	bgtz $s0 BACKSPACE1 #if $s0 == 1 then 1 second has passed
	j LOOP

END:
	li $v0 10 #quit application
	syscall


	