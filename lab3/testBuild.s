.data
	visited: .space 1000 		#number of instruction*number of functions 
	allLiveRegs: .space 10  	#number of functions
	liveRegs: .space 4 			#word
	DeadStack: .space 1000 		#like visited(each instruction is branch)
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
	beq $t1, 0x03000000, checkJR
	bne $t1, 0x03000000, ITYPE

	
		
j continue2:

	addi $s2, $s2, 4 #move to next instruction

	sll $t2, $t0, 26 					#search for jr ra to see if code is end 
	beq $t2, 0x00000000, endInstruction

	j updateLiveRegs

ITYPE:
	andi $t5, $t0, 0x001F0000 	#rt
	andi $t3, $t0, 0x03E00000 	#rs
	li $s0, 1
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
	sb $t8, 0($t9)
	sub $t9, $t9, $t3	#going back to original position

	beq $s0, $t8, skip
	sll $t4, $t4, 11 	#rt
	srl $t4, $t4, 27
	addi $t9, $t9, $t4
	sb $t8, 0($t9)
	sub $t9, $t9, $t4
skip:
	
	j updateLiveRegs 
