.data
	error: ascii. "Dimension pssed is higher than 3" 
.text
CubeStats:
	lw $t9, 0($a0)
	
	subu $sp, $sp, 4
	sw $fp, 0($sp)
	move $fp, $sp
	subu $sp, $sp, 20
	sw $s0, -4($fp)
	sw $s1, -8($fp)
	sw $s2, -12($fp)
	sw $s3, -16($fp)
	sw $s4, -20($fp)
	
	addi $t0, $zero,0
	lw $s0, 0($a2) #starting
	lw $s1, 0($a3) #edge
	lw $s2, 0($a1) #size
	
	addi $s4, $zero, 0
	addi $s3, $zero, 0
	addi $t2, $zero, 0
	addi $t3, $zero, 0
	addi $t4, $zero, 0
	
	
	beq $t9, 1, ONE
	beq $t9, 2, TWO
	beq $t9, 3, THREE
	
ONE:
		
	
	LOOP:
		beq $t0, $s1, AvgOne
		bgtz $s0, PosOne
		bltz $s0, NegOne
		beqz $s0, ZerOne	
		lw $s0, 4($a2)
		addi $s0, $t0, 1
		
		j LOOP
		
	PosOne:
		addi $t1, $t1, 1
		add $t2, $t2, $s0
	NegOne:
		addi $t3, $t3, 1
		add $t4, $t4, $s0
		mult $t4, $t4, -1
		#add $t5, $zero, $t4
	ZerOne:
		#Do nothing 
		#Blessed
	AvgOne:
		#negative
		div $t5, $t4, $t3
		rem $t6, $t4, $t3
		add $t7, $t6, $t5 #negative avg
		add $v0, $zero, $t7
		#positive
		div $t8, $t2, $t1 #positive avg
		add $v1, $zero, $t8
		
	
			
#end of 1D

TWO:
	sub $s4, $s2, $s1
	
	Loop1:
		beq $s3, $s4, AvgTwo
		Loop2:
			beq $t0, $s1, Continue
			bgtz $s0, PosTwo
			bltz $s0, NegTwo
			beqz $s0, ZerTwo
			lw $s0, 4($a2)
			addi $s3, $s3, 1
			j Loop2
	Continue:
		add $s0, $s0, $s4
		j Loop1
	PosTwo:
		addi $t1, $t1, 1
		add $t2, $t2, $s0
	NegTwo:
		addi $t3, $t3, 1
		add $t4, $t4, $s0
		mult $t4, $t4, -1
		#add $t5, $zero, $t4		#dont really need t5
	ZerTwo:
		#Do nothing 
		#Blessed
	AvgTwo:
		#negative
		div $t5, $t4, $t3
		rem $t6, $t4, $t3
		add $t7, $t6, $t5 #negative avg
		add $v0, $zero, $t7
		#positive
		div $t8, $t2, $t1 #positive avg
		add $v1, $zero, $t8
#end Two
THREE:
	addi $t7, $zero, 0
	Loop3:
		beq $t7, $s1, AvgThree
		sub $s4, $s2, $s1
		Loop1:
			beq $s3, $s4, AvgThree
			Loop2:
				beq $t0, $s1, Continue
				bgtz $s0, PosThree
				bltz $s0, NegThree
				beqz $s0, ZerThree
				lw $s0, 4($a2)
				addi $s3, $s3, 1
				j Loop2
		Continue:
			add $s0, $s0, $s4
			j Loop1
		PosThree:
			addi $t1, $t1, 1
			add $t2, $t2, $s0
		NegThree:
			addi $t3, $t3, 1
			add $t4, $t4, $s0
			mult $t4, $t4, -1
			#add $t5, $zero, $t4		#dont really need t5
		ZerThree:
			#Do nothing 
			#Blessed
	addi $t8, $zero, 0
	addi $k8, $s2, $s1
	sub $t8, $s2, $s1
	mult $t8, $s2, $k8
	lw $s0, ($t8)($a2)

	AvgThree:
		#negative
		div $t5, $t4, $t3
		rem $t6, $t4, $t3
		add $t7, $t6, $t5 #negative avg
		add $v0, $zero, $t7
		#positive
		div $t8, $t2, $t1 #positive avg
		add $v1, $zero, $t8
	
	lw $s0, -4($fp)
	lw $s1, -8($fp)
	lw $s2, -12($fp)
	lw $s3, -16($fp)
	lw $s4, -20($fp)
	addu $sp, $sp, 24
	lw $fp, -4($sp)

