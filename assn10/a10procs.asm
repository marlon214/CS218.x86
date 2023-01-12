; *****************************************************************
;  Name: Marlon Alejandro
;  NSHE ID: 5002573038
;  Section: 1003
;  Assignment: 10
;  Description: OpenGL test program

; -----
;  Function: getParams
;	Gets, checks, converts, and returns command line arguments.

;  Function drawWheels()
;	Plots functions

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

SPD_MIN		equ	1
SPD_MAX		equ	50			; 101(7) = 50

CLR_MIN		equ	0
CLR_MAX		equ	0xFFFFFF		; 0xFFFFFF = 262414110(7)

SIZ_MIN		equ	100			; 202(7) = 100
SIZ_MAX		equ	2000			; 5555(7) = 2000

; -----
;  Local variables for getParams functions.

STR_LENGTH	equ	12

errUsage	db	"Usage: ./wheels -sp <septNumber> -cl <septNumber> "
		db	"-sz <septNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL

errSpdSpec	db	"Error, speed specifier incorrect."
		db	LF, NULL
errSpdValue	db	"Error, speed value must be between 1 and 101(7)."
		db	LF, NULL

errClrSpec	db	"Error, color specifier incorrect."
		db	LF, NULL
errClrValue	db	"Error, color value must be between 0 and 262414110(7)."
		db	LF, NULL

errSizSpec	db	"Error, size specifier incorrect."
		db	LF, NULL
errSizValue	db	"Error, size value must be between 202(7) and 5555(7)."
		db	LF, NULL

; -----
;  Local variables for drawWheels routine.

t		dq	0.0			; loop variable
s		dq	0.0
tStep		dq	0.001			; t step
sStep		dq	0.0
x		dq	0			; current x
y		dq	0			; current y
scale		dq	7500.0			; speed scale

fltZero		dq	0.0
fltOne		dq	1.0
fltTwo		dq	2.0
fltThree	dq	3.0
fltFour		dq	4.0
fltSix		dq	6.0
fltTwoPiS	dq	0.0

pi		dq	3.14159265358

fltTmp1		dq	0.0
fltTmp2		dq	0.0

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255


; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cos, sin


; ******************************************************************
;  Function getParams()
;	Gets draw speed, draw color, and screen size
;	from the command line arguments.

;	Performs error checking, converts ASCII/septenary to integer.
;	Command line format (fixed order):
;	  "-sp <septNumber> -cl <septNumber> -sz <septyNumber>"

; -----
;  Arguments:
;	ARGC, double-word, value	rdi
;	ARGV, double-word, address	rsi
;	speed, double-word, address	rdx
;	color, double-word, address	rcx
;	size, double-word, address	r8

; Returns:
;	speed, color, and size via reference (of all valid)
;	TRUE or FALSE rax

;	YOUR CODE GOES HERE
global getParams
getParams: 


push rbp
mov rbp,rsp
push rdi            
push rsi
push rbx
push r12           
push r13
push r14  
push r15

mov r15,0 				; string index
mov r14, rdx
cmp rdi, 1
je promptUser

cmp rdi, 7
jne invalidNumEntries

mov rbx, qword[rsi+8]	; we skip the first element of the command line
mov al, byte[rbx]		; valids our 2nd string in the command line is "-sp"
cmp al, "-"
jne speedInd
mov al, byte[rbx+1]
cmp al, "s"
jne speedInd
mov al, byte[rbx+2]
cmp al, "p"
jne speedInd
mov al, byte[rbx+3]
cmp al, NULL
jne speedInd

;speed
mov rdi, qword[rsi+16]	; move our string to the desired registers for our function
call sept2int			; must define this function
cmp  eax, 0				; this is a unsigned number
jl speedValue			 
cmp  eax, SPD_MIN		; within out range
jb speedValue
cmp  eax, SPD_MAX	
ja speedValue
mov dword[r14], eax		; if valid return it by reference

mov rbx, qword[rsi+24]	
mov al, byte[rbx]		; valids our 2nd string in the command line is "-cl"
cmp al, "-"
jne colorInd
mov al, byte[rbx+1]
cmp al, "c"
jne colorInd
mov al, byte[rbx+2]
cmp al, "l"
jne colorInd
mov al, byte[rbx+3]
cmp al, NULL
jne colorInd

;color
mov rdi, qword[rsi+32]	; move our string to the desired registers for our function
call sept2int			; must define this function
cmp  eax, 0				; this is a unsigned number
jl colorValue			 
cmp  eax, CLR_MIN		; within out range
jb colorValue
cmp  eax, CLR_MAX	
ja colorValue
mov dword[rcx], eax ; if valid, pass color value by reference

mov rbx, qword[rsi+40]	
mov al, byte[rbx]		; valids our 2nd string in the command line is "-sz"
cmp al, "-"
jne sizeInd
mov al, byte[rbx+1]
cmp al, "s"
jne sizeInd
mov al, byte[rbx+2]
cmp al, "z"
jne sizeInd
mov al, byte[rbx+3]
cmp al, NULL
jne sizeInd

;size
mov rdi, qword[rsi+48]	; move our string to the desired registers for our function
call sept2int			; must define this function
cmp  eax, 0				; this is a unsigned number
jl sizeValue			 
cmp  eax, SIZ_MIN		; within out range
jb sizeValue
cmp  eax, SIZ_MAX	
ja sizeValue
mov dword[r8], eax		; if valid, pass size value by reference

jmp true

; errUsage	db	"Usage: ./wheels -sp <septNumber> -cl <septNumber> "
; 		db	"-sz <septNumber>"
; 		db	LF, NULL
; errBadCL	db	"Error, invalid or incomplete command line argument."
; 		db	LF, NULL

; errSpdSpec	db	"Error, speed specifier incorrect."
; 		db	LF, NULL
; errSpdValue	db	"Error, speed value must be between 1 and 101(7)."
; 		db	LF, NULL

; errClrSpec	db	"Error, color specifier incorrect."
; 		db	LF, NULL
; errClrValue	db	"Error, color value must be between 0 and 262414110(7)."
; 		db	LF, NULL

; errSizSpec	db	"Error, size specifier incorrect."
; 		db	LF, NULL
; errSizValue	db	"Error, size value must be between 202(7) and 5555(7)."
; 		db	LF, NULL

speedInd:
	mov rsi, errSpdSpec 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne speedInd
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rsi, errSpdSpec 			; msg address
	mov rdx, r15 ; length value
	syscall
	jmp false

speedValue:
	mov rsi, errSpdValue 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne speedValue
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	syscall
	jmp false

colorInd:
	mov rsi, errClrSpec 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne colorInd
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	syscall
	jmp false

colorValue:
	mov rsi, errClrValue 		; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne colorValue
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	syscall
	jmp false

sizeInd:
	mov rsi, errSizSpec 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne sizeInd
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	jmp false

sizeValue:
	mov rsi, errSizValue 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne sizeValue
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	syscall
	jmp false

promptUser:
	mov rsi, errUsage 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne promptUser
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	syscall
	jmp false

invalidNumEntries:
	mov rsi, errBadCL 			; msg address
	inc r15
	cmp byte[rsi+r15], NULL
	jne invalidNumEntries
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rdx, r15 ; length value
	syscall
	jmp false

false:
	mov rax, FALSE
	jmp done

true:
	mov rax, TRUE

done:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rsi
  pop rdi
  pop rbp
  ret
ret
; ******************************************************************
;  Draw wheels function.
;	Plot the provided functions (see PDF).

; -----
;  Arguments:
;	none -> accesses global variables.
;	nothing -> is void

; -----
;  Gloabl variables Accessed:

common	speed		1:4			; draw speed, dword, integer value
common	color		1:4			; draw color, dword, integer value
common	size		1:4			; screen size, dword, integer value

global drawWheels
drawWheels:
	push	rbp

; do NOT push any additional registers.
; If needed, save regitser to quad variable...

; -----
;  Set draw speed step
;	sStep = speed / scale

;	YOUR CODE GOES HERE
mov rdi, qword[rsi+16]	; move our string to the desired registers for our function
call sept2int			; must define this function
div qword[scale]
mov qword[sStep], rax
; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Set draw color(r,g,b)
;	uses glColor3ub(r,g,b)

;	YOUR CODE GOES HERE
mov rdi, qword[rsi+32]	; move our string to the desired registers for our function
call sept2int			; must define this function
mov byte[blue], al
ror eax, 8
mov byte[green], al
ror eax, 8
mov byte[red], al
mov rdi, 0
mov rsi,0 
mov rdx, 0
mov edi, dword[red]
mov esi,  dword[green]
mov edx, dword[blue]
call glColor3ub
; -----
;  main plot loop
;	iterate t from 0.0 to 2*pi by tStep
;	uses glVertex2d(x,y) for each formula

;	YOUR CODE GOES HERE
mov rax, qword[tStep]
add qword[t], rax
mov rdi, qword[t]
call cos
mov qword[x], rax
mov rdi, qword[t]
call sin
mov qword[y], rax
; -----
;  Display image

	call	glEnd
	call	glFlush

; -----
;  Update s, s += sStep;
;  if (s > 1.0)
;	s = 0.0;

	movsd	xmm0, qword [s]			; s+= sStep
	addsd	xmm0, qword [sStep]
	movsd	qword [s], xmm0

	movsd	xmm0, qword [s]
	movsd	xmm1, qword [fltOne]
	ucomisd	xmm0, xmm1			; if (s > 1.0)
	jbe	resetDone

	movsd	xmm0, qword [fltZero]
	movsd	qword [sStep], xmm0
resetDone:

	call	glutPostRedisplay

; -----

	pop	rbp
	ret

; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop	rbx
	ret

; ******************************************************************
global sept2int
sept2int:
; rdi hold 
; r12 holds reference to ne
push rbp
mov rbp,rsp
push r11
push r12
push r13
push r14
push r15

; r12 holds reference to newNumber
mov r13, 0  ;index
mov r14, 0  ; holds our char
mov eax, 0  ; return value
mov r12d, 0 ; convertion
;mov r8d, 7 -> dword[rbp-54]
mov r11d, 7  ; constant
mov r15d, "0"	; ascii conversion constant

startLoop: 
	mov r14b, byte[rdi+ r13]
	cmp r14b, NULL
	je fin
	cmp byte[rdi+r13], "6"   ; check if valid septnary value
	ja invalid
	cmp byte[rdi+r13], "0"   ; check if valid septnary value
	jb invalid

	movsx r12d, r14b
	sub r12d, r15d 
	imul r11d 
	add eax, r12d 

	inc r13  
	jmp startLoop
invalid:
	mov rax, -1
fin:

pop r15
pop r14
pop r13
pop r12
pop r11
mov rsp, rbp
pop rbp
ret
