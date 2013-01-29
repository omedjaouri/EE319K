; main.s
; Runs on LM3S1968
; A very simple first project implementing a random number generator
; Daniel Valvano
; May 4, 2012

;  This example accompanies the book
;  "Embedded Systems: Introduction to the Arm Cortex M3",
;  ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2012
;  Section 3.3.10, Program 3.12
;
;Copyright 2012 by Jonathan W. Valvano, valvano@mail.utexas.edu
;   You may use, edit, run or distribute this file
;   as long as the above copyright notice remains
;THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
;OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
;MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
;VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
;OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
;For more information about my classes, my research, and my books, see
;http://users.ece.utexas.edu/~valvano/


    .thumb
    .text
M   .field 4,16		;M contains the value 4 in 16 bits		
		
    .align 2
    .text
    .thumb
       
 	.asg	"main", Start			; 'Start' is an alias for 'main'
	.global Start
	
	
	.thumbfunc Start
Start: .asmfunc 
       LDR R2,M       ; R4 -> M
       MOV R0,#1       ; Initial seed
       STR R0,[R2]     ; M=1
loop   BL  Random
       B   loop
       
       .endasmfunc
;------------Random------------
; Return R0= random number
; Linear congruential generator 
; from Numerical Recipes by Press et al.
	.thumbfunc Random 
Random: .asmfunc 
       LDR R2,M    ; R2 -> M
       LDR R0,[R2]  ; R0=M
       LDR R1, 1664525
       MUL R0,R0,R1 ; R0 = 1664525*M
       LDR R1, 1013904223
       ADD R0,R1    ; 1664525*M+1013904223 
       STR R0,[R2]  ; store M
       BX  LR
       .endasmfunc
       
       .end      