; *****************************************************************
;  Name: Marlon Alejandro
;  NSHE ID: 5002573038	
;  Section: 1003
;  Assignment: 6
;  Description:	Simple assembly language program to calculate 
;		the diameters if a circle for a series of circles.
;		The circle radii lengths are provided as septenary values
;		represented as ASCII characters and must be converted into
;		integer in order to perform the calculations.

; =====================================================================
; General form 
; %macro <name> <count of args>
; <body>
; %endmacro


;  STEP #2
;  Macro to convert ASCII/septenary value into an integer.
;  Reads <string>, convert to integer and place in <integer>
;  Assumes valid data, no error checking is performed.

;  Arguments:
;	%1 -> <string>, register -> string address
;	%2 -> <integer>, register -> result

;  Macro usgae
;	aSept2int  <string>, <integer>

;  Example usage:
;	aSept2int	rbx, tmpInteger

;  For example, to get address into a local register:
;		mov	rsi, %1

;  Note, the register used for the macro call (rbx in this example)
;  must not be altered before the address is copied into
;  another register (if desired).

%macro	aSept2int	2

;	STEP #2
;	YOUR CODE GOES HERE
mov rbx, %1
mov rsi, 0  
mov eax, 0  
mov ecx, 0 
mov r8d, 7 
mov r9d, 1
mov r11d, "0"
%%startLoop: 
	mov r10b, byte[rbx+ rsi]
	cmp r10b, NULL
	je %%Done
	cmp r10b, " "
	je %%skip
	cmp r10b, "+"
	je %%skip
	cmp r10b, "-"
	je %%negLoop 

	movsx ecx, r10b
	sub ecx, r11d 
	imul r8d 
	add eax, ecx 

	inc rsi  
	jmp %%startLoop

%%skip:
	inc rsi 
	jmp %%startLoop

%%negLoop:	
	mov r9d, -1
	inc rsi
	jmp %%startLoop	

%%Done: 
	imul r9d
	mov dword[%2], eax 

%endmacro

; =====================================================================
;  Macro to convert integer to septenary value in ASCII format.
;  Reads <integer>, converts to ASCII/septenary string including
;	NULL into <string>

;  Note, the macro is calling using RSI, so the macro itself should
;	 NOT use the RSI register until is saved elsewhere.

;  Arguments:
;	%1 -> <integer>, value
;	%2 -> <string>, string address

;  Macro usgae
;	int2aSept	<integer-value>, <string-address>

;  Example usage:
;	int2aSept	dword [diamsArrays+rsi*4], tempString

;  For example, to get value into a local register:
;		mov	eax, %1

%macro	int2aSept	2
;****************************
;	STEP #5
;	YOUR CODE GOES HERE
mov eax, %1 ; get integer
mov rcx, 0 ; digitCount = 0
mov ebx, 7 ; set for dividing by 10
mov r8, "0"
mov r9, STR_LENGTH-1
mov r10,0

cmp eax, 0
jl %%signedNegative
cmp eax, 0
jg %%signedPositive

%%signedPositive:
mov r10, "+"
jmp %%divideLoop

%%signedNegative:
;mov r8, -44
neg eax
mov r10, "-"
jmp %%divideLoop

%%divideLoop:
	mov edx, 0
	cdq
	idiv ebx ; divide number by 7
	add rdx, r8
	push rdx ; push remainder
	inc rcx ; increment digitCount
	cmp eax, 0 ; if (result > 0)
	jne %%divideLoop ; goto divideLoop

	mov rbx, %2 ; get addr of string
	mov rdi, 0 ; idx = 0
	push r10
	inc rcx
	;'jmp %%whiteSpace

; %%negDivideLoop:
; 	mov edx, 0
; 	cdq
; 	idiv ebx ; divide number by 7
; 	neg rdx
; 	add rdx, r8
; 	push rdx ; push remainder
; 	inc rcx ; increment digitCount
; 	cmp eax, 0 ; if (result > 0)
; 	jne %%divideLoop ; goto divideLoop

; 	mov rbx, %2 ; get addr of string
; 	mov rdi, 0 ; idx = 0
; 	push r10
; 	inc rcx
; 	jmp %%whiteSpace

%%whiteSpace:
	push " "
	inc rcx
	cmp r9, rcx
	jne %%whiteSpace
%%popLoop:

pop rax ; pop intDigit
;add al, "0" ; char = int + "0"
mov byte [rbx+rdi], al ; string[idx] = char
inc rdi ; increment idx
loop %%popLoop ; if (digitCount > 0)

; goto popLoop
mov byte [rbx+rdi], NULL ; string[idx] = NULL

%endmacro

; =====================================================================
;  Simple macro to display a string to the console.
;  Count characters (excluding NULL).
;  Display string starting at address <stringAddr>

;  Macro usage:
;	printString  <stringAddr>

;  Arguments:
;	%1 -> <stringAddr>, string address

%macro	printString	1
	push	rax			; save altered registers (cautionary)
	push	rdi
	push	rsi
	push	rdx
	push	rcx

	lea	rdi, [%1]		; get address
	mov	rdx, 0			; character count
%%countLoop:
	cmp	byte [rdi], NULL
	je	%%countLoopDone
	inc	rdi
	inc	rdx
	jmp	%%countLoop
%%countLoopDone:

	mov	rax, SYS_write		; system call for write (SYS_write)
	mov	rdi, STDOUT		; standard output
	lea	rsi, [%1]		; address of the string
	syscall				; call the kernel

	pop	rcx			; restore registers to original values
	pop	rdx
	pop	rsi
	pop	rdi
	pop	rax
%endmacro

; =====================================================================
;  Initialized variables.

section	.data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
NOSUCCESS	equ	1			; unsuccessful operation

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

NUMS_PER_LINE	equ	4


; -----
;  Assignment #6 Provided Data

STR_LENGTH	equ	12			; chars in string, with NULL

septRadii	db	"         +5", NULL, "        +10", NULL, "        +16", NULL
		db	"        +24", NULL, "        +35", NULL, "        +46", NULL
		db	"        +55", NULL, "        +63", NULL, "       +106", NULL
		db	"       +143", NULL, "       +144", NULL, "       +155", NULL
		db	"      -2542", NULL, "      -1610", NULL, "      -1361", NULL
		db	"       +266", NULL, "       +330", NULL, "       +421", NULL
		db	"       +502", NULL, "       +516", NULL, "       +642", NULL
		db	"      +1161", NULL, "      +1135", NULL, "      +1246", NULL
		db	"      -1116", NULL, "      -1000", NULL, "       -136", NULL
		db	"      +1540", NULL, "      +1651", NULL, "      +2151", NULL
		db	"      +2161", NULL, "     +10063", NULL, "     -11341", NULL
		db	"     +12224", NULL
aSeptLength	db	"        +46", NULL
length		dd	0

diamSum		dd	0
diamAve		dd	0
diamMin		dd	0
diamMax		dd	0

; -----
;  Misc. variables for main.

hdr		db	"-----------------------------------------------------"
		db	LF, ESC, "[1m", "CS 218 - Assignment #6", ESC, "[0m", LF
		db	"Diameter Calculations", LF, LF
		db	"Diameters:", LF, NULL
shdr		db	LF, "Diameters Sum:  ", NULL
avhdr		db	LF, "Diameters Ave:  ", NULL
minhdr		db	LF, "Diameters Min:  ", NULL
maxhdr		db	LF, "Diameters Max:  ", NULL

newLine		db	LF, NULL
spaces		db	"   ", NULL

ddTwo		dd	2

; =====================================================================
;  Uninitialized variables

section	.bss

tmpInteger	resd	1				; temporaty value

diamsArray	resd	34

lenString	resb	STR_LENGTH
tempString	resb	STR_LENGTH			; bytes

diamSumString	resb	STR_LENGTH
diamAveString	resb	STR_LENGTH
diamMinString	resb	STR_LENGTH
diamMaxString	resb	STR_LENGTH

; **************************************************************

section	.text
global	_start
_start:

; -----
;  Display assignment initial headers.

	printString	hdr

; -----
;  STEP #1
;	Convert integer length, in ASCII septenary format to integer.
;	Do not use macro here...
;	Read string aSeptLength1, convert to integer, and store in length

;	YOUR CODE GOES HERE
mov cl, 0				; stores our results in ebx
mov dl, 7				; stores const 
mov bl, "0"				; ASCII int converstion constant


mov rsi, STR_LENGTH-2	; index with in string
mov r8, aSeptLength 	; stores string address in r9d


mov al, byte[r8+rsi*1]	; holds the character within our string	
sub al, bl
mov cl, al
dec rsi
mov al, byte[r8+rsi*1]	; holds the character within our string	
sub al, bl
mul dl
add cl, al
mov byte[length], cl


; -----
;  Convert radii from ASCII/septenary format to integer.
;  STEP #2 must complete before this code.

	mov	ecx, dword [length]
	mov	rdi, 0					; index for radii
	mov	rbx, septRadii
cvtLoop:
	push	rbx					; safety push's
	push	rcx
	push	rdi
	aSept2int	rbx, tmpInteger
	pop	rdi
	pop	rcx
	pop	rbx

	mov	eax, dword [tmpInteger]
	mul	dword [ddTwo]				; diam = radius * 2
	mov	dword [diamsArray+rdi*4], eax
	add	rbx, STR_LENGTH

	inc	rdi
	dec	ecx
	cmp	ecx, 0
	jne	cvtLoop

; -----
;  Display each the diamsArray (four per line).

	mov	ecx, dword [length]
	mov	rsi, 0
	mov	r12, 0
printLoop:
	push	rcx					; safety push's
	push	rsi
	push	r12

	mov	eax, dword [diamsArray+rsi*4]
	int2aSept	eax, tempString

	printString	tempString
	printString	spaces

	pop	r12
	pop	rsi
	pop	rcx

	inc	r12
	cmp	r12, 4
	jne	skipNewline
	mov	r12, 0
	printString	newLine
skipNewline:
	inc	rsi

	dec	ecx
	cmp	ecx, 0
	jne	printLoop
	printString	newLine

; -----
;  STEP #3
;	Find diamaters array stats (sum, min, max, and average).
;	Reads data from diamsArray (set above).

;	YOUR CODE GOES HERE
;***********************************
;Set Diameter Sum

mov ecx, dword[length]                   ;amout of iterations
mov rsi, 0                               ;array index
mov eax, 0                               ;intialize sum as 0

sumDiameterLoop: 
    add eax, dword[diamsArray+(rsi*4)]      ;adds each element to our sum register
    inc rsi                              ;increament index 
    loop sumDiameterLoop                   ;loops until end of array
    mov dword[diamSum], eax
  
;Set Diameter Average                      ;Sum is still stores in eax

mov edx, 0
div dword[length]                        ;divides array sum by the number of elements 
mov dword[diamAve], eax                    ;sets value to average

;Set Diameter Min/Max

mov eax, dword[diamsArray]                 ;sets eax to first value in array
mov dword[diamMin], eax                    ;sets min and max to the first value in array
mov dword[diamMax], eax
mov rsi, 0                              ;reset index 
mov ecx, dword[length]                  ;amout of iterations

minDiameterLoop:
        mov eax, dword[diamsArray+rsi*4]   ; sets value of our current index to eax
        cmp eax, dword[diamMin]            ; compares value to our current min
        jg minDiameterSet                 ; if eax is greater than min, we jump
        mov dword[diamMin], eax            ; sets new min

minDiameterSet:                           ; increments and loops back
        inc rsi 
        loop minDiameterLoop

mov rsi, 0                              ;reset index
mov ecx, dword[length]                  ;amout of iterations

maxDiameterLoop:
        mov eax, dword[diamsArray+rsi*4]   ;sets value of our current index to eax
        cmp eax, dword[diamMax]            ;compares value to our current max
        jl maxDiameterSet                 ;if eax is less than max, we jump
        mov dword[diamMax], eax            ;sets new max

maxDiameterSet:                           ;increments and loops back
        inc rsi
        loop maxDiameterLoop

;**********************************
; -----
;  STEP #4
;	Convert sum to ASCII/septenary for printing.
;	Do not use macro here...

	printString	shdr

;	Read diamsArray sum inetger (set above), convert to
;		ASCII/septenary and store in diamSumString.

;	YOUR CODE GOES HERE

mov eax, dword [diamSum] ; get integer
mov rcx, 0 ; digitCount = 0
mov ebx, 7 ; set for dividing by 10
mov r8, "0"
mov r9, STR_LENGTH-1
divideLoop:
	mov edx, 0
	cdq
	idiv ebx ; divide number by 7
	add rdx, r8
	push rdx ; push remainder
	inc rcx ; increment digitCount
	cmp eax, 0 ; if (result > 0)
	jne divideLoop ; goto divideLoop

	mov rbx, diamSumString ; get addr of string
	mov rdi, 0 ; idx = 0
	push "+"
	inc rcx
whiteSpace:
	push " "
	inc rcx
	cmp r9, rcx
	jne whiteSpace
popLoop:

pop rax ; pop intDigit
;add al, "0" ; char = int + "0"
mov byte [rbx+rdi], al ; string[idx] = char
inc rdi ; increment idx
loop popLoop ; if (digitCount > 0)

; goto popLoop
mov byte [rbx+rdi], NULL ; string[idx] = NULL



;	print the diamSumString (set above).
	printString	diamSumString

; -----
;  Convert average, min, and max integers to ASCII/septenary for printing.
;  STEP #5 must complete before this code.

	printString	avhdr
	int2aSept	dword [diamAve], diamAveString
	printString	diamAveString

	printString	minhdr
	int2aSept	dword [diamMin], diamMinString
	printString	diamMinString

	printString	maxhdr
	int2aSept	dword [diamMax], diamMaxString
	printString	diamMaxString

	printString	newLine
	printString	newLine

; *****************************************************************
;  Done, terminate program.

last:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall
