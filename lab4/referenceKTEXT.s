.kdata					# kernel data
s1:	.word 10
s2:	.word 11

new_line: 
	.asciiz "\n"

	.text
	.globl main
main:
	mfc0 $a0, $12			# read from the status register
	ori $a0, 0xff11			# enable all interrupts
	mtc0 $a0, $12			# write back to the status register

	lui $t0, 0xFFFF			# $t0 = 0xFFFF0000;
	ori $a0, $0, 2				# enable keyboard interrupt
	sw $a0, 0($t0)			# write back to 0xFFFF0000;
		
here: 
	j here				# stay here forever
	
	li $v0, 10				# exit,if it ever comes here
	syscall


.ktext 0x80000180				# kernel code starts here
	
	.set noat				# tell the assembler not to use $at, not needed here actually, just to illustrae the use of the .set noat
	move $k1, $at			# save $at. User prorams are not supposed to touch $k0 and $k1 
	.set at				# tell the assembler okay to use $at
	
	sw $v0, s1				# We need to use these registers
	sw $a0, s2				# not using the stack because the interrupt might be triggered by a memory reference 
					# using a bad value of the stack pointer

	mfc0 $k0, $13			# Cause register
	srl $a0, $k0, 2				# Extract ExcCode Field
	andi $a0, $a0, 0x1f

    bne $a0, $zero, kdone			# Exception Code 0 is I/O. Only processing I/O here

	lui $v0, 0xFFFF			# $t0 = 0xFFFF0000;
	lw $a0, 4($v0)			# get the input key
	li $v0,1				# print it here. 
					# Note: interrupt routine should return very fast, so doing something like 
					# print is NOT a good practice, actually!
	syscall

	li $v0,4				# print the new line
	la $a0, new_line
	syscall

kdone:
	mtc0 $0, $13				# Clear Cause register
	mfc0 $k0, $12			# Set Status register
	andi $k0, 0xfffd			# clear EXL bit
	ori  $k0, 0x11				# Interrupts enabled
	mtc0 $k0, $12			# write back to status

	lw $v0, s1				# Restore other registers
	lw $a0, s2

	.set noat				# tell the assembler not to use $at
	move $at, $k1			# Restore $at
	.set at					# tell the assembler okay to use $at

	eret					# return to EPC


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.kdata
	s1: .word 0
	s2: .word 0

.ktext 0x80000180 				# modifying our exception Handler here
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
	li $v0, 1
	syscall
	eret						# escape to main program

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

infinite:
	beq $s3, 0x36, moveDown		# If value equal to 'q' then go to JumpM
	j infinite

	li $v0, 10
	syscall

moveDown:
	la $s0, cursorRow 		# Making s4 -ve cause in future if the s4 value is negative then it directly quits
	addi $s0, $s0, 1
	sw $s0, newCursorRow
	j infinite