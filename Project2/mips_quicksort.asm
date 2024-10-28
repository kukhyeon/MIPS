#############################################################
#     HW2: Quicksort to sort numbers in increasing order    #
#     ID: 12191468                                          #
#     Name:남국현                                           #
#############################################################

#
#  Data segment
#
	.data
	count:		.word 0							# number of elements in integer array
	array: 		.word 0:40						# data buffer for integer array
	input:		.space 64						# buffer for input string
	message1: 	.asciiz "Enter numbers be sorted (e.g., 23 103 69 932): "	# output message 1
	message2:	.asciiz "Sorted output: "				# output message 2
	space:   	.asciiz " "         					# spacebar ascii   
	newline:    .asciiz "\n"

	
#
#  Text segment
#
	.text
#
#  main 
#
main:    
	add 	$t6,$zero, $zero 		# number of elements to sort
	jal		data_input      		# input from keyboard 
	la		$t0, input				# $t0 = &input[0]
	li		$s0, 0					# $s0는 다음 서브루틴에서 임시로 사용할 register
	la 		$s6, array				# $s6 = &array[0]
	jal		acsii_2_int     		# call ascii2int to convert string (ascii) to integer
	la		$s5, array 				# $s5 = &array[0]
	sll  	$t7, $t6, 2				# 원소 개수 * 4byte
	add		$s6, $s5, $t7			# $s6 = &array[4*t7]
	move	$a0, $s5				# 시작 주소
	addi	$a1, $s6, -4			# 끝 주소
	add	$s0, $zero, $zero
	add	$s1, $zero, $zero
	add	$s2, $zero, $zero
	jal		quick_sort      		# quick sort algorithm
	jal		print         			# print array 
	li		$v0, 10         		# system exit
	syscall
		
	#
	#  Read input data 
	# $t6
data_input:
	la 		$a0,message1  	# print 
	li 		$v0,4			# "Enter numbers be sorted (e.g. 23 103 69 932):"
	syscall
	la 		$a0,input		# load input buffer from keyboard         
	li  	$a1,64			# max string length = 64 
	li 		$v0,8 	    	# read string
	syscall
	jr 		$ra				# return
	
#
#  Parse and store input data 
#	$t0, $t6, $s0, $s6
acsii_2_int:
	lb 		$t1, 0($t0)		# $t1 = *input[n]
	beq     $t1, '\0', end_parse  # 문자열의 끝을 만나면 종료
	beq	 	$t1, '\n', end_parse 	# '\n'를 만나면 stop
	beq		$t1, ' ', next_int	# 공백을 만난다는 것은 한 요소의 정수 처리가 끝났다는 것
	addi 	$t1, $t1, -48	# ASCII -> number 변환
	mul		$s0, $s0, 10	# 자릿수 증가
	add		$s0, $s0, $t1	# *s0에 현재 숫자로 변환된 한 자리 정수를 더함	 
	addi	$t0, $t0, 1		# 다음 문자열 파싱
	j		acsii_2_int		# 반복한다		
end_parse:
	sw 		$s0, 0($s6)		# 마지막 원소 저장
	addi	$t6, $t6, 1		# 원소 개수 하나 추가
	jr 		$ra		

next_int:
	sw		$s0, 0($s6)		# 정수 array에 값 저장
	mul		$s0, $s0, 0		# 자릿수 및 저장된 수 초기화
	addi	$s6, $s6, 4		# array의 다음 위치로 포인터 이동 (word 단위)
	addi 	$t6, $t6, 1		# 원소 개수 하나 추가
    addi    $t0, $t0, 1     # input의 다음 위치로 포인터 이동 (byte 단위)
	j 		acsii_2_int		# 원 레이블로 복귀
#
#  quick sort function  
#  $s5 = array의 맨 첫번째 원소, $s6 = array의 맨 마지막 원소, $t6 = 원소의 개수
# 
quick_sort:
    # 함수 시작: 스택에 레지스터 저장
    addi    $sp, $sp, -16     # 스택 공간 확보
    sw      $ra, 12($sp)      # 반환 주소 저장
    sw      $s0, 8($sp)       # $s0 저장
    sw      $s1, 4($sp)       # $s1 저장
    sw      $s2, 0($sp)       # $s2 저장

    # 인자 설정
    move    $s0, $a0          # $s0 = Left 포인터
    move    $s1, $a1          # $s1 = Right 포인터

    # 종료 조건 확인
    bge     $s0, $s1, quick_sort_end

    # Pivot 선택 (시작 주소의 값 사용)
    lw      $s2, 0($s0)       # $s2 = Pivot 값

    # Partition 과정
    move    $t1, $s0          # $t1 = i
    move    $t2, $s1          # $t2 = j

partition_loop:
    # Left 포인터 이동
partition_left:
    lw      $t3, 0($t1)       # $t3 = *left
    blt     $t3, $s2, partition_left_increment # *left < pivot이면 증가
    j       partition_left_done # *left >= pivot이면 끝
partition_left_increment:
    addi    $t1, $t1, 4       # i += 1
    ble     $t1, $t2, partition_left # &left <= &right면 다시 반복
partition_left_done:
    # Right 포인터 이동
partition_right:
    lw      $t4, 0($t2)       # $t4 = *right
    bgt     $t4, $s2, partition_right_decrement # *right > pivot이면 증가
    j       partition_right_done # *right <= pivot이면 끝
partition_right_decrement:
    addi    $t2, $t2, -4      # j -= 1
    ble     $t1, $t2, partition_right # &left <= &right면 다시 반복
partition_right_done:

    # 포인터가 교차했는지 확인
    ble     $t1, $t2, swap
    j       partition_end

swap:
    # Swap(array[i], array[j])
    lw      $t3, 0($t1)
    lw      $t4, 0($t2)
    sw      $t4, 0($t1)
    sw      $t3, 0($t2)

    # 포인터 이동
    addi    $t1, $t1, 4       # i += 1
    addi    $t2, $t2, -4      # j -= 1

    j       partition_loop

partition_end:
    # Left 부분 배열 정렬
    blt     $s0, $t2, quick_left_sort
    # 시작 주소 >= 끝 주소이면 재귀 호출 생략
    j       check_right_subarray
quick_left_sort:
    move    $a0, $s0          # 시작 주소
    move    $a1, $t2          # 끝 주소
    jal     quick_sort

check_right_subarray:
    # Right 부분 배열 정렬
    blt     $t1, $s1, quick_right_sort
    # 시작 주소 >= 끝 주소이면 재귀 호출 생략
    j       quick_sort_end
quick_right_sort:
    move    $a0, $t1          # 시작 주소
    move    $a1, $s1          # 끝 주소
    jal     quick_sort

quick_sort_end:
    # 레지스터 복원 및 함수 종료
    lw      $s2, 0($sp)       # $s2 복원
    lw      $s1, 4($sp)       # $s1 복원
    lw      $s0, 8($sp)       # $s0 복원
    lw      $ra, 12($sp)      # $ra 복원
    addi    $sp, $sp, 16      # 스택 포인터 복원
    jr      $ra               # 복귀
		
#
#  Print function 
#
print:
    la      $t0, array        # 배열의 시작 주소
    li      $t1, 0            # 인덱스 초기화
print_loop:
    bge     $t1, $t6, print_end   # 모든 원소를 출력하면 종료

    # 배열의 원소를 로드하여 출력
    lw      $a0, 0($t0)
    li      $v0, 1            # print integer
    syscall

    # 공백 출력
    la      $a0, space
    li      $v0, 4            # print string
    syscall

    # 다음 원소로 이동
    addi    $t0, $t0, 4       # 주소 증가
    addi    $t1, $t1, 1       # 인덱스 증가
    j       print_loop

print_end:
    # 줄 바꿈 출력
    la      $a0, newline
    li      $v0, 4            # print string
    syscall
    jr      $ra
		
