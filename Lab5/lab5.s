#-------------------------------
# Control Flow Lab - Student Testbed
# Author: Taylor Lloyd
# Date: July 19, 2012
#
#-------------------------------
.data
	.align 2
binary:  #Absolutely MUST be the first data defined, for jump correction
	.space 2052
noFileStr:
	.asciiz "Couldn't open specified file.\n"
blkCountStr:
	.asciiz " block(s) found.\n"
blkLeaderStr:
	.asciiz "Block Leader: "
sizeStr:
	.asciiz ", Size: "
nlStr:
	.asciiz "\n"
spaceStr:
	.asciiz " "
edgesStr:
	.asciiz "\nEdges:\n"
edgeSepStr:
	.asciiz " --> "
domsStr:
	.asciiz "\nDominator Bit Vectors:\n"
.text
main:
	lw	$a0 4($a1)	# Put the filename pointer into $a0
	li	$a1 0		# Read Only
	li	$a2 0		# No Mode Specified
	li	$v0 13		# Open File
	syscall
	bltz	$v0 main_err	# Negative means open failed

	move	$a0 $v0		#point at open file
	la	$a1 binary	# write into my binary space
	li	$a2 2048	# read a file of at max 2kb
	li	$v0 14		# Read File Syscall
	syscall
	la	$t0 binary
	add	$t0 $t0 $v0	#point to end of binary space

	li	$t1 0xFFFFFFFF	#Place ending sentinel
	sw	$t1 0($t0)

	#fix all jump instructions
	la	$t0 binary	#point at start of instructions
	move	$t1 $t0
	main_jumpFixLoop:
		lw	$t2 0($t0)
		srl	$t3 $t2 26	#primary opCode
		li	$t4 2
		beq	$t3 $t4 main_jumpFix
		li	$t4 3
		beq	$t3 $t4 main_jumpFix
		j	main_jfIncrem
		main_jumpFix:
			#Replace upper 10 bits of jump with binary address
			li	$t3 0xFC000FFF		#bitmask
			and	$t2 $t2 $t3		#clear bits
			la	$t4 binary
			srl	$t4 $t4 2		#align to instruction
			not	$t3 $t3
			and	$t4 $t4 $t3		#only get bits in field
			or	$t2 $t2 $t4		#combine back on the binary address
			sw	$t2 0($t0)		#place the modified instruction
		main_jfIncrem:
		addi	$t0 $t0 4
		li	$t4 -1
		bne	$t2 $t4 main_jumpFixLoop

	la	$a0 binary	#prepare pointer for assignment
	jal	getControlFlow

	#Retrieve stack values
	lw	$s1 0($sp)	#Block Pointer
	lw	$s3 4($sp)	#Edge Pointer
	lw	$s4 8($sp)	#Dominators Pointer
	addi	$sp $sp 8

	move	$s0 $v0		#Block Count
	move	$s2 $v1		#Edge Count

	move	$a0 $v0
	li	$v0 1
	syscall

	la	$a0 blkCountStr
	li	$v0 4
	syscall
	
	move	$t0 $s0
	addi	$sp $sp -4
	main_parseBlocks:
		beqz	$t0 main_doneBlocks
		sw	$t0 0($sp)
		la	$a0 blkLeaderStr
		li	$v0 4
		syscall

		lw	$a0 0($s1)
		jal	printHex

		la	$a0 sizeStr
		li	$v0 4
		syscall

		lw	$a0 4($s1)
		li	$v0 1
		syscall

		la	$a0 nlStr
		li	$v0 4
		syscall

		lw	$t0 0($sp)
		addi	$t0 $t0 -1
		addi	$s1 $s1 8

		j	main_parseBlocks
	main_doneBlocks:
		addi	$sp $sp 4
		la	$a0 edgesStr
		li	$v0 4
		syscall
	main_parseEdges:
		beqz	$s2 main_parseDoms

		lw	$a0 0($s3)
		jal	printHex

		la	$a0 edgeSepStr
		li	$v0 4
		syscall

		lw	$a0 4($s3)
		jal	printHex

		la	$a0 nlStr
		li	$v0 4
		syscall

		addi	$s2 $s2 -1
		addi	$s3 $s3 8

		j	main_parseEdges

	main_parseDoms:
		la	$a0 domsStr
		li	$v0 4
		syscall

		srl	$s5 $s0 5		# get number of words required
		sll	$t0 $s5 5
		beq	$s0 $t0 dominators_noAddCom
		addi	$s5 $s5 1		# add space for the dropped amount
		dominators_noAddCom:
		move	$t0 $s4			#Dominators pointer
		sll	$t1 $s5 2		#words to bytes
		li	$t3 0			#Block Counter
		main_printDomLoop:
			move	$t2 $t0
			add	$t2 $t2 $t1	#last word
			main_domWordLoop:
				beq	$t2 $t0 main_domWordDone
				addi	$t2 $t2 -4
				lw	$a0 0($t2)
				addi	$sp $sp -16
				sw	$t0 0($sp)
				sw	$t1 4($sp)
				sw	$t2 8($sp)
				sw	$t3 12($sp)
				
				jal	printBinary

				la	$a0 spaceStr
				li	$v0 4
				syscall			#add a space just in case

				lw	$t0 0($sp)
				lw	$t1 4($sp)
				lw	$t2 8($sp)
				lw	$t3 12($sp)
				addi	$sp $sp 16
				j	main_domWordLoop
			main_domWordDone:

			la	$a0 nlStr
			li	$v0 4
			syscall
			add	$t0 $t0 $t1	#Next dominator
			addi	$t3 $t3 1
			blt	$t3 $s0 main_printDomLoop

		j	main_done
		main_err:
		la	$a0 noFileStr
		li	$v0 4
		syscall
	main_done:
		li	$v0 10
		syscall


.data
prefix:
	.asciiz "0x"
hexChars:
	.ascii "0123456789ABCDEF"
.text
#-------------
# printHex
#
# ARGS: $a0 = number to print
#-------------
printHex:
	move	$a1 $a0
	la	$a0 prefix
	li	$v0 4
	syscall
	la	$t1 hexChars
	li	$v0 11
	li	$t2 8
	printHex_loop:
		beqz	$t2 printHex_done
		srl	$t0 $a1 28
		add	$t0 $t0 $t1
		lb	$a0 0($t0)
		syscall
		sll	$a1 $a1 4
		addi	$t2 $t2 -1
		j	printHex_loop
	printHex_done:
	jr	$ra

#-----------
# printBinary
# 
# Prints the binary value of a register
#
# ARGS: $a0 = the register to print
#-----------
printBinary:
	move	$t0 $a0
	li	$t2 0
	li	$t3 32
	j	printBinary_loop

	printBinary_space:
		srl	$t4 $t2 2
		sll	$t4 $t4 2
		bne	$t2 $t4 printBinary_loop
		
		#If we got here, print a space
		la	$a0 spaceStr
		li	$v0 4
		syscall

	printBinary_loop:
		srl	$a0 $t0 31
		sll	$t0 $t0 1
		li	$v0 1
		syscall
		addi	$t2 $t2 1
		bne	$t2 $t3 printBinary_space
	jr	$ra
########################## STUDENT CODE BEGINS HERE ############################
.text
getControlFlow:
	
	subu $sp, $sp, 4	# decrease stack pointer memory adress by 4
	sw $fp, 0($sp)		# place the frame pointer at the top
	move $fp, $sp
	subu $sp, $sp, 36	# create space for all the s registers in the 
	sw $s0, -4($fp)
	sw $s1, -8($fp)
	sw $s2, -12($fp)
	sw $s3, -16($fp)
	sw $s4, -20($fp)
	sw $s5,	-24($fp)
	sw $s6, -28($fp)
	sw $s7, -32($fp)
	sw $ra, -36($fp)

	li $t0, 0 # counter of instructions
	lui $t1, 0xffff
	ori $t1, 0xffff
	addi $t3, $a0, 0
	

Loop:
	lw $t2, 0($t3)
	beq $t2, $t1, Next
	addi $t0, $t0, 1	
	addi $t3, $t3, 4	
	j Loop
Next:
		
	add $v0, $0, $t0
	
	add $t4, $0, $a0
	
	add $a0, $0, $t0
	li $v0, 9
	syscall
	
	li $t9, 1
	 
	sb $t9, 0($a0)
	
	lw $t6, 0($t4)
	
	srl $t6, $t4, 26
	
	li $t5, 0
	
LeaderPos:
	lw $t6, 0($t4)
	add $t7, $t6, $0
	beq $t5, $t0, Exit
	
	beq $t6, 1, fTarget
	beq $t6, 4, fTarget	
	beq $t6, 5, fTarget
	beq $t6, 6, fTarget
	beq $t6, 7, fTarget
	
	#beq $t6, 2, fTarget #j
	#beq $t6, 3, fTarget #jal
	#jr
	#j to not finding target
	
	addi $t4, $t4, 4
	
	addi $t5, $t5, 1
	j LeaderPos
	
fTarget:
	addi $t0lw $s0, -4($fp)
	lw $s1, -8($fp)
	lw $s2, -12($fp)
	lw $s3, -16($fp)
	lw $s4, -20($fp)
	lw $s5,	-24($fp)
	lw $s6, -28($fp)
	lw $s7, -32($fp)
	lw $ra, -36($fp)
	addu $sp, $sp, 40
	lw $fp, -4($sp)			# fp present below sp
	
	jal $ra, $t5, 1 
	sb $t9, $t0($t4)
	
	#offset
	sll $t7, $t7, 16
	sra $t7, $t7, 16
	sll $t7, $t7, 2 	#multiplying offset by 4
	addi $t7, $t7, 4	#PC + 4
	
	# $t7 now has where the branch target
	sub $t7, $t7, $t4
	div $t7, 4
	mflo $t1
	sb $t9, $t1($t4)
	li $s0, 0
	
CountBB:
	lb $s1, 0($t4)
	addi $t4, $t4, 4
	addi $s2, $s2, 1
	bne $s1, 1, CountBB 
	addi $s0, $s0,1
	bne $s2, $t0, CountBB
	add $v0, $0, $s0
	
Exit:

	lw $s0, -4($fp)
	lw $s1, -8($fp)
	lw $s2, -12($fp)
	lw $s3, -16($fp)
	lw $s4, -20($fp)
	lw $s5,	-24($fp)
	lw $s6, -28($fp)
	lw $s7, -32($fp)
	lw $ra, -36($fp)
	addu $sp, $sp, 40
	lw $fp, -4($sp)			# fp present below sp
	
	jal $ra
		
