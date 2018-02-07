.data
	sec: .asciiz "Seconds= "
	space: .space 11
.kdata	
	s1: .word 0
	s2: .word 0
	
.ktext 0x80000180
	sw $v0, s1
	sw $a0, s2
	
	mfco $k0, $13
	andi $s3, $k0, 0x8800
	srl $s3, $s3, 11
	beq $s3, 1, timer
	srl $s3, $s3,4
	beq $s3, 1,
	la $s4, 0xffff0004
	beq $s4, 0x71, next
	j next2
	timer:
		 
		
	next2:
		lw $v0, s1
		lw $a0, s2
	
	
.text
main:
	la $s2, 0xffff0000
	ori $s2, $s2, 0x02
	sw $s2, 0xffff0000
	
	
	li $v0, 4
	la $a0, sec
	syscall
	
	li $v0, 5
	syscall
	add $t0, $zero, $v0 # t0 -> has the time entered by the user
	
	addi $t1, $zero, 60
	div $t0, $t1
		
	mflo $t2 #quotient
	mfhi $t3 #remainder
	
	addi $t4, $zero, 10
	
	div $t2, $t4
	mflo $t5 # quotient
	mfhi $t6 # remainder
	
	div $t3, $t4
	mflo $t7 # quotient
	mfhi $t8 # remainder
	
	addi $t0, $zero, 8 # RR
	addi $t1, $zero, 0x3A
	addi $t2, $zero, 0
	
	addi $t5, $t5, 48
	addi $t6, $t6, 48
	addi $t7, $t7, 48
	addi $t8, $t8, 48
	
	la $t9, space
	sb $t0, 0($t9)
	sb $t0, 1($t9)
	sb $t0, 2($t9)
	sb $t0, 3($t9)
	sb $t0, 4($t9)
	sb $t5, 5($t9)
	sb $t6, 6($t9)
	sb $t1, 7($t9)
	sb $t7, 8($t9)
	sb $t8, 9($t9)
	sb $t2, 10($t9)
	
	
	#enabling Status Register
	mfc0 $k0, $12
	ori $k0, 0x8801	# enabling the status and the keyboard and timer
	mtc0 $0, $k0
	
	# cause register enabling
	mfc0 $k0, $13
	ori $k0, 0x8800	# enabling the status and the keyboard and timer
	mtc0 $0, $k0
	
	loop:
		lb $s0, 0($t9)
		beqz $s0, next
		
	poll:
		lw $s1, 0xffff0008
		andi $s1, $s1, 0x01
		beqz $s1, poll
		
		sb $s0, 0xffff000c
		addi $t9, $t9, 1
		j loop
		
	next:	
		li $v0, 10
		syscall

