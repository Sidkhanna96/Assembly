#---------------------------------------------------------------
# Assignment:           2
# Due Date:             October 5, 2016
# Name:                 Siddhant Khanna
# Unix ID:              skhanna1
# Lecture Section:      A1
# Instructor:           Jose Nelson Amaral
# Lab Section:          Lab D06(Thursday5-8)
# Teaching Assistant:   Shantong Zhang
#---------------------------------------------------------------


#---------------------------------------------------------------
# The subroutine disassemble Branch obtains a set of MIPS assembly instructions and checks #weather the instruction provided are MIPS set instructions or not. The program breaks the #assembly Branch instructions into there format to obtain the OPcode, RegS, RegT and Offset #value. It obtains the value in a binary format and then converts them into the Binary #Instruction. The program lastly calculates the Offset value and then converts it into the #required format of hexdecimal
#
# Register Usage:
#
#       $v0: number entered
#	$a0: initialize $a0 to the address of the MIPS instructions
#	$t0: Obtains the value of the MIPS instruction
#	$t1: Adds the constant four to initialize the PC counter
#	$t2: OPcode Value
#	$t3: Reg S
#	$t4: Reg T 
#	$t5: Offset Value
#	$t6: Initialize to number 9 to calculate the character in Hex
#	$t7: Shifted value of the Offset towards right
#	$t9: Assigned value 8 to control the number of loops
#---------------------------------------------------------------


#.data defines values that needed to be printed in order to present the equivalent output
.data
	bgezs: 	.asciiz "bgez"
	bgezals: .asciiz "bgezal"
	bltzs: 	.asciiz "bltz"
	bltzals: .asciiz "bltzal"
	beqs: 	.asciiz "beq"
	bnes: 	.asciiz "bne"
	blezs: 	.asciiz "blez"
	bgtzs: 	.asciiz "bgtz"
	spaces: .asciiz " "
	coms: 	.asciiz ", "
	dollas: .asciiz "$"
	xs:    .asciiz "0x"
#The main code where the computation happens begins	
.text
	
	disassembleBranch:		# Program calls the disassemble Branch
		lw $t0, 0($a0)		# Load the value of address to t0
	
		addi $t1, $a0, 4	# Begin the PC counter
	
		#OPcode
		srl $t2, $t0, 26	# We shift the bits value towards right by 26 bits 						# to obtain the OPcode Value   
		#Here to Check if the insruction i a MIPS instuction
		beq $t2, 1, Continue	#checks if the OPcode obtained is equal to 1
		beq $t2, 4, Continue	#Check if OPcode is equal to 4
		beq $t2, 5, Continue	#Check if OPcode is equal to 5
		beq $t2, 6, Continue	#check if OPcode is equal to 6
		beq $t2, 7, Continue	#check if OPcode is equal to 7
	
		jr $ra #exits aswe do notwant it to go over allthe functions again
	
	Continue:
	
	
		#Reg S
		sll $t3, $t0, 6		#Shifts thew bit left
		srl $t3, $t3, 27	#shifts te bit rigt to get he Regs value
	
		#Reg T
		sll $t4, $t0, 11 	#Shifts th bits left
		srl $t4, $t4, 27	#shifts te bits righ to get the RegT value in the 
					#left most of the bits structure
	
		#Offset	
		sll $t5, $t0, 16	#shifts te bits left
		sra $t5, $t5, 16	#We do sra totake into accunt for negative value
		
		sll $t5, $t5, 2		#multiplythe Offset by 4 to get the word positon
		add $t5, $t5, $t1	#adding the orginal address o the Offset
		
		#Here to Print the call value -> beq, bn etc 
		beq $t2, 1, PrintBG	
		beq $t2, 4, PrintBEQ
		beq $t2, 5, PrintBNE
		beq $t2, 6, PrintBLEZ
		beq $t2, 7, PrintBGTZ
	
		j $ra
	#If the value is equl to 1 then we needto further ealuate wht call alue(bne 		#etc) it is as wmany of them have the same OPcode hene here we use its Reg T value
	# to further ealuate
	PrintBG:
		beq $t4, 1, PrintBGEZ		
		beq $t4, 17, PrintBGEZAL
		beq $t4, 0, PrintBLTZ
		beq $t4, 16, PrintBLTZAL
		
		j $ra
	#checks fr other cll value(beq etc) but only usesOPcode asfor these they ae all 	#disinct
	PrintBGEZ:
		li $v0, 4
		la $a0, bgezs
		syscall
		j next
	PrintBGEZAL:
		li $v0, 4
		la $a0, bgezals
		syscall
		j next
	PrintBLTZ:
		li $v0, 4
		la $a0, bltzs
		syscall
		j next
	PrintBLTZAL:
		li $v0, 4
		la $a0, bltzals
		syscall
		j next
	PrintBEQ:
		li $v0, 4
		la $a0, beqs
		syscall
		j next
	PrintBNE:
		li $v0, 4
		la $a0, bnes
		syscall
		j next
	PrintBLEZ:
		li $v0, 4
		la $a0, blezs
		syscall
		j next # the j nxt are here to skip the code below it that ae not par of the 				# next fnction
	PrintBGTZ:
		li $v0, 4
		la $a0, bgtzs
		syscall
		j next 
	next: #here we re just formatting paces $ and commas
		li $v0, 4
		la $a0, spaces
		syscall
		
		li $v0, 4
		la $a0, dollas
		syscall
		
		add $a0, $t3, $zero
		li $v0, 1
		syscall
		
		li $v0, 4
		la $a0, coms
		syscall
		
		beq $t2, 4, addT #since only beq and bne have register T we need tofind them
		beq $t2, 5, addT
		
	next2: #begining f the foration of he Offset value calculation
		li $v0, 4	#formatting
		la $a0, xs
		syscall
		
		addi $t9, $zero, 8 #initialie to 8 fo number o loop iterations
		addi $t6, $zero, 9 #initialie to 9 for charactes to access
		
		Loop:
			#Convert to Hex
			beq $t9, 0, EXIT	#checking condition for the if statement
			
			srl $t7, $t5, 28	#shifting th binay value twards rigt and 
						#from te Offset calculated in order to 
						#get the irst integer value n Hex
			
			bgt $t7, $t6, 
			PrintChar # if the vale is greater tghanb 9 then 
						#it would print out the charcter form of it
			
			li $v0, 1
			add $a0, $t7, $zero	# if it i not greater tan characer then it 							# willcall the integer 
			syscall
			
			sll $t5, $t5, 4		#shifting the original binary value to the 							#right in order to put it next inline to be
						#printed
			addi $t9, $t9, -1	#decrease for loop in order for it to end
			j Loop
			
		PrintChar: 	#Print Character form of integer if its value is geater than 					#zero
			
			li $v0, 11	# print character
			addi $a0, $t7, 87 #used to onvert the integer to lowercase form
			syscall
			
			sll $t5, $t5, 4 #shift the binary value in order to get it neXt in 
					#lineto print
			
			addi $t9, $t9, -1 #
			j Loop
	#Formatting and addin Reg T
	addT:	
		li $v0, 4
		la $a0, dollas	#adding $ sign
		syscall
		
		add $a0, $t4, $zero
		li $v0, 1	#adding value
		syscall
		
		li $v0, 4
		la $a0, coms	#adding comma
		syscall
		
		j next2
		
	EXIT:			#Exit the suboutine
		jr $ra		#exiting he subrouine
