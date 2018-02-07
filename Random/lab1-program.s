#---------------------------------------------------------------
# This program performs endianness conversion
#
# Register Usage:
#
#       v0: contains the number to be converted
#       t0: contains the converted number
#
#---------------------------------------------------------------


main:
	li	$v0,	5			# syscall code for read_int
	syscall					# reads int
	
	andi	$t1,	$v0,	0x000000ff	# masking out bits
	sll	$t1,	$t1,	24		# shifting byte to new position
					
	andi	$t2,	$v0,	0x0000ff00	# repeat for all bytes	
	sll	$t2,	$t2,	8		
	
	li	$s0,	0x000000ff
	sll	$t3,	$s0,	16
	and	$t3,	$v0,	$t3
	srl	$t3,	$t3,	8
	
	li	$s1,	0x000000ff
	sll	$t4,	$s1,	24
	and	$t4,	$v0,	$t4
	srl	$t4,	$t4,	24

	add	$t5,	$t1,	$t2		# adding to get final integer
	add	$t6,	$t3,	$t4
	add	$t0,	$t5,	$t6
		
	li	$v0,	1			# syscall code for print_int
	move	$a0,	$t0			# int to read
	syscall					# prints int	
	
	li	$v0,	10
	syscall
