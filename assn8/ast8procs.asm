; *****************************************************************
;  Name: Marlon Alejandro
;  NSHE ID: 5002573038
;  Section: 1003
;  Assignment: 8
;  Description:functions with assembly


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
q2Sum		resq	1


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
;*********************************************************
global	shellSort
shellSort:

mov eax, 1			;h
mov ebx, 3			; constant
mov r8, 0			;i
mov r9, 0			;tmp
mov r10, 0		;index
mov r11, 0			; j
; mov rdi, lst
; mov rsi, 200			; index
loop1:
	imul ebx		; h = 1;
	inc eax			; while ( (h*3+1) < length ) {
	cmp eax, esi	; h = 3 * h + 1;
	jl loop1		; }
	dec eax
	cdq
	idiv ebx		;back track one iteration
; loop1 good	

loop2:				; while(h>0)
cmp eax, 0
jle done
;**********outsideLoop****************


mov r8d, eax			;i=h-1
dec r8d	

loop3:							;for(i=h-1; i<length; i++)
	cmp r8d, esi				;i<length
	jge loop6
	mov r10, r8					; set i as our index
	mov r9d, dword[rdi+r10*4] 	;tmp = lst[i]
	mov r11d, r8d				; j=i

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
	mov r10, r11			; set index to j
	mov dword[rdi+r10*4], r9d ;a[j] =tmp
	inc r8d					;i++
	jmp loop3

;**********outsideLoop****************
loop6:
cdq				
idiv ebx				; h=h/3
jmp loop2				; loop if h>0
done:


;*********************************************************
;	YOUR CODE GOES HERE


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

	push rbp 
	mov rbp, rsp 
	push r15
	push r14
	push r13
	push r12

	 
;******************min/max**************
mov r14d, dword[rdi]
mov dword[rdx], r14d
mov r14d, dword[rdi+(rsi-1)*4] 
mov dword[r8], r14d
;************mean*******************


mov r15, rdx
mov r14d, 2
mov eax, esi
cdq
idiv r14d
mov r13,0
mov r13d, eax
cmp edx, 0
je evenMed
cmp edx,1
je  oddMed

evenMed:
mov eax, dword[rdi+(r13)*4]
add eax, dword[rdi+(r13-1)*4]
cdq
idiv r14d
jmp fin

oddMed:
mov eax, dword[rdi+(r13)*4]

fin:
mov dword[rcx], eax
mov rdx, r15
;********************************************

call lstSum
mov dword[r9], eax

mov r12, 0 
call lstAve
mov r12, qword[rbp+16]
mov dword[r12], eax 

;	YOUR CODE GOES HERE

    push r15
	push r14
	push r13
	push r12
	pop r12
	pop r13
	pop r14
	pop r15
	mov rsp, rbp
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

;rdi - address
;rsi - length

push rbp 
mov rbp, rsp 
push r15

mov r15, 0                 ;amout of iterations
mov rax, 0                          ;intialize sum as 0
sumLstLoop: 
    add eax, dword[rdi+(r15*4)]     ;adds each element to our sum register
    inc r15d                         ;increament index 
    cmp r15d, esi
    jne sumLstLoop                 ;loops until end of array

pop r15 
mov rsp, rbp 
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
	push rbp 
	mov rbp, rsp 
	push r12 

mov r12, rdx
call lstSum 
; mov r15, 0                 ;amout of iterations
; mov rax, 0                          ;intialize sum as 0
; sumLstLoop2: 
;     add eax, dword[rdi+(r15*4)]     ;adds each element to our sum register
;     inc r15d                         ;increament index 
;     cmp r15d, esi
;     jne sumLstLoop2                 ;loops until end of array
; ;*****************
cdq
idiv esi
mov rdx, r12

	pop r12 
;r12
	pop rbp 
;	YOUR CODE GOES HERE


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
	push rbp 
	mov rbp, rsp 
	mov rbx, rdx			;holds length
	push r12

mov qword[qSum], 0
mov qword[q2Sum], 0
mov r15, 0                 ;amout of iterations
mov r14,0					;xi-xave
mov r13,0					;yi-yave
mov r11,0					;(xi-xave)^2
mov r12, qword[rbp+16]
mov rax, 0                          ;intialize sum as 0

linRegLoop: 
    mov eax, dword[rdi+(r15*4)]    
	sub rax, rcx					;eax=xi-xave

	mov r13d, dword[rsi+(r15*4)]
	sub r13d, r8d					;r13d=yi-yave

	imul r13d
	movsxd rax, eax
	mov r14, rax					;eax/r14d=sum((xi-xave)(yi-yave))
	add qword[qSum], r14

	mov eax, dword[rdi+(r15*4)]		; eax= xi
	sub rax, rcx					;eax=xi-xave
	imul rax						
	mov r11, rax					; r11d= sum((xi-xave)^2)
	add qword[q2Sum], r11

    inc r15                         ;increament index 
    cmp r15d, ebx
    jne linRegLoop                 ;loops until end of array

	mov rax, qword[qSum]					; eax= sum((xi-xave)(yi-yave))
	cqo
	mov r11,qword[q2Sum]
	idiv r11						;eax= sum((xi-xave)(yi-yave))/sum((xi-xave)^2)
	mov dword[r12], r14d

	imul rcx
	mov r15d, eax
	mov eax,r8d
	sub eax, r15d
	mov dword[r9], eax	



	mov rdx, rbx 
	pop r12
	pop rbp 
;****************************
   ;; ; (x - avX ) (y -avY) /(x -Avex)^2 

    ; push rbp
	; mov rsp, rbp

    ; movsxd r8, r8d     ;a = while i =0 and len -1 
    ; ; yvae 
    ; mov r10d, ecx   ;xave 
    ; movsxd rcx, edx   ;length 
    ; mov dword[dSum], 0
    ; mov qword[qSum], 0  
    ; loopReg:
    ;     mov eax, dword[rdi + ((rcx-1) * 4)]  ;x 
    ;     sub eax, r10d 
    ;     mov r11d, eax    ;temp hold 
    ;     imul eax         ;x^2 
    ;     add dword[dSum], eax   ;(x - xave)

    ; ;loopYavY: 
    ;     movsxd r14, dword[rsi +((rcx-1)*4)]  ;y 
    ;     sub r14, r8              ; y - yav 

    ;     movsxd rax, r11d   ;x-xav  break it down intp two cases 
    ;     imul r14 
    ;     add qword[qSum], rax   ;this is the x-xav * y - yav 
    ;     loop loopReg    ;cmp rcx jmp loopYavY 
    ;     ;cmp rcx, 0 
    ;     ;jne loop1
        
    ;     ;mov qword[tempVar], 0     ; temp to use 

    ; ;solveforB1: 
    ;     mov rax, qword[qSum]        ;re use x-xav * y-yav 
    ;     movsxd r15, dword[dSum]    ;temp hold 
    ;     idiv r15                    ;div divaden with divisor 
    ;     mov r15, qword[rbp + 16]    ;use a non call reg 
    ;     ;jmp solveforB0 

    ; ;solveforB0: 
    ;     mov dword[r15], eax 
    ;     imul r10d          ;mul b1 with y 
    ;     sub r8d, eax     ;sub to get b0 
    ;     ;jmp solveforB1
        
    ;     mov dword[r9], r8d 
    ;     ;jmp Done 
    ; ;Done: 
    
    ; ;mov rsp, rbp
    ; ;pop r12 
    ; pop rbp 
;***************************
	
;	YOUR CODE GOES HERE


	ret

; ********************************************************************************