; main.s
; Your named 
; Runs on LM3S1968
; Lab 2 EE319K Summer 2012
; Toggle on PG2 LED if select switch pressed pressed
; Date Created: May 23, 2012 
; Last Modified: 6/4/2012 

; "Status" LED connected to PG2	    positive logic
; "Select" button connected to PG7  negative logic


GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_PUR_R   EQU 0x40024510
GPIO_PORTE_PDR_R   EQU 0x40024514
GPIO_PORTE_DEN_R   EQU 0x4002451C
GPIO_PORTE_PIN_1   EQU 0x40024008

SYSCTL_RCGC2_R     EQU 0x400FE108
SYSCTL_RCGC2_GPIOE EQU 0x00000010
NVIC_ST_CTRL_R	   EQU 0xE000E010
NVIC_ST_RELOAD_R   EQU 0xE000E014
NVIC_ST_CURRENT_R  EQU 0xE000E018
NVIC_ST_RELOAD_M   EQU 0x00FFFFFF

SYSTICK_DELAY_1MS  EQU 0x00002ED0


      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
	
Start
	; Initialize clock
	LDR R1, =SYSCTL_RCGC2_R
	LDR R0, =SYSCTL_RCGC2_GPIOE
	STR R0, [R1]
	NOP
	NOP
	; Disable alternate function (pins 0&1)
	LDR R1, =GPIO_PORTE_AFSEL_R
	LDR R0, [R1]
	BIC R0, #0x03
	STR R0, [R1]
	; Set pull down on PORTE pin 0.
	LDR R1, =GPIO_PORTE_PDR_R
	LDR R0, [R1]
	ORR R0, #0x01
	STR R0, [R1]
	; Set direction register (0: input; 1: output)
	LDR R1, =GPIO_PORTE_DIR_R
	LDR R0, [R1]
	BIC R0, #0x01
	ORR R0, #0x02
	STR R0, [R1]
	; Digital enable (pins 0&1)
	LDR R1, =GPIO_PORTE_DEN_R
	LDR R0, [R1]
	ORR R0, #0x03
	STR R0, [R1]
	; Load initial toggle value
	MOV R1, #0x01
    LDR R2, =GPIO_PORTE_DATA_R
	LDR R3, =GPIO_PORTE_PIN_1
loop
	LDR R0, [R2]
	; Toggle R1 bit 0
	EOR R1, R1, #0x01
	ORN R0, R1, R0
	LSL R0, R0, #0x01
	STR R0, [R3]
	BL	Wait_8Hz
	B    loop

Wait_1ms
	PUSH {R0, R1, LR}
	MOV R1, #0xBB7
	MOV R0, R1
busy_loop
	SUBS R0, R0, #0x01
	BNE busy_loop
	POP {R0, R1, PC}
	
Wait_8Hz
	PUSH {R0, LR}
	MOV R0, #62
Wait_1s_repeat
	BL Wait_1ms
	SUBS R0, R0, #0x01
	BNE Wait_1s_repeat
	POP {R0, PC}
	
    ALIGN      ; make sure the end of this section is aligned
    END        ; end of file