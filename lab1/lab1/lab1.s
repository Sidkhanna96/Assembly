
# The following format is required for all submissions in CMPUT 229
#
# The following copyright notice does not apply to this file
# It is included here because it should be included in all
# solutions submitted by students.
#
#----------------------------------------------------------------
#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2017 Siddhant Khanna
#
# Redistribution is forbidden in all circumstances. Use of this software
# without explicit authorization from the author is prohibited.
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
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# Assignment:           1
# Due Date:             September 25, 2017
# Name:                 Siddhant Khanna
# Unix ID:              skhanna1
# Lecture Section:      A1
# Instructor:           J. Nelson Amaral
# Lab Section:          D01(1400-1700)
# Teaching Assistant:   Joe Johnson
#---------------------------------------------------------------

#---------------------------------------------------------------
# the calculator program has tokens of numbers in $a0, it takes
# each value from the stack(by incrementing the stack by 4) and 
# then load it in register $t0. We then put the value in stack
# $a1 and then perform the computations based on weather the 
# value passed is a operand or an operator. If operator then 
# the program pops the topmost 2 values and do the computation
# until we are passed a terminator(-3) in the stack which print
# the last rv emaining register in $a0
# 
# Inputs:
#       a0: Contains the operators and operands
#       a1: Stack, used for computation and storage
#		ra: return address
#
# Register Usage: 
#		t0: Store each token number from a0 into it
#		t1: contains the operator values
# 		t2: contains the topmost value when popping from stack
#		t3: contains the second topmost value in stack when popping
#		t4: conatins the final value
#		
#
#---------------------------------------------------------------





.data
	space: .asciiz "\n"
.text
calculator:

		lw $t0, 0($a0)		#Take the first value from tokenlist in input a0

		bgez $t0 PUSH		#Check if the number is an operand

		addi $t1 $zero -1	#check if token is PLUS
		beq $t0 $t1 PLUS	#jump to PLUS
		
		addi $t1 $zero -2 	#check if MINUS
		beq $t0 $t1 MINUS
		
		addi $t1 $zero -3	#check if want to terminate
		beq $t0 $t1 TERM
	
	INCREMENT:				#move on to next token
	
		addi $a0 $a0 4		# moving to next byte
		j calculator		#loop till reach the end of the tokens

PUSH:						#store in stack
	sw $t0 0($a1)			#Take token value and store in stack
	addi $a1 $a1 -4 		#move to next position of stack
	j INCREMENT

MINUS:						#pop and perform subtraction
	addi $a1 $a1 4			#move up the stack
	lw $t2 0($a1)			#get the topmost value
	addi $a1 $a1 4			#move up again on the stack
	lw $t3 0($a1)			#get the second topmost value

	sub $t0 $t3 $t2			#perform subtraction
	j PUSH

PLUS:						#pop and perform addition
	addi $a1 $a1 4			#move up the stack
	lw $t2 0($a1)			#load the topmost value
	addi $a1 $a1 4			#move up the stack
	lw $t3 0($a1)			#store the second topmost value

	add $t0 $t3 $t2			#perform addition
	j PUSH



TERM:						# got -3 hence termination-> print the value
	addi $a1 $a1 4			
	lw $t4 0($a1)			# load the final value

	li $v0 1				#print the final value
	add $a0 $zero $t4
	syscall

	#addi $v0 $zero 4
	#la $a0 space
	#syscall

	j Exit 					#exit to return address

Exit:
	jr $ra 					#exit the code