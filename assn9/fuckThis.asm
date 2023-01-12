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
  mov r14, 0
  mov r14b, byte[rbp-50]   ; if LF is entered it doesnt get placed in the array
  mov dword[r12], r14d    ; debug erase later
;if input => BUFFSIZE => set status exit function
	cmp r13, BUFFSIZE       ; compares if our index exceeded our buffer size
	jb checkInput          ; unsigned (counter) check if equal or below
	mov rax, INPUTOVERFLOW  ; if we exceed our buffer we will call the correspong sys_call
	jmp readFuncDone        ; jmp to readFuncDone to send out the error

checkInput:
  cmp byte[rbx], NULL     ; if nothing was entered in the first index of the array, LF was the only entry
  je end                  ; signifies end of input
	mov byte[rbx+r13], NULL ; ends the string at the designated index ; may seg fault?
  mov r13, 0              ; reset index
  cmp byte[rbx+r13],"+"   ; check if positive
  ; je readFuncDone
  je scanInput


negative:
  cmp byte[rbx+r13],"-"   ; check if negativ
  jne invalid             ; if not either, invalid
; *******************DONT TOUCH ABOVE**************************************

scanInput:
  inc r13                 ; index++
  ; mov r14b, "6"
  ; mov r15b, "0"
  mov r10, 0
  mov r10b, byte[rbx+r13]   ; if LF is entered it doesnt get placed in the array
  mov dword[r12], r10d
  cmp byte[rbx+r13], "6"   ; check if valid septnary value
  ja invalid

  ;problem
  cmp byte[rbx+r13], "0"
  jb invalid
  ; ******** problem*******************

  cmp byte[rbx+r13], NULL    ; check if end of string
  je aSept2int
  jmp scanInput           ; loops until error is detected or EOS
; ******** problem*******************

aSept2int:
;  Arguments:
;	%1 -> <string>, register -> string address
;	%2 -> <integer>, register -> result

;	STEP #2
;	YOUR CODE GOES HERE
; mov rbx, %1
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
	mov dword[r12], eax 
  jmp successful

invalid:
  mov rax, NOSUCCESS    ; invalid if 1st char is not '-' or '+' and if the inputed invalid septnary value
  jmp readFuncDone

end:
  mov rax, ENDOFINPUT   ; signifying last input value
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
  