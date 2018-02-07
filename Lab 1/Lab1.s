#---------------------------------------------------------------
# Assignment:           1
# Due Date:             January 21, 2016
# Name:                 Siddhant Khanna
# Unix ID:              skhanna1
# Lecture Section:      A1
# Instructor:           Jose Nelson Amaral
# Lab Section:          Lab D06(Thursday5-8)
# Teaching Assistant:   Shantong Zhang
#---------------------------------------------------------------


#---------------------------------------------------------------
# The main program flips the bytes at places 3,2,1,0 of an integer entered in the terminal
# to perform endianness conversion. the byte order is inversed. The program shifts the mask no. 
# enabling it to traverse throughout the bit ditribution of the integer and obtaining values at each byte.
# the program also shifts the those numbers obtained from masking to the opposite side of theirs. 
#
# Register Usage:
#
#       $v0: number entered
#	$a0: initialize $a0 to endian value that was flipped in $t1 
#	$t0: mask no.
#	$t1: gives byte 0 and eliminates everything else
#	$t4: getting the byte 2 value
#	$t5: getting the 2 byte place value
#	$t6: getting the 3 byte place value 
#
#---------------------------------------------------------------


main:
	
	li $v0, 5	#to get the integer in the terminal enter in $v0
	syscall 
	
	addi $t0, $zero, 0x00FF	#to make the integer mask with the 1111 1111 number hence $v0 represents the mask 						#number
	
	and $t1, $v0, $t0	#If the bytes are labeled from 3,2,1,0 with 0 being the least significant 					#endianness so obtains the value at the 0 byte and puts it in $t0
	sll $t1, $t1, 24 	#shifting the masked value byte 0 obtained in $t1 to the left in byte 3 place
	sll $t0, $t0, 8 	#shifting the mask no towards left to get byte 1
	
	and $t4, $v0, $t0 	#masking the original value with the new mask no placed at byte 1 
	sll $t4, $t4, 8 	#shifting the byte 1 value towards left in byte 2 place
	or $t1, $t1, $t4 	#adds the byte 1 value in byte 2 place in $t1 
	sll $t0, $t0, 8 	#shifting the mask no to the left in byte 2 place

	and $t5, $v0, $t0 	#get the value at the byte 2 and stores it in $t5
	srl $t5, $t5, 8 	#shifts the byte 2 value tot the right in byte 1 place
	or $t1, $t1, $t5 	#combines byte 1-2, 3 to byte 4-3, 2
	sll $t0, $t0, 8 	#shifts the mask no to the left in byte 2 place

	and $t6, $v0, $t0 	#get the value at the byte 3 position in $t6
	srl $t6, $t6, 24 	#get the value shifted right in byte 3 to byte 0 place
	or $t1, $t1, $t6 	#combine byte 3 value to byte 1 value with other elements
	
	srl $a0, $a0, 1 
	or $a0, $a0, $t3
	
	
	li $v0, 1 
	move $a0, $t1 		#initialize $a0 to endian value that
						# was flipped in $t1 
	syscall
	
	li $v0,10
	syscall
