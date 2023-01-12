push rbp
mov rbp,rsp
push rdi        
push rsi
push rax
push rbx 
push rdx        
push r12      
push r13
push r14  
push r15

mov eax, 1			;h
mov ebx, 3			; constant
mov r15, 0			;i
mov r14, 0			;tmp
mov r13, 0		;index
mov r12, 0			; j
; mov rdi, lst
; mov rsi, length
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


mov r15d, eax			;i=h-1
dec r15d	

loop3:							;for(i=h-1; i<length; i++)
	cmp r15d, esi				;i<length
	jge loop6
	mov r13, r15					; set i as our index
	mov r14d, dword[rdi+r13*4] 	;tmp = lst[i]
	mov r12d, r15d				; j=i

;******2ndOutsideLoopDone*************
loop4:
	cmp r12d, eax               ;j>=h
	jl loop5
	mov r13, r12
	sub r13, rax                ; set index to j-h
	cmp dword[rdi+r13*4], r14d   ;;lst[j-h] > tmp
	jge loop5                   ;switched to lst[j-h] < tmp
;********3rdLoop****************
	mov r12d, dword[rdi+r13*4]
	mov dword[rdi+r12*4], r12d  ;;lst[j] = lst[j-h]
;********3rdLoop****************
	sub r12d, eax               ;j = j-h
	jmp loop4

;******2ndOutsideLoopDone*************
	loop5:
	mov r13, r12			; set index to j
	mov dword[rdi+r13*4], r14d ;a[j] =tmp
	inc r15d					;i++
	jmp loop3

;**********outsideLoop****************
loop6:
cdq				
idiv ebx				; h=h/3
jmp loop2				; loop if h>0
done:

pop r15
pop r14
pop r13
pop r12
pop rdx
pop rbx
pop rax
pop rsi
pop rdi
mov rsp, rbp
pop rbp
	ret