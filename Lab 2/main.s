; main.s
; Your named 
; Runs on LM3S1968
; Lab 2 EE319K Summer 2012
; Toggle on PG2 LED if select switch pressed pressed
; Date Created: May 23, 2012 
; Last Modified: 6/4/2012 

; "Status" LED connected to PG2	    positive logic
; "Select" button connected to PG7  negative logic


GPIO_PORTG_DATA_R  EQU 0x400263FC
GPIO_PORTG_2	   EQU 0x40026010
GPIO_PORTG_DIR_R   EQU 0x40026400
GPIO_PORTG_AFSEL_R EQU 0x40026420
GPIO_PORTG_PUR_R   EQU 0x40026510
GPIO_PORTG_DEN_R   EQU 0x4002651C
SYSCTL_RCGC2_R     EQU 0x400FE108
SYSCTL_RCGC2_GPIOG EQU 0x00000040 
NVIC_ST_CTRL_R	   EQU 0xE000E010
NVIC_ST_RELOAD_R   EQU 0xE000E014
NVIC_ST_CURRENT_R  EQU 0xE000E018
NVIC_ST_RELOAD_M   EQU 0x00FFFFFF
SYSTICK_DELAY_1MS  EQU 0x00002ED0
DELAY_1MS		   EQU 0x00000BB7


      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
	
Start
	; Initialize clock
	LDR R1, =SYSCTL_RCGC2_R
	LDR R0, =SYSCTL_RCGC2_GPIOG
	STR R0, [R1]
	NOP
	NOP
	BL	SysTick_Init
	; Set direction register (pins 2&7)
	LDR R1, =GPIO_PORTG_DIR_R
	LDR R0, [R1]
	BIC R0, #0x80
	ORR R0, #0x04
	STR R0, [R1]
	; Disable alternate function (pins 2&7)
	LDR R1, =GPIO_PORTG_AFSEL_R
	LDR R0, [R1]
	BIC R0, #0x84
	STR R0, [R1]
	; Digital enable (pins 2&7)
	LDR R1, =GPIO_PORTG_DEN_R
	LDR R0, [R1]
	ORR R0, #0x84
	STR R0, [R1]
	; Load initial toggle value
	MOV R1, #0x00
    LDR R2, =GPIO_PORTG_DATA_R
	LDR R3, =GPIO_PORTG_2
loop
	LDR R0, [R2]
	; Toggle R1 bit 7
	EOR R1, R1, #0x80
	EOR R0, R0, #0x80
	AND R0, R0, R1
	LSR R0, R0, #0x05
	STR R0, [R3]
	BL	Wait_1ms
	B    loop

Wait_1ms
	PUSH {R0, R1, LR}
	LDR R1, =DELAY_1MS
	MOV R0, R1
busy_loop
	SUBS R0, R0, #0x01
	BNE busy_loop
	POP {R0, R1, PC}
	  
SysTick_Init
	; Disable SysTick
	LDR R0, =NVIC_ST_CTRL_R
	MOV R1, #0x00
	STR R1, [R0]
	; Set RELOAD Value
	LDR R1, =NVIC_ST_RELOAD_R
	LDR R2, =NVIC_ST_RELOAD_M
	STR R2, [R1]
	; Reset CURRENT
	LDR R1, =NVIC_ST_CURRENT_R
	MOV R2, #0x00
	STR R2, [R1]
	; Initialize SysTick
	MOV R1, #0x05
	STR R1, [R0]
	BX LR
	
SysTick_Wait_1ms
	PUSH {R0, R1, R2, R3, LR}
	; Loads first value of clock
	LDR R1, =NVIC_ST_CURRENT_R
	LDR R2, [R1]
	LDR R0, =SYSTICK_DELAY_1MS
SysTick_Wait_1ms_loop
	LDR R3, [R1]
	SUB R3, R2, R3
	AND R3, R3, #0x00FFFFFF
	CMP R3, R0
	BLS SysTick_Wait_1ms_loop
	POP {R0, R1, R2, R3, PC}
	
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file