; *****************************************************************
;  Name: Natnael Gebremariam 
;  NSHE ID: 5002150850
;  Section: 1003
;  Assignment: 8
;  Description: using assembly functions to do basic stats such as ave, sum, min, and max


; -----------------------------------------------------------------
;  Write some assembly language functions.

;  The function, shellSort(), sorts the numbers into descending
;  order (large to small).  Uses the shell sort algorithm from
;  assignment #7 (modified to sort in descending order).

;  The function, basicStats(), finds the minimum, median, and maximum,
;  sum, and average for a list of numbers.
;  Note, the median is determined after the list is sorted.
;	This function must call the lstSum() and lstAvergae()
;	functions to get the corresponding values.
;	The lstAvergae() function must call the lstSum() function.

;  The function, linearRegression(), computes the linear regression of
;  the two data sets.  Summation and division performed as integer.

; *****************************************************************

section	.data

; -----
;  Define constants.

TRUE		equ	1
FALSE		equ	0

; -----
;  Local variables for shellSort() function (if any).



; -----
;  Local variables for basicStats() function (if any).


; -----------------------------------------------------------------

section	.bss

; -----
;  Local variables for linearRegression() function (if any).

qSum		resq	1
dSum		resd	1


; *****************************************************************

section	.text

; --------------------------------------------------------
;  Shell sort function (form asst #7).
;	Updated to sort in descending order.

; -----
;  HLL Call:
;	call shellSort(list, len)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi

;  Returns:
;	sorted list (list passed by reference)

global	shellSort
shellSort:

;need to read first argument into rdi 
;	YOUR CODE GOES HERE
	

mov eax, 1            ;h
mov ebx, 3            ; constant
mov r8, 0            ;i
mov r9, 0            ;tmp
mov r10, 0        ;index
mov r11, 0            ; j
; mov rdi, lst
; mov rsi, 200            ; index
loop1:
    imul ebx        ; h = 1;
    inc eax            ; while ( (h*3+1) < length ) {
    cmp eax, esi    ; h = 3 * h + 1;
    jl loop1        ; }
    dec eax
    cdq
    idiv ebx        ;back track one iteration
; loop1 good    

loop2:                ; while(h>0)
	cmp eax, 0
	jle done
;**********outsideLoop****************


mov r8d, eax            ;i=h-1
dec r8d    

loop3:                            ;for(i=h-1; i<length; i++)
    cmp r8d, esi                ;i<length
    jge loop6
    mov r10, r8                    ; set i as our index
    mov r9d, dword[rdi+r10*4]     ;tmp = lst[i]
    mov r11d, r8d                ; j=i

;******2ndOutsideLoopDone*************
loop4:
    cmp r11d, eax               ;j>=h
    jl loop5
    mov r10, r11
    sub r10, rax                ; set index to j-h
    cmp dword[rdi+r10*4], r9d   ;;lst[j-h] > tmp
    jge loop5                   ;switched to lst[j-h] < tmp
;********3rdLoop****************
    mov r12d, dword[rdi+r10*4]
    mov dword[rdi+r11*4], r12d  ;;lst[j] = lst[j-h]
;********3rdLoop****************
    sub r11d, eax               ;j = j-h
    jmp loop4

;******2ndOutsideLoopDone*************
    loop5:
    mov r10, r11            ; set index to j
    mov dword[rdi+r10*4], r9d ;a[j] =tmp
    inc r8d                    ;i++
    jmp loop3

;**********outsideLoop****************
loop6:
cdq                
idiv ebx                ; h=h/3
jmp loop2                ; loop if h>0
done:

	
	ret

; --------------------------------------------------------
;  Find basic statistical information for a list of integers:
;	minimum, median, maximum, sum, and average

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum() and lstAvergae() functions
;  to get the corresponding values.

;  Note, assumes the list is already sorted.

; -----
;  Call:
;	call basicStats(list, len, min, med, max, sum, ave)

;  Arguments Passed:
;	1) list, addr - rdi
;	2) length, value - rsi
;	3) minimum, addr - rdx
;	4) median, addr - rcx
;	5) maximum, addr - r8
;	6) sum, addr - r9
;	7) ave, addr - stack, rbp+16

;  Returns:
;	minimum, median, maximum, sum, and average
;	via pass-by-reference (addresses on stack)

global basicStats
basicStats:


;	YOUR CODE GOES HERE
	push rbp 
	mov rbp, rsp 
	push r12  
	 
	;min, max, and median 
	;********************************
	mov eax, dword[rdi] ;lst 
	mov dword[r8], eax ;first elemnt in lst = r8 max 
	;min and max book 
	mov r12, rsi 			;set len to r12 
	dec r12					; -1 one from last value 
	mov eax, dword[rdi +(r12*4)]  ;move to eax, the last value 
	mov dword[rdx], eax 		;mov said value to rdx as min 
	;mov eax, dword[rdi + (rsi-1) * 4]
	;mov dword[rdx], eax      ;min is rdx 
	 
	;med book 
	mov r14, rdx     ;min to rdx 
	mov r15, 2 		; r15 to / 2 
	mov eax, esi 	; len to eax 
	cdq 				
	idiv r15d 		;len / 2 
	mov r12, 0		; new reg to hold answer 
	mov r12d, eax 	;
	cmp edx, 0      ; if even jmp  
	je evenMed
	cmp edx, 1       ;if odd jmp 
	je oddMed 

	evenMed: 
	mov eax, dword[rdi + (r12)*4]     ;this will be med 
	add eax, dword[rdi + (r12-1)*4]   ;this will be med + med - 1 
	cdq     
	idiv r15d					 	;div by 2 
	jmp Done

	oddMed: 
	mov eax, dword[rdi + (r12)*4]		;odd med into eax 

	Done: 
	mov dword[rcx], eax 				;eax into med val 
	mov rdx, r14  						;place back into reg 
	
	;this should do sum function 
	call lstSum
	mov dword[r9], eax 
	
	;call ave function 
	mov r12, 0 
	call lstAve
	mov r12, qword[rbp+16]
	mov dword[r12], eax 
	;mov dword[rbp +16], eax 

	;min, max, and median 
	;********************************
	;mov eax, dword[rdi] ;lst 
	;mov dword[r8], eax ;first elemnt in lst = r8 max 
	;mov eax, dword[rdi + (rsi-1) * 4]
	;mov dword[rdx], eax      ;min is rdx 
	 

	;mov r14, rdx 
	;mov r15, 2 
	;mov eax, esi 
	;cdq 
	;idiv r15d 
	;mov r13, 0
	;mov r13d, eax 
	;cmp edx, 0 
	;je evenMed
	;cmp edx, 1
	;je oddMed 

	;evenMed: 
	;mov eax, dword[rdi + (r13)*4]
	;add eax, dword[rdi + (r13-1)*4]
	;cdq
	;idiv r15d 
	;jmp Done

	;oddMed: 
	;mov eax, dword[rdi + (r13)*4]

	;Done: 
	;mov dword[rcx], eax 
	;mov rdx, r14  


	pop r12 
	pop rbp 
	ret

; --------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	sum (in eax)


global	lstSum
lstSum:


;	YOUR CODE GOES HERE
	; sum register in ax  
	push rbp 
	mov rbp, rsp 
	push r12 
	 

	mov r12, 0  
	mov rax, 0    ;lenght count 
	sumLoop: 
		add eax, dword[rdi +(r12*4)]
		inc r12 
		cmp r12, rsi  
		jl sumLoop

		;;mov r12, qword[rbp + 16]
		;;mov dword[]

	;rax has the sum vlaue  
	
	pop r12 
	pop rbp 
	ret

; --------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(lst, len)

;  Arguments Passed:
;	1) list, address - rdi
;	1) length, value - rsi

;  Returns:
;	average (in eax)


global	lstAve
lstAve:


;	YOUR CODE GOES HERE

	push rbp 
	mov rbp, rsp 
	push r12 
	
		

	;mov ebx, esi  ;to save the length 
	call lstSum   ;has eax via rax 
	cdq 
	idiv rsi 	;div by len 
	;mov r12, qword[rbp+16]
	;mov dword[r12], eax  
	;mov eax, dword[r12]


	pop r12 
	pop rbp 
	ret

; --------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).
;  Due to the data sizes, the summation for the dividend (top)
;  MUST be performed as a quad-word.

; -----
;  Call:
;	linearRegression(xList, yList, len, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - edx
;	4) xList average, value - ecx
;	5) yList average, value - r8d
;	6) b0, address - r9
;	7) b1, address - stack, rpb+16

;  Returns:
;	b0 and b1 via reference

global linearRegression
linearRegression:


;	YOUR CODE GOES HERE


	ret

; ********************************************************************************

