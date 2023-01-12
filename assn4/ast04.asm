;  Name: Marlon Alejandro
;  NSHE ID: 50002573038
;  Section: 1003
;  Assignment: 4
;  Description: Loops, Conditions, Arrays
;
; *****************************************************************
;  Static Data Declarations (initialized)
section .data
; -----
;  Define constants.
NULL            equ     0                       ; end of string
TRUE            equ     1
FALSE           equ     0
EXIT_SUCCESS    equ     0                       ; successful operation
SYS_exit        equ     60                      ; call code for terminate
; -----
lst             dd      4224, 1116, 1542, 1240, 1677
                dd      1635, 2420, 1820, 1246, 1333
                dd      2315, 1215, 2726, 1140, 2565
                dd      2871, 1614, 2418, 2513, 1422
                dd      1119, 1215, 1525, 1712, 1441
                dd      3622, 1731, 1729, 1615, 2724
                dd      1217, 1224, 1580, 1147, 2324
                dd      1425, 1816, 1262, 2718, 1192
                dd      1435, 1235, 2764, 1615, 1310
                dd      1765, 1954, 1967, 1515, 1556
                dd      1342, 7321, 1556, 2727, 1227
                dd      1927, 1382, 1465, 3955, 1435
                dd      1225, 2419, 2534, 1345, 2467
                dd      1615, 1959, 1335, 2856, 2553
                dd      1035, 1833, 1464, 1915, 1810
                dd      1465, 1554, 1267, 1615, 1656
                dd      2192, 1825, 1925, 2312, 1725
                dd      2517, 1498, 1677, 1475, 2034
                dd      1223, 1883, 1173, 1350, 2415
                dd      1335, 1125, 1118, 1713, 3025
length          dd      100
lstMin          dd      0
estMed          dd      0
lstMax          dd      0
lstSum          dd      0
lstAve          dd      0
oddCnt          dd      0
oddSum          dd      0
oddAve          dd      0
nineCnt         dd      0
nineSum         dd      0
nineAve         dd      0
count           dd      0

section .bass
;no uninitialized datas
;**********************************************
section .text
global _start
_start:
;**********************************************
; sum of entire array

mov ecx, dword[length]                  ;amout of iterations
mov eax, 0                              ;initilizes register for our sum to zero
mov rsi, 0                              ; array index

loopSumArray:   
        add eax, dword[lst + (rsi * 4)] ; adds current array index to our sum
        dec ecx                         ; decrement remaining iterations
        inc rsi                         ; increment our position to the index
        cmp ecx, 0                      ;checks if we are at the end of our array
        jne loopSumArray                ; loops back if 
        mov dword[lstSum], eax          ; eax is lstSum

;average value of our array
mov edx, 0
div dword[length]                       ; divides array sum by the number of elements 
mov dword[lstAve], eax                  ; sets value to average

;**********************************************
;Min/Max

mov eax, dword[lst]                     ;sets eax to first value in array
mov dword[lstMin], eax                  ;sets min and max to the first value in array
mov dword[lstMax], eax
mov rsi, 0                              ;reset index 
mov ecx, dword[length]                  ;amout of iterations

minLoop:
        mov eax, dword[lst + rsi * 4]   ; sets value of our current index to eax
        cmp eax, dword[lstMin]          ; compares value to our current min
        ja minSet                       ; if eax is greater than min, we jump
        mov dword[lstMin], eax          ; sets new min

minSet:                                 ; increments and loops back
        inc rsi 
        loop minLoop

mov rsi, 0                              ;list clear 
mov ecx, dword[length]                  ;100 

maxLoop:
        mov eax, dword[lst + rsi *4]    ; sets value of our current index to eax
        cmp eax, dword[lstMax]          ; compares value to our current max
        jb maxSet                       ; if eax is less than max, we jump
        mov dword[lstMax], eax          ; sets new max

maxSet:                                 ; increments and loops back
        inc rsi
        loop maxLoop

;**********************************************
;Estimated median 

mov r9d, 2                              ; operations to get our desired indexes
mov eax, dword[length]                  
mov edx, 0
div r9d
mov r9d, eax
mov r8d, 4
mov eax, dword[lst]                     ; adds al our designated values together
add eax, dword[lst + (r9d*4)]
add eax, dword[lst + ((r9d-1)*4)]
add eax, dword[lst + ((esi-1)*4)]
mov edx, 0
div r8d
mov dword[estMed], eax                  ; takes the everage of them and stores it as our new median

;**********************************************
;Odd values
        
mov rsi, 0                              ;resets index 
mov ebx, 0                              ;odd counter
mov r8d, 2                               
mov ecx, dword[length]                  ;interations
mov r9d, 0                              ;initialize sum of odd #s

OddCount:
        mov eax, dword[lst + (rsi * 4)] ; current index
        inc rsi                         ; increment index
        dec ecx                         ; decrement iterations

        mov edx, 0  
        div r8d 
        cmp edx, 0                      ; check if current number is even
        je OddCount                     ; if so, jump back into loop 
        inc ebx                         ; if odd increment counter  
        add r9d, dword[lst + ((rsi-1) * 4)] ;add current value into our sum of odd numbers
        cmp ecx, 0                      ; checks if we are at the end of our array
        jne OddCount                    ; if not, loop back

mov dword[oddCnt], ebx                  ; if so, set oddCnt
mov dword[oddSum], r9d                  ; set oddSum 
mov eax, r9d                    
mov edx, 0
div dword[oddCnt]               
mov dword[oddAve], eax                  ; calculate average and store into oddAve

;******************************************
; Nine values

mov rsi, 0                              ;resets index  
mov ebx, 0                              ;nine counter
mov r8d, 9
mov ecx, dword[length]                  ;interations
mov r9d, 0                              ;intialize sum of nine numbers

NineCount:
        mov eax, dword[lst + (rsi * 4)] ;current index 
        inc rsi                         ; increment index
        dec ecx                         ; decrement iterations
        mov edx, 0  
        div r8d 
        cmp ecx, 0                      ; checks if we are at the end of the array
        je nineValuesFound              ; if we are we jump
        cmp edx, 0                      ; checks if current value is divisable by nine
        jne NineCount                   ; if not we loops back
        inc ebx                         ; increment nine counter
        add r9d, dword[lst + ((rsi-1) * 4)] ;adds element to our sum of nines
        jmp NineCount                   ; loops back

nineValuesFound:
        mov dword[nineCnt], ebx         ;set nineCnt 
        mov dword[nineSum], r9d         ;set nineSum 
        mov eax, r9d                    
        mov edx, 0
        div dword[nineCnt]
        mov dword[nineAve], eax         ;calculate and set nineAve
        
;**********************************************
;   done, to terminate program
last:
        mov     rax, SYS_exit
        mov     rdi, EXIT_SUCCESS
        syscall
