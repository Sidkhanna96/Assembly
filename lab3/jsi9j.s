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
# Lab- findLive
#
# Author: Kristen Newbury
# Date: June 9 2017
#
# Adapted from:
# Control Flow Lab - Student Testbed
# Author: Taylor Lloyd
# Date: July 19, 2012
#
#
#-------------------------------
.data
.align 2
binary:	  #These absolutely MUST be the first two data defined, for jump correction
.space 2052
noFileStr:
.asciiz "Couldn't open specified file.\n"
format:
.asciiz "\n"
space:
.asciiz " "
liveMessage:
.asciiz "The live registers: "
zero:
.asciiz "$0  "
at:
.asciiz "$at "
v0:
.asciiz "$v0 "
v1:
.asciiz "$v1 "
a0:
.asciiz "$a0 "
a1:
.asciiz "$a1 "
a2:
.asciiz "$a2 "
a3:
.asciiz "$a3 "
t0:
.asciiz "$t0 "
t1:
.asciiz "$t1 "
t2:
.asciiz "$t2 "
t3:
.asciiz "$t3 "
t4:
.asciiz "$t4 "
t5:
.asciiz "$t5 "
t6:
.asciiz "$t6 "
t7:
.asciiz "$t7 "
s0:
.asciiz "$s0 "
s1:
.asciiz "$s1 "
s2:
.asciiz "$s2 "
s3:
.asciiz "$s3 "
s4:
.asciiz "$s4 "
s5:
.asciiz "$s5 "
s6:
.asciiz "$s6 "
s7:
.asciiz "$s7 "
t8:
.asciiz "$t8 "
t9:
.asciiz "$t9 "

.text
main:

lw      $a0 4($a1)	# Put the filename pointer into $a0
li      $a1 0		# Read Only
li      $a2 0		# No Mode Specified
li      $v0 13		# Open File

syscall
bltz	$v0 main_err	# Negative means open failed

move	$a0 $v0		# point at open file
la      $a1 binary	# write into my binary space
li      $a2 2048	# read a file of at max 2kb
li      $v0 14		# Read File Syscall
syscall
la      $t0 binary
add     $t0 $t0 $v0	# point to end of binary space

li      $t1 0xFFFFFFFF	# place ending sentinel
sw      $t1 0($t0)

# fix all jump instructions
la      $t0 binary	# point at start of instructions
move	$t1 $t0
main_jumpFixLoop:
    lw      $t2 0($t0)
    srl     $t3 $t2 26	# primary opCode
    li      $t4 2       # 2 is the jump opcode
    beq     $t3 $t4 main_jumpFix
    li      $t4 3       # 3 is the jal opcode
    beq     $t3 $t4 main_jumpFix
    j		main_jfIncrem
    main_jumpFix:
    #Replace upper 10 bits of jump with binary address
    li      $t3 0xFC000FFF	# bitmask
    and     $t2 $t2 $t3		# clear bits
    la      $t4 binary
    srl     $t4 $t4 2		# align to instruction
    not     $t3 $t3
    and     $t4 $t4 $t3		# only get bits in field
    or      $t2 $t2 $t4		# combine back on the binary address
    addi    $t2 $t2 -9      # adjust for the first 9 lines
                            # when spim loads a program
    sw      $t2 0($t0)      # place the modified instruction
    main_jfIncrem:
    addi	$t0 $t0 4
    li      $t4 -1
    bne     $t2 $t4 main_jumpFixLoop

la      $a0 binary	#prepare pointers for assignment
jal     findLive
move    $a0 $v0 
jal     writeArray

j       main_done

main_err:
la      $a0 noFileStr
li      $v0 4
syscall
main_done:

li      $v0 10
syscall


#-----------------------------------------------------------
# writeArray writes out the live registers
# that have been gathered in a nice format
#
# input:
# $a0: the array to write out
#-----------------------------------------------------------

writeArray:

addi    $sp $sp -24
sw      $ra 0($sp)
sw      $s0 4($sp)
sw      $s1 8($sp)
sw      $s2 12($sp)
sw      $s3 16($sp)
sw      $s4 20($sp)

move    $s0 $a0
li      $s1 0xFFFFFFFF      # sentinel to look for, for end of array

writeArrayLoop:
    lw      $s2 0($s0)
    beq     $s2 $s1 writeArrayDone  # if array entry == -1 : done
    addi	$s0 $s0 4
    la      $a0 liveMessage     # print the generic live message
                                # for each entry in the array
    li      $v0 4
    syscall

    # Print the contents of the vector lists

    #iterate over each bit and print as needed
    li      $t2, 0                  # shamt = 0
    li      $t3, 32
    vLPbits:                        # while True
        beq     $t2, $t3, vLPbend	# if shamt = 32: break
        srlv	$t4, $s2, $t2       # bit = (word >> shamt) AND 0x1
        andi	$t4, $t4, 0x1
        beq     $t4, $zero, vLPbcont # if bit == 1
        la      $t4, zero
        addi	$t5, $zero, 5
        mult	$t5, $t2
        mflo	$t5
        add     $a0, $t4, $t5
        li      $v0, 4
        syscall
        la      $a0 space
        li      $v0 4
        syscall
        vLPbcont:
        addi	$t2, $t2, 1         # shamt = shamt + 1
        j       vLPbits
    vLPbend:
    la      $a0 format      #newline
    li      $v0 4
    syscall
    j       writeArrayLoop
writeArrayDone:
lw      $ra 0($sp)
lw      $s0 4($sp)
lw      $s1 8($sp)
lw      $s2 12($sp)
lw      $s3 16($sp)
lw      $s4 20($sp)
addi    $sp $sp 24
jr      $ra

#####---------  end of common file  ---------#####


.data
	visited: .space 4000 		#number of instruction*number of functions 
	allLiveRegs: .space 40  	#number of functions
	liveRegs: .space 4 			#word
	DeadStack: .space 4000 		#like visited(each instruction is branch)
	begAddr: .space 4

.text
findLive:
	move $t0, $a0 			# $t0 -> beginningAddressArg - $a0
	li $t1, 0				# ResultIndex = 0
	la $t4, allLiveRegs 	# allLiveRegs  stored in array
	la $t5, liveRegs 		# liveRegs - Live Registers 
	la $t6, DeadStack 		# DeadStack 
	
Loop:
	beq $t0, 0xFFFFFFF, END #end
	srl $t2, $t0, 26 		# Get OpCode
	bne $t2, 0x0011, NextInstruction # Checking if opcode is JA
	
	li $t3, 0 			# deadStackIndex = 0
	move $a1, $t3
	addi $t0, $t0, 4 	# Instruction right after jal
	move $a2, $t0
	jal gatherLiveRegs 	# Check if the currentPath is live 

	sll $t1, $t1, 2 	# 4*ResultIndex
	add $t4, $t4, $t1  	# allLiveRegs[resultIndex] ~ allLiveRegs + resultIndex
	lw $t5, 0($t4) 		# allLiveRegs[resultIndex] = liveRegs
	addi $t1, $t1, 1 	# resultIndex ++
	li $s0, 0
	sw $s0, 0($t6) 		# deadStack[0] = 0 
	addi $t5, $zero, 0 	# liveRegs = 0

	j NextInstruction

NextInstruction:
	addi $t0, $t0, 4 	#moving to next address
	j Loop

END:
	sll $t1, $t1, 2 	#allLiveRegs[resultIndex] = -1
	add $t4, $t4, $t1
	addi $t4, $zero, -1

	jr $ra


gatherLiveRegs:
	sub $t7, $a2, $a0 	#index = address-beginningAddress
	lw $s2, 0($a2) 		#instruction = load instruction from address
	sra $s3, $s2, 26 

	la $t8, visited    	#visited[index]
	sll $t9, $t7, 2
	add $s1, $t8, $t9 

	beq $s1, 0x0001, ChangeBack 	#visited[index] == 1
	beq $s3, 0x0000, ChangeBack 	#instruction == jr $ra

continue:

	addi $s0, $zero, 1
	sw $s0, 0($s1) 					#visited[index] = 1

	j updateLiveRegs
	###updateDead()

	sra $s4, $s2, 26  
	beq $s4, 0x0000, jumpInstruction
	beq $s4, 0x0002, jumpInstruction
	beq $s4, 0x0003, jumpInstruction
	beq $s4, 0x0001, branchInstruction
	beq $s4, 0x0004, branchInstruction
	beq $s4, 0x0005, branchInstruction
	beq $s4, 0x0006, branchInstruction
	beq $s4, 0x0007, branchInstruction

	addi $t0, $t0, 4
	j gatherLiveRegs

	addi $s0, $zero, 0
	sw $s0, 0($s1)

	jr $ra

ChangeBack:
	addi $s0, $zero, 0 	#visited[index] = 0	
	sw $s0, 0($s1)
	j continue

jumpInstruction:
	#target	
	addi $s6, $s2, 4
	lui $s7, 0xF000
	and $s7, $s7, $s6
	andi $s7, $s6, 0xF0000000

	andi $t2, $s2,0x03FFFFFF
	sll $t2, $t2, 2
	andi $t2, $t2, 0x03FFFFFF
	or $a2, $t2, $s7 	#target for jump

	addi $s0, $zero, 0
	sw $s0, 0($s1)  	#visited[index] = 0

	
	j gatherLiveRegs

branchInstruction:
	addi $t3, $t3, 1 	#deadStackIndex++

	sll $s5, s2, 16 	#lower 16 bits
	sra $s5, $s5, 14	#16 - 2 = sll 2
	addi $a2, $s5, 4	#target

	#### clone top of stack ?????
	j gatherLiveRegs
	addi $t3, $t3, -1 	#deadStackIndex--


########Remember to load and store registers.
updateLiveRegs:
#registers where values are used than defined
#beq instructions - follow different path
#calls dead to tell them which one is dead in the path
# need to know dead so that we do not create live registers 
	lw $t0, 0($s2)		#start instruction

	andi $t1, $t0, 0xFC000000 	#check if it is R/I type/ What is the instruction
	beq $t1, 0x00000000, checkJR
	bne $t1, 0x00000000, ITYPE

	
		
j continue2:

	addi $s2, $s2, 4 #move to next instruction

	sll $t2, $t0, 26 					#search for jr ra to see if code is end 
	beq $t2, 0x00000000, endInstruction

	j updateLiveRegs


ITYPE:
	srl $t1, $t1, 26
	#single register branch functions
	beq $t1, 0x00000001, rs
	beq $t1, 0x00000006, rs
	beq $t1, 0x00000007, rs
	#double register branch functions
	beq $t1, 0x00000004, NORMAL
	beq $t1, 0x00000005, NORMAL
	andi $t5, $t0, 0x001F0000 	#rt
	andi $t3, $t0, 0x03E00000 	#rs
	li $s0, 1
	j updateDead

rs:
 	andi $t3, $t0, 0x03E00000 	#rs
	li $s0, 1
	j cloneDeadStack

cloneDeadStack:
	lw $t9, 0($t6)
	addi $t6, $t6, 4	#move to next dead stack
	sw $t9, 0($t6) 		#cloning deadstack here path 1 use this dead stack



	j updateDead

checkJR:
	andi $t7, $t0, 0x000FFFF8
	bne $t7, 0x00000008, RTYPE

RTYPE:
	andi $t3, $t0, 0x03E00000 	#rs
	andi $t4, $t0, 0x001F0000 	#rt
	andi $t5, $t0, 0x0000F800 	#rd DEAD
	li $s0, 0
	j updateDead


updateDead:
	la $t6, DeadStack
	li $t8, 1
	sll $t5, $t5, 16
	srl $t5, $t5, 27 	#get the number  
	addi $t6, $t6, $t5	#Marking the dead
	sb $t8, 0($t6)
	sub $t6, $t6, $t5 	#going back to original position
	j markLive

markLive:
	la $t9, liveRegs
	li $t8, 1

	sll $t3, $t3, 6 		#rs
	srl $t3, $t3, 27
	addi $t9, $t9, $t3

	addi $t6, $t6, $t3  #checking the deadstack
	beq $t6, $t8, alreadyDead

	sb $t8, 0($t9)
	sub $t9, $t9, $t3	#going back to original position

	beq $s0, $t8, skip #checking if the instruction has a 
alreadyDead:

	addi $t6, $t6, $t4  #checking the deadstack
	beq $t6, $t8, skip

	
	sll $t4, $t4, 11 	#rt
	srl $t4, $t4, 27
	addi $t9, $t9, $t4
	sb $t8, 0($t9)
	sub $t9, $t9, $t4

skip:
	j continue2 
	