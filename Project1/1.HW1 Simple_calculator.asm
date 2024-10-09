###################################
#  HW1: Simple string calculator  #
###################################
#
#  Data segment
#
		.data
input:		.asciiz  "Enter input (e.g. 1+2): "	# accept input expression
error:		.asciiz  "Input error!" 
sol:    	.asciiz  "Answer = "	# label for "Anmswer: " 
plus: 		.asciiz  "+"		# label for "+"
minus:		.asciiz  "-"		# label for "-"
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
		
		jal load_input		# load operand1, 2, operator
		jal	operator		# decide operation
		jal	print			# print result
		
_end:	li 	$v0,10      	# system call for exit       
        syscall   			# EXIT!
		
#
#  Subroutine to load operands & operator, and to print the result 
#

load_input:	lb		$t1,1($a0)     	# load operator to $t1
			lb 		$s0,0($a0)		# load operand 1 to $s0	
			addi 	$s0,$s0,-48 	# ascii to integer          
			lb 		$s1,2($a0)		# load operand 2 to $s1
			addi 	$s1,$s1,-48		# ascii to integer
			jr   	$ra				# return from subroutine    
		 		         
operator:	lb 		$t5,plus		# load "+" to $t5
			lb		$t6,minus		# load "-" to $t5
			beq 	$t1,$t5,add_op	# goto add operation  
			beq 	$t1,$t6,sub_op	# goto sub operation  
			la 		$a0,error    	# print
			li 		$v0,4			# "Input error"
			syscall
			b		_end

add_op:   	add 	$s2,$s0,$s1		# operand1 + operand2
        	jr 		$ra				# return from subroutine 
        	
sub_op:  	sub 	$s2,$s0,$s1		# operand1 - operand2
			jr 		$ra				# return from subroutine 

print: 		la 		$a0,sol    		# load "=" to $a0
			li 		$v0,4			# print "="
			syscall
			la 		$a0,0($s2)  	# load result to $a0
			li 		$v0,1       	# print result		
			syscall
			jr 		$ra				# return from subroutine 

