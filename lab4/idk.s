upt
.ktext 0x80000180
	move $k1, $at		#no idea what it does
	
	sw $v0, s1 			# Reloading v0 and a0 registers
	sw $a0, s2

	mfc0 $k0, $13				# Reading from cause register to see the cause of problem
	andi $a0, $k0, 0x0800  		# Get the 11 byte value 
	srl $a0, $a0, 11			# Get the value stored at 11 to byte 1 position
	bgtz $a0, Keyboard 			# if value more than zero hence keyboard interuption happened

Keyboard:
	lw $s3, 0xffff0004			# Checking what keyboard value was entered and storing it in s3
	beq $s3, 0x38, moveUp

	mtc0 $0, $13				# Clearing Cause Register
	lw $v0, s1 					# Restoring v0 and a0 values
	lw $a0, s2				
	eret						# escape to main program

moveUp:
	la $s1, cursorRow
	addi $s2, $s1, -1
	la $s0, newCursorRow
	sw $s2, 0($s0)

	mtc0 $0, $13 
	lw $v0, s1
	lw $a0, s2

	eret

Timer:

main:

	#To enable Status Register interrupt($12) -> keyboard / timer
	mfc0 $k0, $12   		# enabling Status Register
	ori $k0, 0x8801 		# initializing the 1st 11th and 15th values
	mtc0 $k0, $12			# Clearing the Register

	# enable keyboard control
	lw $s2, 0xffff0000 		# Enabling the Keyboard Control
	ori $s2, $s2, 0x02
	sw $s2, 0xffff0000 

	# li $v0, 10   # syscall 10 = exit    
	# syscall


PART@::::::::::::::::::::::::::::::::::::::

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

infiniteloop:
	beq $s3, 50, moveDown		# If value equal to 'q' then go to JumpM
	j infiniteloop

	li $v0, 10				# exit,if it ever comes here
	syscall

moveDown:
	la $s1, cursorRow
	addi $s2, $s1, 1
	la $s0, newCursorRow
	sw $s2, 0($s0)
	j infiniteloop


.kdata
	s1: .word 0
	s2: .word 0
	s3: .word 0

# modifying our exception Handler here
.ktext 0x80000180
	sw $v0, s1 					# Reloading v0 and a0 registers
	sw $a0, s2
	sw $s3, s3

	mfc0 $k0, $13				# Cause Register values Stored
	andi $a0, $k0, 0x0800  		# Get the 11 byte value 
	srl $a0, $a0, 11			# Get the value stored at 11 to byte 1 position
	bgtz $a0, Keyboard
	 			# if value more than zero hence keyboard interuption happened

Keyboard:
	lw $s3, 0xffff0004			# Checking what keyboard value was entered and storing it in s3
	
	mtc0 $0, $13 
	lw $s3, s3
	lw $v0, s1
	lw $a0, s2

	eret


