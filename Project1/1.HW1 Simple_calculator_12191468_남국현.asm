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
multiple:   .asciiz  "*"    # 곱셈 기호
divider:    .asciiz  "/"    # 나눗셈 기호
div_error:	.asciiz	 "0으로 나눌 수 없습니다." # 예외 추가
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
		la	$t0, exp		# exp의 base address load
		jal load_input		# load operand 1, 2, operator
		jal signchecker	
		jal check_s4
		jal	operator		# decide operation
		jal	print			# print result
		
_end:	li 	$v0,10      	# system call for exit       
        syscall   			# EXIT!
		
#
#  Subroutine to load operands & operator, and to print the result 
#

	
load_input: addi 	$sp, $sp, -4	# 스택에 공간 확보 
			sw 		$ra, 0($sp)		# $ra 값을 스택에 저장
			li      $s0, 0          # 첫 번째 피연산자 초기화
        	li      $s1, 0          # 두 번째 피연산자 초기화

			jal 	op1comp			# 음수 여부 확인하는 서브루틴
			jal 	op1				# op1 subroutine
			
			lb 		$t2, 0($t0)		# load operator to $t2
			addi	$t0, $t0, 1		# 다음 주소로

			jal 	op2comp    		# 음수 여부 확인하는 서브루틴  
			jal 	op2				# op2 subroutine

			lw 		$ra, 0($sp)		# 스택에서 $ra 값 복원
			addi 	$sp, $sp, 4		# 스택 포인터 복원
			jr   	$ra				# return from subroutine    
op1comp:
			lb      $t1, 0($t0)         # 현재 문자 로드
			lb      $t2, minus          # '-' 문자 로드
			beq     $t1, $t2, op1_neg   # '-'이면 음수 처리로 분기
			li      $s3, 0              # 양수 부호 플래그 설정
			jr      $ra                 # load_input으로 복귀

op1_neg:
			li      $s3, 1              # 음수 부호 플래그 설정
			addi    $t0, $t0, 1         # 다음 문자로 이동
			jr      $ra                 # load_input으로 복귀

op2comp:
			lb      $t1, 0($t0)         # 현재 문자 로드
			lb      $s5, minus          # '-' 문자 로드
			beq     $t1, $s5, op2_neg   # '-'이면 음수 처리로 분기
			li      $s4, 0              # 양수 부호 플래그 설정
			jr      $ra                 # load_input으로 복귀

op2_neg:
			li      $s4, 1              # 음수 부호 플래그 설정
			addi    $t0, $t0, 1         # 다음 문자로 이동
			jr      $ra                 # load_input으로 복귀
op1:		lb		$t1,0($t0)     	# 현재 문자 load
			beq     $t1, '\n', end_op   # 개행 문자 처리
			beq     $t1, '\0', end_op   # 널 종결자 처리
			li		$t3, '0'		# ASCII '0' = 48	
			li		$t4, '9'		# ASCII	'9' = 57
			# $t1 > 57 && $t1 < 48이면 숫자가 아니다.
			blt     $t1, $t3, end_op
    		bgt     $t1, $t4, end_op
			
			# 숫자일 경우
			addi 	$t1, $t1, -48 	# ASCII -> 숫자 변환
			mul		$s0, $s0, 10	# 자리수 증가
			add     $s0, $s0, $t1	# 현재 숫자 더함
			addi	$t0, $t0, 1		# 다음 문자로 이동
			j 		op1

op2:		lb		$t1,0($t0)     	# 현재 문자 load
			beq     $t1, '\n', end_op   # 개행 문자 처리
			beq     $t1, '\0', end_op   # 널 종결자 처리
			li		$t3, '0'		# ASCII '0' = 48	
			li		$t4, '9'		# ASCII	'9' = 57
			# $t1 > 57 && $t1 < 48이면 숫자가 아니다.
			blt     $t1, $t3, error
    		bgt     $t1, $t4, error
			
			# 숫자일 경우
			addi 	$t1, $t1, -48 	# ASCII -> 숫자 변환
			mul		$s1, $s1, 10	# 자리수 증가
			add     $s1, $s1, $t1	# 현재 숫자 더함
			addi	$t0, $t0, 1		# 다음 문자로 이동		
			j 		op2

end_op: 	jr $ra

signchecker:
    		bne     $s3, $zero, neg_op1   # $s3 != 0이면 neg_op1으로 분기 (음수이면)
			jr		$ra
check_s4:
    		bne     $s4, $zero, neg_op2   # $s4 != 0이면 neg_op2로 분기 (음수이면)
			jr		$ra					 # main으로 복귀

neg_op1: 	neg		$s0, $s0
			jr		$ra
			
neg_op2: 	neg		$s1, $s1
			jr 		$ra				 # main으로 복귀

operator:	lb 		$t5, plus		# load "+" to $t5
			lb		$t6, minus		# load "-" to $t6
			lb      $t7, multiple    # '*' 로드
			lb      $t8, divider     # '/' 로드

			beq     $t2, $t5, add_op    # '+'이면 add_op로 분기
			beq     $t2, $t6, sub_op    # '-'이면 sub_op로 분기
			beq     $t2, $t7, mul_op    # '*'이면 mul_op로 분기
			beq     $t2, $t8, div_op    # '/'이면 div_op로 분기

			la      $a0, error          # 그 외에는 오류 메시지 출력
			li      $v0, 4
			syscall
			b       _end

add_op:   	add 	$s2,$s0,$s1		# operand1 + operand2
        	jr 		$ra				# return from subroutine 
        	
sub_op:  	sub 	$s2,$s0,$s1		# operand1 - operand2
			jr 		$ra				# return from subroutine 


mul_op:		mul     $s2, $s0, $s1       # operand1 * operand2
			jr      $ra                 # 서브루틴 종료

div_op:
			beq     $s1, $zero, div_errorL   # 에러 레이블로 분기
			div     $s0, $s1				 # operand1 / operand2
			mflo    $s2						 
			jr      $ra

div_errorL:
			la      $a0, div_error      # load div_error
			li      $v0, 4				# error 출력
			syscall
			b       _end                # 프로그램 종료

print: 		la 		$a0,sol    		# load "=" to $a0
			li 		$v0,4			# print "="
			syscall
			move    $a0, $s2        # 결과 값을 $a0로 이동
			li      $v0, 1          # 정수 출력 syscall
			syscall
			jr 		$ra				# return from subroutine 
