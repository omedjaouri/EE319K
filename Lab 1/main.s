;****************** main.s *************** 
; Program written by: Kevin George; Omar Medjaouri
; Date Created: 1/28/2013
; Last Modified: 1/4/2013  
; Section 2-3pm     TA: 
; Lab number: 1 
; Brief description of the program 
; The overall objective of this system is a digital lock 
; Hardware connections 
;  PG3 is switch input  (negative logic) 
;  PG4 is switch input  (negative logic) 
;  PG2 is LED output (on means unlocked)  
; The specific operation of this system  
;   unlock if both switches are pressed

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

; Making Memory Locations of the Port easier to use.
GPIO_PORTG2        EQU 0x40026010 
GPIO_PORTG_DATA_R  EQU 0x400263FC 
GPIO_PORTG_DIR_R   EQU 0x40026400 
GPIO_PORTG_AFSEL_R EQU 0x40026420 
GPIO_PORTG_PUR_R   EQU 0x40026510 
GPIO_PORTG_DEN_R   EQU 0x4002651C 
SYSCTL_RCGC2_R     EQU 0x400FE108 
SYSCTL_RCGC2_GPIOG EQU 0x00000040   ; port G Clock Gating Control 

       THUMB	
       AREA    DATA, ALIGN=2
M      SPACE   4
       ALIGN          
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
Start  LDR R2,=M       ; R2 = &M, R2 points to M
       MOV R0,#1       ; Initial seed
       STR R0,[R2]     ; M=1
       ; Initialize clock.
       LDR R0, =SYSCTL_RCGC2_R
	   LDR R1, =SYSCTL_RCGC2_GPIOG
	   STR R1, [R0]
	   ; Wait two bus cycles.
	   NOP
	   NOP
	   ; Update PORTG direction register.
	   LDR R0, =GPIO_PORTG_DIR_R
	   LDR R1, [R0]
	   ORR R1, R1, #0x04
	   BIC R1, R1, #0x18
	   STR R1, [R0]
	   ; Digital Enable.
	   LDR R0, = GPIO_PORTG_DEN_R
	   LDR R1, [R0]
	   ORR R1, R1, #0x1C
	   STR R1, [R0]
	   ; Loop unto infinity.
	   ; Reading Data from PG3 and PG4
read   LDR R0, =GPIO_PORTG_DATA_R
       LDR R1, [R0]
	   ; Logic Operatons: PG2=(not(PG3)) and (not(PG4))
	   AND R2, R1, #0x10
	   AND R1, R1, #0x08
	   ASR R1, R1, #1
	   ASR R2, R2, #2
	   ORR R1, R1, R2
	   EOR R1, #0x04
	   ; Storing Data to PG2
	   LDR R0, =GPIO_PORTG2
	   STR R1, [R0]
	   B   read
       ALIGN      
       END  
           