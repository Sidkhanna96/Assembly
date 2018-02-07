.data
    visited: .space 1000         #number of instruction*number of functions*word 
    allLiveRegs: .space 100      #number of functions*word (Each word has an jal code block)
    liveRegs: .word 0             #word
    DeadStack: .space 4000         #like visited(each instruction is branch)
    beginningAddressArg: .word 0

.text
findLive:
    addi $sp, $sp, -44     #storing registers
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)
    sw $a2, 36($sp)
    sw $a1, 40($sp)

    lw $s0, beginningAddressArg
    move $s0, $a0                 # $t0 -> beginningAddressArg - $a0
    li $s1, 0                    # ResultIndex = 0

    la $s4, allLiveRegs
    la $s5, liveRegs
    la $s6, DeadStack

    #getting all the jal instructions
    Loop:
        #$s0 - instruction position
        beq $s0, 0xFFFFFFFF, END     #Reaching end of program (no more JAL)
        srl $t2, $s0, 26             #getting the opcode
        bne $t2, 0x0003, NextIntr     #if not jal dont go through

        addi $t3, $zero, 0             #deadStackIndex = 0
        move $a1, $t3
        addi $a2, $s0, 4            #address value after the jump
        jal gatherLiveRegs             

        sll $s1, $s1, 2             #resultindex*4
        add $s4, $s4, $s1             #allLiveRegs + resultIndex - allLiveRegs[resultIndex]
        sw $s5, 0($s4)                 #allLiveRegs[resultIndex] = liveRegs 

        addi $s1, $s1, 1             #resultIndex ++

        li $s6, 0
        sw $s6, 0($s5)

        add $s5, $zero, $zero

    NextIntr:
        addi $s0, $s0, 4             #next instruction
        j Loop

END:
    sll $t1, $t1, 2             #resultindex*4
    add $t4, $t4, $t1             #allLiveRegs + resultIndex = allLiveRegs[resultIndex]
    li $t6, 0
    sw $t6, 0($t4)

    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    lw $a1, 36($sp)
    lw $a2, 40($sp)
    addi $sp, $sp, 44

    jr $ra


gatherLiveRegs:
Loop2:

	addi $sp, $sp, -44     #storing registers
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    sw $s5, 24($sp)
    sw $s6, 28($sp)
    sw $s7, 32($sp)
    sw $a2, 36($sp)
    sw $a1, 40($sp)

    move $t0, $a2         #address of the current position instruction
                        #after the jal

    andi $s0, $t0, 0x001FFFF

    bne $s0, 0x0008, END 	#checking if we reached jr $ra(End of code block)

    move $t1, $a1         #deadStackIndex

	la $s3, liveRegs 		#LiveRegs will have all the registers that are live
	la $s2, DeadStack 		#DeadStack 

    sub $t2, $t0, $a0     #index = address-beginningAddress
    lw $t3, 0($t0)         #instruction = load instruction from address

    la $t4, visited     #Visited
    add $t4, $t4, $t2     #visited[index]
    
    li $t5, 1
    beq $t4, $t5, Term     #visited[index] == 1
    srl $t5, $t3, 26
    beq $t5, 0x0000, Term     #instruction == jr $ra

    sw $t5, 0($t4)             #visited[index] = 1

    j updateLiveRegs

Term:
    li $t5, 0             #visited[index] = 0    
    sw  $t5, 0($t4)
    jr $ra

updateLiveRegs:
	
	lw $t6, 0($t0) 				#Instruction(starts with the one after jal)

Back:

	srl $t7, $t6, 26 			#OpCode

	beq $t7, 0x0001, calcTarget
	beq $t7, 0x0004, calcTarget
	beq $t7, 0x0005, calcTarget
	beq $t7, 0x0006, calcTarget
	beq $t7, 0x0008, calcTarget
 
 	beq $t7, 0x0002, jCalcTarget
	beq $t7, 0x0000, RTYPE		#RTYPE
	bne $t7, 0x0000, ITYPEbranch 	#ITYPE

	j NextIntr2 				#?????

calcTarget:
	li $s5, 1
	sll $t7, $t6, 16 	#has the lower 16 bit of branch
	sra $t7, $t7, 16

	sll $t7, $t7, 2

	addi $s0, $t6, 4 	#PC+4

	add $t6, $s0, $t7 	#PC+4 + signExtended

	jal gatherLiveRegs


jCalcTarget:
	andi $t7, $t7, 0x03FFFFFF 	#26 bits of jump
	andi $s0, $t6, 4 			#PC+4
	sll $t7, $t7, 2				# shift by 2

	andi $t7, $t7, 0xF0000000 	#get the 4 MSB
	and $t6, $t7, $s0 			#concatenate the 4 MSB with PC+4

	$a1, $t6

	jal gatherLiveRegs


	#How does allLiveRegs update ???
RTYPE:
	sll $t5, $t7, 6 	#rs
	srl $t5, $t5, 26 	#rs
	
	sll $t8, $t7, 11 	#rt
	srl $t8, $t8, 26 	#rt
	li $s6, 1
	
	sll $t9, $t7, 16 	#rd (Dead)
	srl $t9, $t9, 26 	#rd

	# JUMP INSTRUCTIONS

	j Continue

ITYPEbranch:
	sll $t8, $t7, 11
	srl $t8, $t8, 26

	bne $t8, 0x0000, check 	#for branches that only have $s not $t
check:
	bne $t8, 0x0001, ITYPE

	sll $t5, $t7, 6 	#rs
	srl $t5, $t7, 26 	#rs
	
	li $s7, 1 			# for not doing delete
	li $s6, 0 			# for not having second register

	j Continue


ITYPE:  
	sll $t5, $t7, 6 	#rs
	srl $t5, $t5, 26 	#rs
	
	sll $t9, $t7, 11 	#rt (Dead)
	srl $t9, $t9, 26 	#rt
	li $s6, 0 			#for not having second register

Continue:
	#s3 liveRegs
	li $s4, 1
	
	add $s2, $s2, $t5 	#checking for if the element is in dead registers
	lb $s1, 0($s2)
	sub $s2, $s2, $t5
	beq $s1, 1, skip2

	add $s3, $s3, $t5 	#s3 liveReg, t5 rs
	lb $s4, 0($s3)
	sub $s3, $s3, $t5 	#getting back to original position

skip2:

	bne $s6, 1, skip 	#rt

	add $s2, $s2, $t8 	#checking if element is present
	lb $s1, 0($s2)
	sub $s2, $s2, $t8
	beq $s1, 1, skip

	add $s3, $s3, $t8
	lb $s4, 0($s3)
	sub $s3, $s3, $t8
skip:
	bne $s7, 1, updateDelete

updateDelete:
	li $s4, 1
	bne $s5, 1, dontCloneStack
	sw $s5, 0($s2)
	addi $s2, $s2, 4 	#move to next stack
	lw $s5, 0($s2) 		#clone the value of previous to current

dontCloneStack:

	sll $s2, $s2, $t9
	sb $s4, 0($s2)
	srl $s2, $s2, $t9

NextIntr2:
	addi $a2, $a2, 4 	#move to next instruction

	j Loop2

END:

	lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    lw $s2, 12($sp)
    lw $s3, 16($sp)
    lw $s4, 20($sp)
    lw $s5, 24($sp)
    lw $s6, 28($sp)
    lw $s7, 32($sp)
    lw $a1, 36($sp)
    lw $a2, 40($sp)
    addi $sp, $sp, 44

	jr $ra