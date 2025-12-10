		.text
		.globl _start
_start:
	
		la $a0, prompt 			#printStr("Number: ")
		li $v0, 4
		syscall
		
		li $v0, 5				#readInt() = number1
		syscall
		sw $v0, number1
		lw $t3, number1			#result=number1
		
again:		
		la $a0, prompt1			#printStr("Operator: ")
		li $v0, 4
		syscall
		
		li $v0, 12         		#read char
		syscall
		move $t0, $v0      		#store operator in $t0
		
		# Check if operator is valid (+ - * / % =)
		li $t1, '+'        		# compare with '+'
		beq $t0, $t1, valid
		li $t1, '-'        		# compare with '-'
		beq $t0, $t1, valid
		li $t1, '*'        		# compare with '*'
		beq $t0, $t1, valid
		li $t1, '/'        		# compare with '/'
		beq $t0, $t1, valid
		li $t1, '%'       		# compare with '%'
		beq $t0, $t1, valid
		li $t1, '='        		# compare with '='
		beq $t0, $t1, valid
		
invalid:
		li $v0, 4
		la $a0, invalidMsg
		syscall
		j end
		
valid:
		li $t1, '='        		# compare with '='
		beq $t0, $t1, res
		
		la $a0, newline
		li $v0, 4
		syscall

		la $a0, prompt 			#printStr("Number: ")
		li $v0, 4
		syscall
		
		
		li $v0, 5				#readInt() = number2
		syscall
		move $t2, $v0			#store number2 in $t2
		
		
		li $t1, '/'           # check for division
		beq $t0, $t1, check_div_zero
		li $t1, '%'           # check for modulo
		beq $t0, $t1, check_div_zero
		j else_part

check_div_zero:
		beq $t2, $zero, invalid2   # if divisor == 0 → invalid
		j else_part
		
invalid2:
		li $v0, 4
		la $a0, invalidMsg2
		syscall
		j end	
		

else_part: 
		li $t1, '+'        		# compare with '+'
		beq $t0, $t1, do_add
		li $t1, '-'        		# compare with '-'
		beq $t0, $t1, do_sub
		li $t1, '*'        		# compare with '*'
		beq $t0, $t1, do_mul
		li $t1, '/'        		# compare with '/'
		beq $t0, $t1, do_div
		li $t1, '%'       		# compare with '%'
		beq $t0, $t1, do_mod
		
		
		do_add:
			add $t3, $t3, $t2     # result=result+number2
			j end_op 
		do_sub:
			sub $t3, $t3, $t2     # result=result-number2
			j end_op 
		do_mul:
			mul $t3, $t3, $t2     # result=result*number2
			j end_op 
		do_div:
			div $t3, $t3, $t2     # result=result/number2
			j end_op 
		do_mod:
			div $t3, $t3, $t2
			mfhi $t3              # result=result%number2
			j end_op 

end_op: 
		j again
		
res: 	la $a0, result 			#printStr("The result is ")
		li $v0, 4
		syscall
		
		move $a0,$t3				# printInt(result)	
		li $v0, 1
		syscall
		
		la $a0, prompt2 		#printStr("Want to continue?(Y/N)")
		li $v0, 4
		syscall
	
		li $v0, 12         		#read answer
		syscall
		move $t0, $v0      		#store answer in $t0
		li $t1, 'y'        		# compare with 'y'	
		la $a0, newline
		li $v0, 4
		syscall		
		beq $t0, $t1, _start 
		
	
end:
		li $v0, 10         # exit
		syscall
		
		
		.data
number1:	.space 4			#int number1
number2:	.space 4			#int number2
prompt:		.asciiz "Number: "
prompt1:	.asciiz "Operator: "
invalidMsg: .asciiz "\nError! Invalid operator"
invalidMsg2:.asciiz "\nError! Divide by zero"
result:		.asciiz "\nThe result is "
newline: 	.asciiz "\n"
prompt2:	.asciiz "\nDo you want to continue with a new expression? (y/n)"