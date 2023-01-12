;  Name: Marlon Alejandro
;  NSHE ID: 5002573038
;  Section: 1003
;  Assignment: 5
;  Description: Conversions, multiple datatypes, and arrays
;
; *****************************************************************
;  Static Data Declarations (initialized)
section	.data

; -----
;  Define constants

NULL		equ	0			; end of string
TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS    equ	0			; successful operation
SYS_exit	equ	60			; call code for terminate

; -----
;  Provided Data

lengths		dd	 1355,  1037,  1123,  1024,  1453
                dd	 1115,  1135,  1123,  1123,  1123
                dd	 1254,  1454,  1152,  1164,  1542
                dd	-1353,  1457,  1182, -1142,  1354
                dd	 1364,  1134,  1154,  1344,  1142
                dd	 1173, -1543, -1151,  1352, -1434
                dd	 1134,  2134,  1156,  1134,  1142
                dd	 1267,  1104,  1134,  1246,  1123
                dd	 1134, -1161,  1176,  1157, -1142
                dd	-1153,  1193,  1184,  1142

widths		dw	  367,   316,   542,   240,   677
                dw	  635,   426,   820,   146,  -333
                dw	  317,  -115,   226,   140,   565
                dw	  871,   614,   218,   313,   422	
                dw	 -119,   215,  -525,  -712,   441
                dw	 -622,  -731,  -729,   615,   724
                dw	  217,  -224,   580,   147,   324
                dw	  425,   816,   262,  -718,   192
                dw	 -432,   235,   764,  -615,   310
                dw	  765,   954,  -967,   515

heights		db	   42,    21,    56,    27,    35
                db	  -27,    82,    65,    55,    35
                db	  -25,   -19,   -34,   -15,    67
                db	   15,    61,    35,    56,    53
                db	  -32,    35,    64,    15,   -10
                db	   65,    54,   -27,    15,    56
                db	   92,   -25,    25,    12,    25
                db	  -17,    98,   -77,    75,    34
                db	   23,    83,   -73,    50,    15
                db	   35,    25,    18,    13

length		dd	   49

vMin		dd	    0
vEstMed		dd	    0
vMax		dd	    0
vSum		dd	    0
vAve		dd	    0
  
saMin		dd	    0
saEstMed	dd	    0
saMax		dd	    0
saSum		dd	    0
saAve		dd	    0

; -----
; Additional variables (if any)
count           dd          0 
ddTwo           dd          2 
ddThree         dd          3 
ddTemp1         dd          0
ddTemp2         dd          0  
ddTemp3         dd          0 
ddFinal         dd          0 
; --------------------------------------------------------------
; Uninitialized data

section	.bss

volumes		resd	    49
surfaceAreas	resd	    49

;**********************************************
section .text
global _start


; -----
; Additional variables (if any)

_start:
;**********************************************
;Volumes
;v=l*w*h

;Set Volume Array
mov ecx, dword[length]                   ;amout of iterations
mov dword[count], ecx                    ;sets count as length
mov rsi, 0                               ;array index

setVolumeLoop:                      
    mov eax, dword[lengths+(rsi*4)]      ;sets length as base
    movsx ebx, word[widths+(rsi*2)]      ;converts width to dword
    movsx r8d, byte[heights+(rsi*1)]     ;converts heights to dword
    imul ebx                             ;multiplies length by width
    imul r8d                             ;multiplies product by height
    mov dword[volumes+(rsi*4)], eax      ;sets newly calculated volume to our array
    inc rsi                              ;increament index 
    loop setVolumeLoop                   ;loops until end of array

;Set Volume Sum

mov ecx, dword[length]                   ;amout of iterations
mov rsi, 0                               ;array index
mov eax, 0                               ;intialize sum as 0

sumVolumeLoop: 
    add eax, dword[volumes+(rsi*4)]      ;adds each element to our sum register
    inc rsi                              ;increament index 
    loop sumVolumeLoop                   ;loops until end of array
    mov dword[vSum], eax
  
;Set Volume Average                      ;Sum is still stores in eax

mov edx, 0
div dword[length]                        ;divides array sum by the number of elements 
mov dword[vAve], eax                    ;sets value to average

;Set Volume Min/Max

mov eax, dword[volumes]                 ;sets eax to first value in array
mov dword[vMin], eax                    ;sets min and max to the first value in array
mov dword[vMax], eax
mov rsi, 0                              ;reset index 
mov ecx, dword[length]                  ;amout of iterations

minVolumeLoop:
        mov eax, dword[volumes+rsi*4]   ; sets value of our current index to eax
        cmp eax, dword[vMin]            ; compares value to our current min
        jg minVolumeSet                 ; if eax is greater than min, we jump
        mov dword[vMin], eax            ; sets new min

minVolumeSet:                           ; increments and loops back
        inc rsi 
        loop minVolumeLoop

mov rsi, 0                              ;reset index
mov ecx, dword[length]                  ;amout of iterations

maxVolumeLoop:
        mov eax, dword[volumes+rsi*4]   ;sets value of our current index to eax
        cmp eax, dword[vMax]            ;compares value to our current max
        jl maxVolumeSet                 ;if eax is less than max, we jump
        mov dword[vMax], eax            ;sets new max

maxVolumeSet:                           ;increments and loops back
        inc rsi
        loop maxVolumeLoop

;Set Volume Median
mov r8d, dword[length]                  ;49
mov r9d,  2                             ;middle divider
mov r11d, 3                             ;average divider      
mov eax, dword[length]                  ;sets eax to length      
mov edx, 0 
div r9d
mov r10d, eax                           ; divide length by 2, 49->24

mov eax, 0                              ;resets register to 0
add eax, dword[volumes]                 ;adds first element
add eax, dword[volumes + ((r10d) *4)]   ;adds middle element
add eax, dword[volumes + ((r8d-1) *4)]  ;adds last element
cdq
idiv r11d
mov dword[vEstMed], eax                 ;takes the average of the 3 and stores it as vEstMed

;**********************************************
;Initialize Surface Area Array
;SA= (2*l*w)+(2*w*h)+(2*h*l)

mov ebx, 0                              ;holds surface area
mov rsi, 0                              ;resets index
mov r11d, 2                             ;2 contants multiply
mov ecx, dword[length]                  ;amout of iterations


surfaceAreaLoop:

    movsx r8d, word[widths+(rsi*2)]     ;word to dw register 
    movsx r9d, byte[heights+(rsi*1)]    ;byte to dw register 
    mov r10d, dword[lengths+(rsi*4)]    ;length in eax 

;1stRectangle:    
    mov eax, r10d                       ;sets eax to length
    imul r8d                            ;multiplies it by width
    imul r11d                           ;multiplies by our constant 2
    mov ebx,eax                         ;adds product to surface area

;2ndRectangle:
    mov eax, r8d                        ;sets eax to width
    imul r9d                            ;multiplies it by height                   
    imul r11d                           ;multiplies by our constant 2
    add ebx, eax                        ;sets product to surface area

;3rdRectangle:        
    mov eax, r9d                        ;sets eax to height
    imul r10d                           ;multiplies it by length
    imul r11d                           ;multiplies by our constant 2
    add ebx,eax                         ;adds product to surface are

;SetSum
    mov dword[surfaceAreas+(rsi*4)], ebx;sets current Surface area index to our calculated value
    inc rsi                             ;increament index 
    loop surfaceAreaLoop                ;loops until end of array
 

mov rsi, 0
mov eax, 0
mov ecx, dword[length]

;Surface Area Sum

sumSurfaceAreaLoop: 
    add eax, dword[surfaceAreas+(rsi*4)] ;adds each element to our sum register
    inc rsi                              ;increament index 
    loop sumSurfaceAreaLoop              ;loops until end of array
    mov dword[saSum], eax                ;set saSum to our calculated value 
  
;Set Volume Average                      ;Sum is still stores in eax

mov edx, 0
div dword[length]                        ;divides array sum by the number of elements 
mov dword[saAve], eax                    ;sets value to average

;Set Volume Min/Max

mov eax, dword[surfaceAreas]             ;sets eax to first value in array
mov dword[saMin], eax                    ;sets min and max to the first value in array
mov dword[saMax], eax
mov rsi, 0                               ;reset index 
mov ecx, dword[length]                   ;amout of iterations

minSurfaceAreaLoop:
        mov eax, dword[surfaceAreas+rsi*4]; sets value of our current index to eax
        cmp eax, dword[saMin]             ; compares value to our current min
        jg minSurfaceAreaSet              ; if eax is greater than min, we jump
        mov dword[saMin], eax             ; sets new min

minSurfaceAreaSet:                       ;increments and loops back
        inc rsi 
        loop minSurfaceAreaLoop

mov rsi, 0                               ;reset index
mov ecx, dword[length]                   ;amout of iterations

maxSurfaceAreaLoop:
        mov eax, dword[surfaceAreas+rsi*4];sets value of our current index to eax
        cmp eax, dword[saMax]             ;compares value to our current max
        jl maxSurfaceAreaSet              ;if eax is less than max, we jump
        mov dword[saMax], eax             ;sets new max

maxSurfaceAreaSet:                        ;increments and loops back
        inc rsi
        loop maxSurfaceAreaLoop

;Set Surface Area Median

mov r8d, dword[length]                  ;49
mov r9d,  2                             ;middle divider
mov r11d, 3                             ;average divider      
mov eax, dword[length]                  ;sets eax to length      
mov edx, 0 
div r9d
mov r10d, eax                           ; divide length by 2, 49->24

mov eax, 0                              ;resets register to 0
add eax, dword[surfaceAreas]            ;adds first element
add eax, dword[surfaceAreas+((r10d)*4)] ;adds middle element
add eax, dword[surfaceAreas+((r8d-1)*4)];adds last element
cdq
idiv r11d
mov dword[saEstMed], eax                ;takes the average of the 3 and stores it as vEstMed

;**********************************************
;   done, to terminate program
last:
        mov     rax, SYS_exit
        mov     rdi, EXIT_SUCCESS
        syscall