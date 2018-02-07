#
# CMPUT 229 Public Materials License
# Version 1.0
#
# Copyright 2017 University of Alberta
# Copyright 2017 Kristen Newbury
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
#-------------------------------
# Lab- Reverse Polish Notation Calculator
#
# Author: Kristen Newbury
# Date: August 9 2017
#
# Adapted from:
# Control Flow Lab - Student Testbed
# Author: Taylor Lloyd
# Date: July 19, 2012
#
# This program reads a file and places it in memory
# and then jumps to the student code under the label "calculator" -
# which is responsible for printing the output.
#
#-------------------------------
.data
.align 2
inputStream:    #space for input sequence of tokens to be stored
.space 2048
noFileStr:
.asciiz "Couldn't open specified file.\n"
.align 2
stack:          #space for stack
.space 2048
stackBeginning: #beginning of the stack
.word 0
.text
main:

    lw	$a0 4($a1)	# Put the filename pointer into $a0
    li	$a1 0		# Read Only
    li	$a2 0		# No Mode Specified
    li	$v0 13		# Open File
    syscall
    bltz	$v0 main_err	# Negative means open failed

    move	$a0 $v0		#point at open file
    la	$a1 inputStream	# write into my binary space
    li	$a2 2048        # read a file of at max 2kb
    li	$v0 14          # Read File Syscall
    syscall

    la	$a0 inputStream	#supply pointers as arguments
    la  $a1 stackBeginning
    jal	calculator      #call the student subroutine/jump to code under the label 'calculator'

    j	main_done

main_err:
    la	$a0 noFileStr   #print error message in the event of an error when trying to read a file
    li	$v0 4
    syscall
main_done:

    li      $v0 10      #exit program syscall
    syscall
#-------------------end of common file-------------------------------------------------
.data
	space: .asciiz "\n"
.text
calculator:

		lw $t0, 0($a0)		#has the number we want

		bgez $t0 PUSH

		addi $t1 $zero -1
		beq $t0 $t1 PLUS
		
		addi $t1 $zero -2
		beq $t0 $t1 MINUS
		
		addi $t1 $zero -3
		beq $t0 $t1 TERM
	
	INCREMENT:
	
		addi $a0 $a0 4
		j calculator	#moving to next byte

PUSH:
	sw $t0 0($a1)
	addi $a1 $a1 -4 
	j INCREMENT

MINUS:
	addi $a1 $a1 4
	lw $t2 0($a1)
	addi $a1 $a1 4
	lw $t3 0($a1)

	sub $t0 $t3 $t2
	j PUSH

PLUS:
	addi $a1 $a1 4
	lw $t2 0($a1)
	addi $a1 $a1 4
	lw $t3 0($a1)

	add $t0 $t3 $t2
	j PUSH



TERM:
	addi $a1 $a1 4
	lw $t4 0($a1)

	li $v0 1
	add $a0 $zero $t4
	syscall

	#addi $v0 $zero 4
	#la $a0 space
	#syscall

	j Exit

Exit:
	jr $ra