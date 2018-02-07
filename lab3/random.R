#and $t1, $t0, 0xE0000000 	#get the first 3 bits
	#beq $t1, 0x00000000, branch 	#branch 000
	#beq $t1, 0x80000000, load 		#load 100
	#beq $t1, 0x20000000, andInstr 	#and 001
	#beq $t1, 0xA0000000, load 		#beacause store/load same - 101