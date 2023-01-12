;  CS 218 - Assignment #11
;  Functions Template
;*****************************************************************
;  Name: Marlon Alejandro 
;  NSHE ID: 5002573038
;  Section: 1003
;  Assignment: 11
;  Description: Convert image to thumbnail

; ***********************************************************************
;  Data declarations
;	Note, the error message strings should NOT be changed.
;	All other variables may changed or ignored...

section	.data

; -----
;  Define standard constants.

LF		equ	10				; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20		; space

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

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

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q		; file permission - read only
O_WRONLY	equ	000001q		; file permission - write only
O_RDWR		equ	000002q		; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q

; -----
;  Define program specific constants.

MIN_FILE_LEN	equ	5

; buffer size (part A) - DO NOT CHANGE THE NEXT LINE.
BUFF_SIZE	equ	750000

; -----
;  Variables for getImageFileName() function.

eof		db	FALSE

usageMsg		db	"Usage: ./makeThumb <inputFile.bmp> "
				db	"<outputFile.bmp>", LF, NULL
errIncomplete	db	"Error, incomplete command line arguments.", LF, NULL
errExtra	db	"Error, too many command line arguments.", LF, NULL
errReadName	db	"Error, invalid source file name.  Must be '.bmp' file.", LF, NULL
errWriteName	db	"Error, invalid output file name.  Must be '.bmp' file.", LF, NULL
errReadFile	db	"Error, unable to open input file.", LF, NULL
errWriteFile	db	"Error, unable to open output file.", LF, NULL

; -----
;  Variables for setImageInfo() function.

HEADER_SIZE	equ	138

errReadHdr	db	"Error, unable to read header from source image file."
		db	LF, NULL
errFileType	db	"Error, invalid file signature.", LF, NULL
errDepth	db	"Error, unsupported color depth.  Must be 24-bit color."
		db	LF, NULL
errCompType	db	"Error, only non-compressed images are supported."
		db	LF, NULL
errSize		db	"Error, bitmap block size inconsistent.", LF, NULL
errWriteHdr	db	"Error, unable to write header to output image file.", LF,
		db	"Program terminated.", LF, NULL

; -----
;  Variables for readRow() function.

buffMax		dq	BUFF_SIZE
curr		dq	BUFF_SIZE
wasEOF		db	FALSE
pixelCount	dq	0

errRead		db	"Error, reading from source image file.", LF,
		db	"Program terminated.", LF, NULL

;  Variables for writeRow() function.

errWrite	db	"Error, writting to output image file.", LF,
		db	"Program terminated.", LF, NULL

; ------------------------------------------------------------------------
;  Unitialized data

section	.bss

buffer		resb	BUFF_SIZE	;arry
header		resb	HEADER_SIZE	; array

; ############################################################################

section	.text

; ***************************************************************
;  Routine to get image file names (from command line)
;	Verify files by atemptting to open the files (to make
;	sure they are valid and available).

;  Command Line format:
;	./makeThumb <inputFileName> <outputFileName>

; -----
;  Arguments: 
;	- argc (value)  rdi 
;	- argv table (address)   rsi 
;	- read file descriptor (address)  rdx 
;	- write file descriptor (address)  rcx 
;  Returns:
;	read file descriptor (via reference) 
;	write file descriptor (via reference)
;	TRUE or FALSE
global getImageFileNames
getImageFileNames:  
	push rbp
	push rbx 
	push rdi
	push rsi
	push r10
	push r11
	push r12
	push r13
	push r14
	push r15
	push rdx

	mov r10, rcx	;copy write file address (rcx gets overwritten during syscall)
	mov r15, 0		;error string counter
	mov r14, 0		;command line string counter

	cmp rdi, 1 
	je promptUser	; prompts user needed arguments
	cmp rdi, 2       		
	je fewArg		; print error string for to few arguments
	cmp rdi, 3      ; 3 arguements are a valid number
	ja tooMuchArg 	; print error string for to few arguments
	
	;Validate File names
	mov rbx, qword[rsi+8]	; we skip the first element of the command line
	mov r13, qword[rsi+8]	;saves first arguments address
	mov r12, qword[rsi+16]	;saves second arguments address

	validateReadFileType:
		mov al, byte[rbx+r14]		; valids our 1st string in the command line ends in ".bmp" Null
		inc r14
		cmp al, NULL
		je badReadName
		cmp al, "."
		jne validateReadFileType
		mov al, byte[rbx+r14]
		cmp word[rbx+r14], "bm"
		jne badReadName
		inc r14
		inc r14	
		mov al, byte[rbx+r14]
		cmp byte[rbx+r14], "p"
		jne badReadName
		inc r14
		mov al, byte[rbx+r14]
		cmp byte[rbx+r14], NULL
		jne badReadName

	mov rbx, qword[rsi+16]	; we skip the first element of the command line
	mov r14, 0				; resets index

	validateWriteFileType:
		mov al, byte[rbx+r14]		; valids our 2nd string in the command line ends in ".bmp" Null
		inc r14
		cmp al, NULL
		je badWriteName
		cmp al, "."
		jne validateWriteFileType
		mov al, byte[rbx+r14]
		cmp word[rbx+r14], "bm"
		jne badWriteName
		inc r14
		inc r14
		mov al, byte[rbx+r14]
		cmp byte[rbx+r14], "p"
		jne badWriteName
		inc r14
		mov al, byte[rbx+r14]
		cmp byte[rbx+r14], NULL
		jne badWriteName


	; System Service - Open
	; rax = SYS_open
	; rdi = address of file name string >arc[1] for read file
	; rsi = attributes (i.e., read only, etc.)
	; Returns:
	; if error -> eax < 0
	; if success -> eax = file descriptor number

	;OPEN READ FILE
	mov rax, SYS_open 		; file open
	mov rdi, r13 			; file name string
	mov rsi,  O_RDONLY 		; read/write access (maybe should be read only)
	syscall 				; call the kernel
	cmp rax, 0 				; error code if negative
	jl errorReadOpen		; else return file descriptor 
	mov qword[rdx], rax		; return read file by reference

	;OPEN/CREATE WRITE FILE
	mov rax, SYS_creat 			; file create/open
	mov rdi, r12 				; file name string
	mov rsi,  S_IRUSR | S_IWUSR ; read/write only access
	syscall 					; call the kernel
	cmp rax, 0 					; error code if negative
	jl errorWriteOpen			; else return file descriptor
	mov qword[r10], rax			; return write file by reference

	jmp true					;if all checks pass return true

	promptUser: 
		mov rsi, usageMsg 		; "Usage: ./makeThumb <inputFile.bmp> <outputFile.bmp>"
		inc r15
		cmp byte[rsi+r15], NULL
		jne promptUser
		jmp false

	errorWriteOpen:
		mov rsi, errWriteFile 	;"Error, unable to open output file."
		inc r15
		cmp byte[rsi+r15], NULL
		jne errorWriteOpen
		jmp false

	errorReadOpen:
		mov rsi, errReadFile 	; "Error, unable to open input file."
		inc r15
		cmp byte[rsi+r15], NULL
		jne errorReadOpen
		jmp false

	fewArg:  
		mov rsi, errIncomplete 	;"Error, incomplete command line arguments."
		inc r15
		cmp byte[rsi+r15], NULL
		jne fewArg
		jmp false

	tooMuchArg:
		mov rsi, errExtra 		;"Error, too many command line arguments."
		inc r15
		cmp byte[rsi+r15], NULL
		jne tooMuchArg
		jmp false

	badReadName:
		mov rsi, errReadName 	;"Error, invalid source file name.  Must be '.bmp' file."
		inc r15
		cmp byte[rsi+r15], NULL
		jne badReadName

		jmp false

	badWriteName:
		mov rsi, errWriteName 	;"Error, unable to open output file."
		inc r15
		cmp byte[rsi+r15], NULL
		jne badWriteName
		jmp false

	false: 
		mov rax, SYS_write		;writes error message to terminal
		mov rdi, STDOUT			;return false to the function
		mov rdx, r15 
		syscall
		mov rax, FALSE 
		jmp done

	true:  
		mov rax, TRUE			; return true to the funtion

	done: 
		pop rdx
		pop r15
		pop r14
		pop r13
		pop r12
		pop r11
		pop r10
		pop rsi 
		pop rdi 
		pop rbx 
		pop rbp
	ret 
; ***************************************************************
;  Read, verify, and set header information

;  HLL Call:
;	bool = setImageInfo(readFileDesc, writeFileDesc,
;		&picWidth, &picHeight[rsi+10], "54", thumbWidth, thumbHeight)

;  If correct, also modifies header information and writes modified
;  header information to output file (i.e., thumbnail file).

; -----
;  2 -> BM						(+0)
;  4 file size					(+2)
;  4 skip						(+6)
;  4 header size				(+10)
;  4 skip						(+14)
;  4 width						(+18)
;  4 height						(+22)
;  2 skip						(+26)
;  2 depth (16/24/32)			(+28)
;  4 compression method code	(+30)
;  4 bytes of pixel data		(+34)
;  skip remaing header entries

; -----
;   Arguments:
;	- read file descriptor (value) rdi 
;	- write file descriptor (value) rsi 
;	- old image width (address)		rdx 
;	- old image height (address)	rcx   
;	- new image width (value)		r8 
;	- new image height (value)		r9 

;  Returns:
;	file size (via reference)    this is wrong, might be a value or not even returnd 
;	old image width (via reference)
;	old image height (via reference)
;	TRUE or FALSE
global setImageInfo
setImageInfo:
	push rbp
	mov rbp,rsp
	push rdi            
	push rsi
	push rbx
	push r10
	push r12           
	push r13
	push r14  
	push r15

	mov r15, 0		;error string index			
	mov r14, 0 		;misc value holder for debugging
	mov r10, rsi	; move write file descriptor
	mov r13, rcx 	;rcx gets modified when syscall so mov it to differnt register(old image height address)
	mov r12, rdx	; we need rdx for syscall so we store (old image width address)

	mov rax, SYS_read	      	; intialize rax SYS_read
								;rdi already hold our value descriptor
	mov rsi, header				;we will read it into our header array 
	mov rdx, HEADER_SIZE        ; reads in HEADER_SIZE(138) amount of characters
	syscall 

	cmp rax, 0
	jl readHeader
			

	;mov rbx, qword[header] ;debug
	;mov r14b, byte[rsi]	;debug

	;VALID FILE SIGNATURE
	cmp word[rsi], "BM"
	jne sig

	;mov r14b, byte[rsi+1]	;debug
	; cmp byte[rsi+1], "M"
	; jne sig

	; mov al, byte[rsi+28]	;debug
	; mov al, byte[rsi+29]	;debug

	;CHECK FOR VALID COLOR DEPTH
	cmp word[rsi+28], 24
	jne color

	; mov al, byte[rsi+30]	;debug
	; mov al, byte[rsi+31]	;debug
	; mov al, byte[rsi+32]	;debug
	; mov al, byte[rsi+33]	;debug

	; mov rax, 0				; clear rax
	; mov eax, dword[rsi+30]	; stores compression value

	; CHECK FOR VALID COMPRESSION VALUE
	cmp dword[rsi+30], 0	; must be zero
	jne compress		; else errors out

	; mov rax, 0
	; mov r14d,24
	; mov eax, dword[rsi+18]
	; mul dword[rsi+22]
	; mul r14d
	; mov r14d,8
	; mov rdx,0
	; div r14d
	; add eax, dword[rsi+10]	; manual calculations
	
	; debug
	; mov r14d, dword[rsi+10]	; header size
	; mov r14d, dword[rsi+2]	; file size
	; mov r14d, dword[rsi+18]	; width
	; mov r14d, dword[rsi+22]	;height
	; mov r14d, dword[rsi+34]	;pixel size

	;RETURN HEIGHT AND WIDTH BY REFERENCE
	mov r14d, dword[rsi+22]	;height
	mov dword[r13], r14d		;heigth
	mov r14d, dword[rsi+18]	; width
	mov dword[r12],	r14d		;width


	mov rax, 0
	mov eax, dword[rsi+34]	;pixel size = height*width*24/8 (bytes)
	add eax, dword[rsi+10]	; header size
	cmp eax, dword[rsi+2]	; file size	= header+pixels
	jne blockSize


	;UPDATE HEADER VALUE
	mov rax, 3
	mul r8
	mul r9
	;mov dword[header+34], eax	; WE DO NOT update pixel size
	add eax, dword[header+10]	
	mov dword[header+2], eax	; update file size
	mov dword[header+18], r8d 	; update width
	mov dword[header+22], r9d	; update height height


	mov rax, SYS_write	      	;intialize rax SYS_write
	mov rdi, r10				;rdi already hold our value descriptor
	mov rsi, header				;we will read it into our header array 
	mov rdx, HEADER_SIZE        ;reads in HEADER_SIZE(138) amount of characters
	syscall 					; write header to our output file
	cmp rax, 0
	jl writeHeader

	jmp false2 

	blockSize:
		mov rsi, errSize 			;"Error, bitmap block size inconsistent."
		inc r15
		cmp byte[rsi+r15], NULL
		jne blockSize
		jmp true2

	compress:
		mov rsi, errCompType 		;"Error, only non-compressed images are supported."
		inc r15
		cmp byte[rsi+r15], NULL
		jne compress
		jmp true2

	color:
		mov rsi, errDepth 			; "Error, unsupported color depth.  Must be 24-bit color."
		inc r15
		cmp byte[rsi+r15], NULL
		jne color
		jmp true2

	sig:
		mov rsi, errFileType 		; "Error, invalid file signature.""
		inc r15
		cmp byte[rsi+r15], NULL
		jne sig
		jmp true2

	readHeader:
		mov rsi, errReadHdr 		; "Error, unable to read header from source image file."
		inc r15
		cmp byte[rsi+r15], NULL
		jne readHeader
		jmp true2		

	writeHeader:
		mov rsi, errWriteHdr 		; "Error, unable to write header to output image file. "Program terminated."
		inc r15
		cmp byte[rsi+r15], NULL
		jne writeHeader
		jmp true2		

	true2:
		mov rax, SYS_write			; prompter error message
		mov rdi, STDOUT
		mov rdx, r15 ; length value
		syscall
		mov rax, FALSE 				; return false to function
		jmp done2

	false2:
		mov rax, TRUE				; success
	;  2 -> BM						(+0)
	;  4 file size					(+2)
	;  4 skip						(+6)
	;  4 header size				(+10)
	;  4 skip						(+14)
	;  4 width						(+18)
	;  4 height						(+22)
	;  2 skip						(+26)
	;  2 depth (16/24/32)			(+28)
	;  4 compression method code	(+30)
	;  4 bytes of pixel data		(+34)
	;  skip remaing header entries
	;errWriteHdr	db	"Error, unable to write header to output image file. "Program terminated."

	done2: 
		pop r15
		pop r14
		pop r13
		pop r12
		pop r10
		pop rbx
		pop rsi
		pop rdi
		pop rbp
	ret

; ***************************************************************
;  Return a row from read buffer
;	This routine performs all buffer management

; ----
;  HLL Call:
;	bool = readRow(readFileDesc, picWidth, rowBuffer[]);

;   Arguments:
;	- read file descriptor (value) rdi 
;	- image width (value)			rsi 
;	- row buffer (address)			rdx 
;  Returns:
;	TRUE or FALSE

; -----
;  This routine returns TRUE when row has been returned
;	and returns FALSE if there is no more data to
;	return (i.e., all data has been read) or if there
;	is an error on read (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.

global readRow
readRow: 
;	YOUR CODE GOES HERE

;read a huge file in one go and return a row at a time, with each pixel taking 3 bites 
;use the buff_size formula 
;keep track of start and end of data being read into the buffer 
;make sure you move char to read into the begining 
;each time you do a read, you need to varafi how much bite you got back 
;if the end of data is not at the end of the buffer, you know youve done2shed reading 
;when end of data and next are the same point -> return true 

 	push rbp
	mov rbp,rsp
	push rdi            
	push rsi
	push rbx
	push r10
	push r12           
	push r13
	push r14  
	push r15

	mov r15, 0				
	mov r14, BUFF_SIZE 		;row index		
	mov r13, rdx			;row buffer address
	mov rax, 3
	mul rsi
	mov r12, rax			;rowSize= 3*picWidth
	mov rbx, 0 				;misc
	mov r10, 0 				;intialize index
	
	next:					
	 	cmp qword[curr], r14  		
	 	jl loadBuffer				;curr < bufferMAx
		cmp qword[wasEOF], FALSE    ;Check for EOF
		jne false3 

		mov rax, SYS_read 			; read from buffer	
		mov rsi, buffer 			;rdi holds our file descriptor
		mov rdx, BUFF_SIZE
		syscall 
		cmp rax, 0 					;Error Check
		jl errorReadRow 

		cmp rax, BUFF_SIZE			; compares the requested data with the actual data
		je contRead 				; if less than, we reached the end of file

		mov qword[wasEOF], TRUE
		mov r14, rax

	contRead: 
		mov qword[curr], 0			; resets current index

	loadBuffer:
		mov r15, qword[curr]
		mov bl, byte[buffer + r15]		
		inc r15
		mov qword[curr], r15
		mov byte[r13+r10], bl
		inc r10

		cmp r10, r12				; loads until we reach the end of the buffer
		jl next

		jmp true3

	errorReadRow: 
		mov rsi, errRead 		; "Error, reading from source image file. Program terminated."
		inc r15
		cmp byte[rsi+r15], NULL
		jne errorReadRow
		mov rax, SYS_write			
		mov rdi, STDOUT
		mov rdx, r15 
		syscall

	false3: 
 		mov rax, FALSE
 		jmp done3
	
 	true3: 
 		mov rax, TRUE

	done3: 

		pop r15 
		pop r14 
		pop r13 
		pop r12 
		pop r10
		pop rbx
		pop rsi
		pop rdi
		mov rsp, rbp  
		pop rbp  
	ret 

; ***************************************************************
;  Write image row to output file.
;	Writes exactly (width*3) bytes to file.
;	No requirement to buffer here.

; -----
;  HLL Call:
;	bool = writeRow(writeFileDesc, picWidth, rowBuffer);

;  Arguments are:
;	- write file descriptor (value) rdi 
;	- image width (value)		rsi 
;	- row buffer (address)		rdx 

;  Returns:
;	N/A

; -----
;  This routine returns TRUE when row has been written
;	and returns FALSE only if there is an
;	error on write (which would not normally occur).

;  The read buffer itself and some misc. variables are used
;  ONLY by this routine and as such are not passed.

global writeRow
writeRow:
;	YOUR CODE GOES HERE
	push rbp 
	mov rbp, rsp 
	push r15
	mov r15 ,0 			; error string index

	push rdx
	mov rax, 3			
	mul rsi 
	mov rbx, rax    	;row length = width*3
	pop rdx			

	mov rax, SYS_write	
	mov rsi, rdx 
	mov rdx, rbx 
	syscall

	cmp rax, 0
	jl writeRowError

	mov rax, TRUE
	jmp done4

	writeRowError: 
		mov rsi, errWrite 			;"Error, writting to output image file.", LF,db	"Program terminated."
		inc r15
		cmp byte[rsi+r15], NULL
		jne writeRowError
		mov rax, SYS_write			
		mov rdi, STDOUT
		mov rdx, r15 
		syscall
		mov rax, FALSE 	

	done4: 

		pop r15
		mov rsp, rbp 
		pop rbp 
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
