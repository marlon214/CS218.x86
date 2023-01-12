; *****************************************************************
;  Name: Natnael Gebremariam 
;  NSHE ID: 5002150850
;  Section: 1003 
;  Assignment: 9
;  Description: learning to read data from main using assembly 

; -----------------------------------------------------------------------------
;  Write assembly language functions.

;  Function, shellSort(), sorts the numbers into ascending
;  order (small to large).  Uses the shell sort algorithm
;  modified to sort in ascending order.

;  Function lstSum() to return the sum of a list.

;  Function lstAverage() to return the average of a list.
;  Must call the lstSum() function.

;  Fucntion basicStats() finds the minimum, median, and maximum,
;  sum, and average for a list of numbers.
;  The median is determined after the list is sorted.
;  Must call the lstSum() and lstAverage() functions.

;  Function linearRegression() computes the linear regression.
;  for the two data sets.  Must call the lstAverage() function.

;  Function readSeptNum() should read a septenary number
;  from the user (STDIN) and perform apprpriate error checking.


; ******************************************************************************

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  Define program specific constants.

SUCCESS 	equ	0
NOSUCCESS	equ	1
OUTOFRANGEMIN	equ	2
OUTOFRANGEMAX	equ	3
INPUTOVERFLOW	equ	4
ENDOFINPUT	equ	5

LIMIT		equ	1510

MIN		equ	-100000
MAX		equ	100000

BUFFSIZE	equ	50			; 50 chars including NULL


; -----
;  NO static local variables allowed...


; ******************************************************************************

section	.text

; -----------------------------------------------------------------------------
;  Read an ASCII septenary number from the user.

;  Return codes:
;	SUCCESS			Successful conversion
;	NOSUCCESS		Invalid input entered
;	OUTOFRANGEMIN		Input below minimum value
;	OUTOFRANGEMAX		Input above maximum value
;	INPUTOVERFLOW		User entry character count exceeds maximum length
;	ENDOFINPUT		End of the input

; -----
;  Call:
;	status = readSeptNum(&numberRead);

;  Arguments Passed:
;	1) numberRead, addr - rdi

;  Returns:
;	number read (via reference)
;	status code (as above)


;	YOUR CODE GOES HERE
global readSeptNum
readSeptNum: 
    push rbp 
	mov rbp, rsp 
    sub rsp, 55 
    push rbx 
    push r15 
    push r12 
    push r13 

    ;read base 7 number from STDIN 
    ;use read character system service 
        ;check input length 
    ;perform error checking 
        ;valid characters 
    ;convert char input to int 
        ;range (min - max)
    ;return appropriate status lode 

	;might not need this, so keep it at 51 and not 54 
    mov dword[rbp - 54], 7 
    mov r12, rdi 

	;loop  to read user input 
	;lea gets you the address 
    lea rbx, byte[rbp - 50]
    mov r13, 0              ;index 
;read the char 
getChar: 
    mov rax, SYS_read
    mov rdi, STDIN
    lea rsi, byte[rbp - 55]
    ;mov rsi, rbp 
	;sub rsi, 55 
	mov rdx, 1 
    syscall 

	;if char is LF we exit the loop 
	mov al, byte[rbp - 55]
	cmp al, LF 
	je  inputDone

	;if (i < bbuffsize -1)
	cmp r13, BUFFSIZE-1 
	ja buffFull
	mov byte[rbx + r13], al  
	inc r13 			;i++ 

;if we reached max length of char 
buffFull: 
	jmp getChar

;if input is done 
;we check to see if input > buffersize => we set condition to exit 
inputDone: 	
	cmp r13, BUFFSIZE
	jbe checkInput				;need to check input 
	mov rax, INPUTOVERFLOW
	jmp readFunction            ;need do a read function too 
;after checking we havent gone past the end, we add the NULL 
checkInput: 
	mov byte[rbx + r13], NULL 
;correct input includes 0 or more space, +, -, and numbers from 0 t0 6 (no 7)
;if anything else other than that, set error code and you are done 



%macro	aSept2int	2
mov rbx, %1
mov rsi, 0  ;index 
mov rdi, 0  ;number index 
mov eax, 0  ;index set to zero 
mov r12d, 7 
mov r15d, 0 
%%startLoop: 
	;mov inot a db 
	cmp byte[rbx+ rsi], NULL
	je %%Done
	cmp byte[rbx+ rsi], " "
	je %%spaceLoop
	cmp byte[rbx+ rsi], "+"
	je %%plusLoop
	cmp byte[rbx+ rsi], "-"
	je %%negLoop 
	;look for empty space 

	movsx r15d, byte[rbx+ rsi]
	sub r15d, 0x30             ;sub 30 
	imul r12d 					;mul by 7 
	add eax, r15d 				

	inc rsi 
	cmp byte[rbx+ rsi], NULL
	je %%Done 
	jmp %%startLoop

;inc rsi till other then space
%%spaceLoop:
	inc rsi 
	jmp %%startLoop
;reached a plus sign, inc till something else 
%%plusLoop: 
	mov r11d, 1 
	inc rsi 
	jmp %%startLoop
;repear this till no more negLoop: 
%%negLoop:	
	mov r11d, -1
	inc rsi
	jmp %%startLoop	
;loop when null, checks rsi = 0 and lenght to do converstion 
%%Done: 
	imul r11d
	mov dword[%2], eax 

%endmacro




readFunction: 

;now performe error checking for valid character 

;then convert character input into inte
;make sure rnage is within min and max 
;return appropriate status lode 
;you can use the macto from as 6 or make inot a function 

     
     
   
    
    
    
    pop r13  
    pop r12 
    pop r15 
    pop rbx 
    mov rsp, rbp 
	pop rbp 
    ret 

; -----------------------------------------------------------------------------
;  Shell sort function.

; -----
;  HLL Call:
;	call shellSort(list, len)

;  Arguments Passed:
;	1) list, addr
;	2) length, value

;  Returns:
;	sorted list (list passed by reference)


;	YOUR CODE GOES HERE
global	shellSort
shellSort:
push rbx 
push r8 
push r9 
push r10 
push r11
push r12  

mov eax, 1            ;h
mov r8, 0            ;i
mov r11, 0            ; j
mov r9, 0            ;tmp
mov r10, 0        ;index
mov ebx, 3            ; cons			           
firstWhile:
    imul ebx        ; h = 1;
    inc eax            ; while ( h*3+1  < length ) {
    cmp eax, esi    ; h = 3 * inc h;
    jl firstWhile   ;jmp less then 
    dec eax
    cdq
    idiv ebx        ; --1

secondWhile:                ; while(h>0)
	cmp eax, 0
	jle done
;**********mainLoop being now ****************

mov r8d, eax            ;i=h
dec r8d    				;i=h-1 

firstFor:                            ;for(i=h-1; i<length; i++)
    cmp r8d, esi                ;cmp i<length
    jge lastLoop				;jmp grater or equal 
    mov r10, r8                    ; i is index
    mov r9d, dword[rdi+r10*4]     ;tmp = lst[i]
    mov r11d, r8d                ; j=i

;******first for loop is done *************
secondFor:
    cmp r11d, eax               ;cmp j >= h
    jl secondForCalc			;jmp if less then 
    mov r10, r11				;mov j 
    sub r10, rax                ; set index to j-h
    cmp dword[rdi+r10*4], r9d   ; lst[j-h] > tmp
    jle secondForCalc           ; lst[j-h] < tmp (changed from as7) (chnage to jle )
;********connects to second for loop calc****************
    mov r12d, dword[rdi+r10*4]	;move through lst j-h 
    mov dword[rdi+r11*4], r12d  ;set lst[j] = lst[j-h]
;********connects to second for loop calc++****************
    sub r11d, eax               ;j = j-h
    jmp secondFor				;unconditional jump 

;******second for loop will be done*************
    secondForCalc:
    mov r10, r11            ; index = j
    mov dword[rdi+r10*4], r9d ; set lst[j] =tmp 
    inc r8d                    ;inc i
    jmp firstFor				;jmp back to the first loop 

;**********final loop for calc and second for loop done****************
lastLoop:
cdq                		;div using eax from start of second loop or second loop calc 
idiv ebx                ; h=h/3
jmp secondWhile     ;second while            ; loop if h>0
done:

    pop r12 
    pop r11 
    pop r10 
    pop r9 
    pop r8 
    pop rbx 
	ret

; -----------------------------------------------------------------------------
;  Find basic statistical information for a list of integers:
;	minimum, median, maximum, sum, and average

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  This function must call the lstSum() and lstAvergae() functions
;  to get the corresponding values.

;  Note, assumes the list is already sorted.

; -----
;  HLL Call:
;	call basicStats(list, len, min, med, max, sum, ave)

;  Returns:
;	minimum, median, maximum, sum, and average
;	via pass-by-reference (addresses on stack)



;	YOUR CODE GOES HERE
global basicStats
basicStats:
    push rbp 
	mov rbp, rsp 
	push r12
	push r14 
	push r15   
	 
	;min, max, and median 
	;********************************
	mov eax, dword[rdi] ;lst 
	mov dword[r8], eax ;first elemnt in lst = r8 max 
	
	;min and max  
	mov r12, rsi 			;set len to r12 
	dec r12					; -1 one from last value 
	mov eax, dword[rdi +(r12*4)]  ;move to eax, the last value 
	mov dword[rdx], eax 		;mov said value to rdx as min 
	
	 
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

	
	pop r15 
	pop r14 
	pop r12 
	mov rsp, rbp 
	pop rbp 
	ret


; -----------------------------------------------------------------------------
;  Function to calculate the sum of a list.

; -----
;  Call:
;	ans = lstSum(lst, len)

;  Arguments Passed:
;	1) list, address
;	2) length, value

;  Returns:
;	sum (in eax)



;	YOUR CODE GOES HERE
global	lstSum
lstSum:
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
	mov rsp, rbp  
	pop rbp 
	ret
; -----------------------------------------------------------------------------
;  Function to calculate the average of a list.
;  Note, must call the lstSum() fucntion.

; -----
;  Call:
;	ans = lstAve(lst, len)

;  Arguments Passed:
;	1) list, address
;	2) length, value

;  Returns:
;	average (in eax)



;	YOUR CODE GOES HERE
global	lstAve
lstAve:
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
	mov rsp, rbp 
	pop rbp 
	ret

; -----------------------------------------------------------------------------
;  Function to calculate the linear regression
;  between two lists (of equal size).

; -----
;  Call:
;	linearRegression(xList, yList, len, xAve, yAve, b0, b1)

;  Arguments Passed:
;	1) xList, address
;	2) yList, address
;	3) length, value
;	4) xList average, value
;	5) yList average, value
;	6) b0, address
;	7) b1, address

;  Returns:
;	b0 and b1 via reference



;	YOUR CODE GOES HERE
global linearRegression
linearRegression:
    push rbp 
	mov rbp, rsp
	;push r10  
	push r12 
	push rbx
    push r14
    push r15   
    
	
	; ;a = while i =0 and len -1 
	; ; (x - avX ) (y -avY) /(x -Avex)^2 
	movsxd r8, r8d    ; yvae 
	mov r10d, ecx   ;xave 
	movsxd rcx, edx   ;length 
	mov dword[r12], 0   ;dsum 
	mov qword[rbx], 0  ;qSum 
	loop1:
		mov eax, dword[rdi + ((rcx-1) * 4)]  ;x 
		sub eax, r10d 
		mov r11d, eax    ;temp hold 
		imul eax         ;x^2 
		add dword[r12], eax   ;(x - xave)

	;loopYavY: 
		movsxd r14, dword[rsi +((rcx-1)*4)]  ;y 
		sub r14, r8              ; y - yav 

		movsxd rax, r11d   ;x-xav  break it down intp two cases 
		imul r14 
		add qword[rbx], rax   ;this is the x-xav * y - yav 
		loop loop1    ;cmp rcx jmp loopYavY 
		;cmp rcx, 0 
		;jne loop1
		
		;mov qword[tempVar], 0     ; temp to use 

	;solveforB1: 
		mov rax, qword[rbx]		;re use x-xav * y-yav 
		movsxd r15, dword[r12]    ;temp hold 
		idiv r15                    ;div divaden with divisor 
		mov r15, qword[rbp + 16]    ;use a non call reg 
		;jmp solveforB0 

	;solveforB0: 
		mov dword[r15], eax 
		imul r10d  		;mul b1 with y 
		sub r8d, eax     ;sub to get b0 
		;jmp solveforB1
		
		mov dword[r9], r8d 
		;jmp Done 
	;Done: 
	
	;mov rsp, rbp
    pop r15 
    pop r14 
    pop rbx 
    pop r12 
	mov rsp, rbp 
	pop rbp 
	ret


; -----------------------------------------------------------------------------

