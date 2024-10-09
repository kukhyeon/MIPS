#
# Define integer array of size 8, print out first five elements
#
#################################################
#               data segment                    #
#################################################
			.data
enter0:	.asciiz	"\nEnter value= " 	# string for user-input
		.globl	main

#################################################
#               text segment                    #
#################################################
		.text
main:
		li 		$v0, 0				#  initializing $v0
		li 		$t0, 50				#  initializing $t0 with compare-value
while:
        la 		$a0, enter0	 		#  load base address of string into $a0
        li 		$v0, 4 		 		#  set $v0 to 4, this tells syscall to print text string specified by $a0
        syscall		   		 		#  now print “Enter value” string to console
        li 		$v0, 5 		 		#  set $v0 to 5, this tells syscall to read an integer from the console
        syscall		   		 		#  now read the integer: user value will be in $v0 after the syscall
        bgt 	$v0, $t0, endwhile
        add 	$a0, $v0, $zero		#  now, $a0 gets an integer to print
        li 		$v0, 1          	#  set $v0 to 1, this tells syscall to print integer in $a0
        syscall              		#  now print entered integer string to console
        b		while
endwhile:
_end:      							#  exit
        li 		$v0, 10         	#  code for end of execution
        syscall                 	#  au revoir
