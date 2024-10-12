###################################
#  HW1: Simple string calculator  #
###################################
#
#  Data segment
#
		.data
input:		.asciiz  "Enter input (e.g. 1+2): "	# accept input expression
error:		.asciiz  "Input error!" 	# handle input error
sol:    	.asciiz  "Answer = "	# label for "Answer: " 
plus: 		.asciiz  "+"		# label for "+"
minus:		.asciiz  "-"		# label for "-"
multiple:   .asciiz  "*"    # multiplication symbol
divider:    .asciiz  "/"    # division symbol
div_error:	.asciiz	 "Cannot divide by 0." # handle divide by zero exception
exp:		.word 	 0:15   	# define buffer for input string
size: 		.word  	 15			# size of buffer

#
#  Text segment
#
		.text
main:	la 	$a0,input  		# print 
		li 	$v0,4			# "Enter input (e.g.):"
		syscall
		la 	$a0,exp			# load Buffer for input string         
		la  $a1,size		# load size to $a1  
		li  $v0,8 	    	# read string
		syscall
		la	$t0, exp		# load base address of exp
		jal load_input		# load operand 1, 2, operator
		jal signchecker		# check sign of operand 1
		jal check_s4		# check sign of operand 2
		jal	operator		# decide operation
		jal	print			# print result
		
_end:	li 	$v0,10      	# system call for exit       
        syscall   			# EXIT!
		
#
#  Subroutine to load operands & operator, and to print the result 
#

	
load_input: addi 	$sp, $sp, -4	# allocate space on stack 
			sw 		$ra, 0($sp)		# store $ra value on stack
			li      $s0, 0          # initialize first operand
        	li      $s1, 0          # initialize second operand

			jal 	op1comp			# subroutine to check for negative sign
			jal 	op1				# op1 subroutine
			
			lb 		$t2, 0($t0)		# load operator into $t2
			addi	$t0, $t0, 1		# move to next address

			jal 	op2comp    		# subroutine to check for negative sign  
			jal 	op2				# op2 subroutine

			lw 		$ra, 0($sp)		# restore $ra value from stack
			addi 	$sp, $sp, 4		# restore stack pointer
			jr   	$ra				# return from subroutine    
op1comp:
			lb      $t1, 0($t0)         # load current character
			lb      $t2, minus          # load '-' character
			beq     $t1, $t2, op1_neg   # branch if '-' is found
			li      $s3, 0              # set positive sign flag
			jr      $ra                 # return to load_input

op1_neg:
			li      $s3, 1              # set negative sign flag
			addi    $t0, $t0, 1         # move to next character
			jr      $ra                 # return to load_input

op2comp:
			lb      $t1, 0($t0)         # load current character
			lb      $s5, minus          # load '-' character
			beq     $t1, $s5, op2_neg   # branch if '-' is found
			li      $s4, 0              # set positive sign flag
			jr      $ra                 # return to load_input

op2_neg:
			li      $s4, 1              # set negative sign flag
			addi    $t0, $t0, 1         # move to next character
			jr      $ra                 # return to load_input

op1:		lb		$t1,0($t0)     		# load current character
			beq     $t1, '\n', end_op   # handle newline character
			beq     $t1, '\0', end_op   # handle null terminator
			li		$t3, '0'			# ASCII '0' = 48	
			li		$t4, '9'			# ASCII '9' = 57
			# if $t1 > 57 && $t1 < 48, it is not a number
			blt     $t1, $t3, end_op
    		bgt     $t1, $t4, end_op
			
			# If it is a number
			addi 	$t1, $t1, -48 	# Convert ASCII -> number
			mul		$s0, $s0, 10	# Increase place value
			add     $s0, $s0, $t1	# Add current digit
			addi	$t0, $t0, 1		# Move to next character
			j 		op1				# Repeat

op2:		lb		$t1,0($t0)     		# load current character
			beq     $t1, '\n', end_op   # handle newline character
			beq     $t1, '\0', end_op   # handle null terminator
			li		$t3, '0'			# ASCII '0' = 48	
			li		$t4, '9'			# ASCII '9' = 57
			# if $t1 > 57 && $t1 < 48, it is not a number
			blt     $t1, $t3, error
    		bgt     $t1, $t4, error
			
			# If it is a number
			addi 	$t1, $t1, -48 	# Convert ASCII -> number
			mul		$s1, $s1, 10	# Increase place value
			add     $s1, $s1, $t1	# Add current digit
			addi	$t0, $t0, 1		# Move to next character		
			j 		op2				# Repeat

end_op: 	jr $ra					# return to load_input

signchecker:
    		bne     $s3, $zero, neg_op1	# if $s3 != 0, branch to neg_op1 (for negative)
			jr		$ra					# return to main	
check_s4:
    		bne     $s4, $zero, neg_op2 # if $s4 != 0, branch to neg_op2 (for negative)
			jr		$ra					# return to main

neg_op1: 	neg		$s0, $s0			# make operand1 negative
			jr		$ra					# return to main
			
neg_op2: 	neg		$s1, $s1			# make operand2 negative
			jr 		$ra				 	# return to main

operator:	lb 		$t5, plus			# load "+" to $t5
			lb		$t6, minus			# load "-" to $t6
			lb      $t7, multiple    	# load '*' 
			lb      $t8, divider     	# load '/'

			beq     $t2, $t5, add_op    # if operator is '+', branch to add_op
			beq     $t2, $t6, sub_op    # if operator is '-', branch to sub_op
			beq     $t2, $t7, mul_op    # if operator is '*', branch to mul_op
			beq     $t2, $t8, div_op    # if operator is '/', branch to div_op

			la      $a0, error          # otherwise, print error message
			li      $v0, 4
			syscall
			b       _end

add_op:   	add 	$s2,$s0,$s1		# operand1 + operand2
        	jr 		$ra				# return from subroutine 
        	
sub_op:  	sub 	$s2,$s0,$s1		# operand1 - operand2
			jr 		$ra				# return from subroutine 


mul_op:		mul     $s2, $s0, $s1       # operand1 * operand2
			jr      $ra                 # return from subroutine

div_op:
			beq     $s1, $zero, div_errorL   # branch to error label
			div     $s0, $s1				 # operand1 / operand2
			mflo    $s2						 # store quotient in $s2
			jr      $ra 					 # return from subroutine

div_errorL:
			la      $a0, div_error      # load div_error
			li      $v0, 4				# print error
			syscall
			b       _end                # program exit

print: 		la 		$a0,sol    		# load "Answer = " to $a0
			li 		$v0,4			# print "="
			syscall
			move    $a0, $s2        # move result to $a0
			li      $v0, 1          # integer print syscall
			syscall
			jr 		$ra				# return from subroutine  
