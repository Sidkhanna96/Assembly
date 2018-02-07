# .data
# 	max_i:
# 		.double 5.0
# 	min_r:
# 		.double 4.0
# main:
# 	li.d $f12, 5.0
# 	li.d $f18, 4.0
# 	li.d $f14, 2.0
# 	li.d $f16, 3.0
# 	addi $a0, $zero, 6
# 	addi $a1, $zero, 7
# 	jal set_size
# 	li $v0 10
# 	syscall

.text

set_size:  

	s.d $f12, max_i 	#does this erase the values in f12 ?		
	s.d $f18, min_r 	#does this erase the values in f12 ?		

	mov.d $f4, $f14 		#min_i
	mov.d $f6, $f16 		#max_r

	sub.d $f4, $f12, $f4 	#max_i - min_i 	@reusing register
	sub.d $f6, $f6, $f18 	#max_r - min_r 	@reusing register

	mtc1 $a0, $f8 			#storing the nRows in f register
	cvt.d.w $f8, $f8  		#converting to float nRows
	mtc1 $a1, $f10 
	cvt.d.w $f10, $f10 		#converting to float nCols

	div.d $f8, $f4, $f8 	#max_i - min_i/nRows
	div.d $f10, $f6, $f10 	#max_r - min_r/nCols

	s.d $f8, step_i
	s.d $f10, step_r

	jr $ra

