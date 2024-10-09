#
# Define integer array of size 8, print out first five elements
#
#################################################
#               data segment                    #
#################################################
			.data
array:		.word   7, 93, 31, 2, 61, 3, 5, 89 		#  define array elements
str:		.asciiz "\nThe array= "           		#  defining string to be printed
one_blank:	.asciiz " "
        	.globl   main

#################################################
#               text segment                    #
#################################################
		.text
main:				 			# print “The array=“ string
        li		$v0, 4			# code for string print
        la		$a0, str		# load address of the string
        syscall            		# call for OS service
		la		$t0, array		# setting up the print loop
        li		$t1, 0     		# to begin at element 1
        li		$t2, 5       	# to stop at element  5
loop:    	 					# loop body
        li 		$v0, 1    		# system call #1 to print integer
        lw		$a0, ($t0)
        syscall
        li		$v0, 4     		# code for string print
        la		$a0, one_blank	# append a blank/space character
        syscall         
        addi	$t0, $t0, 4  	# go to next elements location
        addi	$t1, $t1, 1   	# increment index counter by 1
        bgt		$t2, $t1, loop	# if t2 > t1 then goto 'loop'
_end:     						# Exit
        li		$v0, 10         # code for end of execution
           		syscall         # au revoir

