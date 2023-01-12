; *****************************************************************
;  Name: Marlon
;  NSHE ID: 50022573038
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
  mov rbp,rsp
  push rdi            ;preserves rdi
  push rsi
  push rbx
  push r12            ;preserves r12
  push r13
  push r14  ; misc
  push r15

  sub rsp, 55
  mov dword[rbp-54], 7
  lea r12, dword[rdi]       ; r12 will hold rdi address(int newNumber)
  lea rbx, byte[rbp-50]		  ;our string array address will be stored in rbx
	mov r13, 0		            ;index i=0
  ;mov byte[rbx], NULL

;loop to read user input
getChar:
	;reads one character at a time
	mov rax, SYS_read	      ; intialize rax SYS_read
	mov rdi, STDIN		      ; reads in the line
	lea rsi, byte[rbp-55]		; rsi 
	mov rdx,1               ; reads in one character before storing in our string
	syscall                 ; preforms system call Sys_read

; rax: Call code = SYS_read (0)
; rdi: Input location, STDIN (0)
; rsi: Address of where to store characters read
; rdx: Number of characters to read
; followed by 'syscall' to preform action
;spaces count toward the input length.
;I would suggested reading the entire input line and only after it is entered, start processing/checking it.

	mov al,byte[rbp-55]     ; moves in read in character to our al register
	cmp al, LF              ; searches for LF to determine the end of the input
	je inputDone            ; if yes, our input is done ; only exit

  cmp r13, BUFFSIZE-1     ; compares if the size of r12 is larger than ???  
	ja buffFull             ; if so, we do not enter the char into our string and we continue to read the line
	mov byte[rbx+r13], al   ; if it is within out range we will enter the char within out designated indexin out string
	inc r13				          ;i++      
buffFull:
	jmp getChar           
  ; loops up

inputDone:
  ; mov r14, 0
  ; mov r14b, byte[rbp-50]   ; if LF is entered it doesnt get placed in the array
  ; mov dword[r12], r14d    ; debug erase later
;if input => BUFFSIZE => set status exit function
	cmp r13, BUFFSIZE       ; compares if our index exceeded our buffer size
	jb checkInput          ; unsigned (counter) check if equal or below
	mov rax, INPUTOVERFLOW  ; if we exceed our buffer we will call the correspong sys_call
	jmp readFuncDone        ; jmp to readFuncDone to send out the error

checkInput:
  mov byte[rbx+r13], NULL ; ends the string at the designated index ; may seg fault?
  cmp byte[rbx], NULL     ; if nothing was entered in the first index of the array, LF was the only entry
  je end                  ; signifies end of input
  mov r13, 0              ; reset index

checkWhiteSpace:
  cmp byte[rbx+r13], " "
  jne positive
  inc r13
  jmp checkWhiteSpace

positive:
  cmp byte[rbx+r13+1], NULL
  je invalid
  cmp byte[rbx+r13],"+"   ; check if positive
  je scanInput

negative:
  cmp byte[rbx+r13],"-"   ; check if negativ
  jne invalid             ; if not either, invalid
  cmp byte[rbx+r13+1], NULL
  je invalid
; *******************DONT TOUCH ABOVE**************************************	

scanInput:
  inc r13                 ; index++
  cmp byte[rbx+r13], "6"   ; check if valid septnary value
  ja invalid
  cmp byte[rbx+r13], NULL    ; check if end of string
  je aSept2int
  cmp byte[rbx+r13], "0"   ; check if valid septnary value
  jb invalid
  jmp scanInput           ; loops until error is detected or EOS

aSept2int:
; r12 holds reference to newNumber
mov r13, 0  ;index
mov r14, 0  ; holds our char
mov eax, 0  
mov r10d, 0 ; r10
;mov r8d, 7 -> dword[rbp-54]
mov r11d, 1  ; sign
mov r15d, "0"

startLoop: 
	mov r14b, byte[rbx+ r13]
	cmp r14b, NULL
	je Done
	cmp r14b, " "
	je skip
	cmp r14b, "+"
	je skip
	cmp r14b, "-"
	je negLoop 

	movsx r10d, r14b
	sub r10d, r15d 
	imul dword[rbp-54] 
	add eax, r10d 

	inc r13  
	jmp startLoop

skip:
	inc r13 
	jmp startLoop

negLoop:	
	mov r11d, -1
	inc r13
	jmp startLoop	

Done: 
	imul r11d
	cmp eax, MAX
	jg	tooLarge
	cmp eax, MIN
	jl tooSmall
	mov dword[r12], eax 
  	jmp successful

invalid:
  mov rax, NOSUCCESS    ; invalid if 1st char is not '-' or '+' and if the inputed invalid septnary value
  jmp readFuncDone

end:
  mov rax, ENDOFINPUT   ; signifying last input value
  jmp readFuncDone

tooLarge:
  mov rax, OUTOFRANGEMAX   ;int is too large
  jmp readFuncDone

tooSmall:
  mov rax, OUTOFRANGEMIN   ; int is too small
  jmp readFuncDone

successful:
  mov rax, SUCCESS

readFuncDone:
  add rsp, 55
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rsi
  pop rdi
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
; push rax
push rbx
push r8
push r9
push r10
push r11 
push r12

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
	jle loop5                   
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

pop r12
pop r11
pop r10
pop r9
pop r8
pop rbx
; pop rax

;*********************************************************
;	YOUR CODE GOES HERE


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

	pop r12
	pop r13
	pop r14
	pop r15
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

	call lstSum   ;has eax via rax 
	cdq 
	idiv rsi 	;div by len 

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
;	1) xList, address - rdi
;	2) yList, address - rsi
;	3) length, value - rdx
;	4) xList average, value - rcx
;	5) yList average, value - r8
;	6) b0, address - r9
;	7) b1, address - stack, rpb+16

    push rbp 
	mov rbp, rsp
	push r10 
	push r11 
	push r12
	push r13
	push r14
	push r15	
	push rbx
	push rdx

	mov rax,0
	mov r10, 0 ;index
	mov r11, rdx
	mov r12, 0 ; hold y ave
	mov r13, 0	; SUM((x -xave)^2 )
	mov r14, 0	; SUM((x - xave ) (y -yave))
	mov r15, 0
	mov rbx, qword[rbp + 16] ; this will hold b1
	
	; ;a = while i =0 and len -1 
	; ; (x - avX ) (y -avY) /(x -Avex)^2 
	
	loopReg:
		mov eax, dword[rdi+r10*4]  	;x 
		sub eax, ecx 				;x-xave
		mov r15d, dword[rsi+r10*4]	;y
		sub r15d, r8d				; y-yave
		imul r15d					;eax= (x - xave ) (y -yave)
		movsxd rax, eax
		add r14, rax

		mov eax, dword[rdi+r10*4]  	;x 
		sub eax, ecx 				;x-xave
		imul eax					;(x -xave)^2
		movsxd rax, eax
		add r13, rax
		
		inc r10
		cmp r10, r11
		jne loopReg

		mov rax, r14				;(x - avX ) (y -avY) /(x -Avex)^2 
		cqo
		idiv r13
		mov qword[rbx], rax			;b1=(x - avX ) (y -avY) /(x -Avex)^2 

		imul rcx					;b1*xave
		mov r12, r8
		sub r12, rax				; yave-b1*xave
		mov dword[r9], r12d			;bo=yave-b1*xave
	

	pop rdx
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop r11
	pop r10
	mov rsp, rbp
	pop rbp
	ret




; -----------------------------------------------------------------------------

