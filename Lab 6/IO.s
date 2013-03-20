; IO.s
; Runs on LM3S1968
; EE319K lab 6 device driver for the switch and LED
; You are allowed to use any switch and any LED, 
; although the Lab suggests the Select switch PG7 and Status LED PG2
; Valvano
; March 2, 2013 (Spring 2013 version)

        EXPORT   IO_Init
        EXPORT   IO_Touch
        EXPORT   IO_HeartBeat


PG7                EQU 0x40026200
PG2                EQU 0x40026010

GPIO_PORTG_DIR_R   EQU 0x40026400
GPIO_PORTG_PUR_R   EQU 0x40026510
GPIO_PORTG_AFSEL_R EQU 0x40026420
GPIO_PORTG_DEN_R   EQU 0x4002651C

SYSCTL_RCGC2_R     EQU 0x400FE108
SYSCTL_RCGC2_GPIOG EQU 0x00000040   ; port G Clock Gating Control

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      ALIGN          

;------------IO_Init------------
; Activate Port and initialize it for switch and LED
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Init
   ; Initialize Port F pins 0,2,4,6, 5,7; Port G pin 2.
   LDR R1, =SYSCTL_RCGC2_R
   LDR R0, [R1]
   LDR R2, =SYSCTL_RCGC2_GPIOG
   ORR R0, R0, R2
   STR R0, [R1]
   
   NOP
   NOP
   
   LDR R1, =GPIO_PORTG_AFSEL_R
   LDR R0, [R1]
   BIC R0, R0, #0x84
   STR R0, [R1]
   
   LDR R1, =GPIO_PORTG_DIR_R
   LDR R0, [R1]
   ORR R0, R0, #0x04
   BIC R0, R0, #0x80
   STR R0, [R1]
   
   LDR R1, =GPIO_PORTG_DEN_R
   LDR R0, [R1]
   ORR R0, R0, #0x84
   STR R0, [R1]
   
    BX  LR                          ; return
;------------IO_Touch------------
; wait for release and touch
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Touch
	BX LR ; For use in simulation mode
    PUSH  {R4,LR}
	LDR R4, =PG7
wait_down
	LDR R0, [R4]
	CMP R0, #0x00
	BNE wait_down
	MOV R1, #10
wait10ms
	BL IO_Wait_1ms
	SUBS R1, #1
	BNE wait10ms
wait_up
	LDR R0, [R4]
	CMP R0, #0x00
	BEQ wait_up
    POP  {R4,PC}

;------------IO_HeartBeat------------
; toggles an LED
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
IO_HeartBeat
	LDR R1, =PG2
	LDR R0, [R1]
	EOR R0, #0x04
	STR R0, [R1]
    BX   LR

;------------IO_Wait1ms--------------
; waits 1ms
; Input: none
; Output: none
; This is a private function
; Invariables: This function must not permanently modify registers R4 to R11
IO_Wait_1ms
	PUSH {LR}
	MOV R0, #0x411A
busy_loop
	SUBS R0, R0, #0x01
	BNE busy_loop
	POP {PC}

    
    ALIGN
    END                             ; end of file