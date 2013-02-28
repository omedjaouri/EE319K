; Debug.s

GPIO_PORTE_DATA_R  EQU 0x400243FC
SYSCTL_RCGC2_R     EQU 0x400FE108
SYSCTL_RCGC2_GPIOG EQU 0x00000040
GPIO_PORTG_DATA_R  EQU 0x400263FC
GPIO_PORTG_AFSEL_R EQU 0x40026420
GPIO_PORTG_DIR_R   EQU 0x40026400
GPIO_PORTG_PUR_R   EQU 0x40026510
GPIO_PORTG_DEN_R   EQU 0x4002651C
NVIC_ST_CURRENT_R  EQU 0xE000E018
CLEAR_ENTRY        EQU 0xFFFFFFFF

        AREA    DATA, ALIGN=2
DataBuffer
	SPACE 50
TimeBuffer
	SPACE 200
DataPt
	SPACE 4
TimePt
	SPACE 4

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        IMPORT   SysTick_Init
        EXPORT   Debug_Init
		EXPORT   Debug_Capture
		
Debug_Init
	PUSH {R0,R1,R2,R3,LR}
	LDR R1, =SYSCTL_RCGC2_R
	LDR R0, =SYSCTL_RCGC2_GPIOG
	LDR R2, [R1]
	ORR R2, R2, R0
	STR R2, [R1]
	MOV R0, #200
	LDR R1, =CLEAR_ENTRY
	LDR R2, =TimeBuffer
time_init_loop
	SUB R0, R0, #4
	STR R1, [R2,R0]
	CMP R0, #0
	BNE time_init_loop
	MOV R0, #50
	LDR R2, =DataBuffer
data_init_loop
	SUB R0, R0, #1
	STRB R1, [R2,R0]
	CMP R0, #0
	BNE data_init_loop
	
	LDR R0, =DataPt
	STR R2, [R0]
	LDR R2, =TimeBuffer
	LDR R0, =TimePt
	STR R2, [R0]
	BL SysTick_Init
	; Initialize heartbeat instrument
	; Disable pull-up on pin 2
	LDR R0, =GPIO_PORTG_AFSEL_R
	LDR R1, [R0]
	BIC R1, R1, #0x04
	STR R1, [R0]
	; Set direction register on heartbeat LED
	LDR R0, =GPIO_PORTG_DIR_R
	LDR R1, [R0]
	ORR R1, R1, #0x04
	STR R1, [R0]
	; Set pull up on pin 2
	LDR R0, =GPIO_PORTG_PUR_R
	LDR R1, [R0]
	ORR R1, R1, #0x04
	STR R1, [R0]
	; Enable heartbeat LED
	LDR R0, =GPIO_PORTG_DEN_R
	LDR R1, [R0]
	ORR R1, R1, #0x04
	STR R1, [R0]
	POP {R0,R1,R2,R3,PC}
	
Debug_Capture
	; Uses on the order of 30 bus cycles when capturing, 8 when full.
	; Consumes .000084% of time.
	PUSH {R0,R1,R2,LR}
	; Heartbeat
	LDR R0, =GPIO_PORTG_DATA_R
	LDR R1, [R0]
	EOR R1, #0x04
	STR R1, [R0]
	; Checking that DataPt does not exceed DataBuffer by more than 49
	LDR R0, =DataPt
	LDR R1, [R0]
	LDR R0, =DataBuffer
	SUB R0, R1, R0
	CMP R0, #200
	BHS Debug_Full
	; Reading Port E Data
	LDR R1, =GPIO_PORTE_DATA_R
	LDR R0, [R1]
	; Selecting bits and shifting to appropriate position
	AND R1, R0, #0x01
	AND R2, R0, #0x02
	LSL R1, R1, #4
	LSR R2, R2, #1
	ORR R1, R1, R2
	; Appending to DataBuffer
	LDR R2, =DataPt
	LDR R0, [R2]
	STRB R1, [R0]
	; Incrementing DataPt
	ADD R0, R0, #1
	STR R0, [R2]
	; Loading Current SysTick Time
	LDR R0, =NVIC_ST_CURRENT_R
	LDR R1, [R0]
	LDR R2, =TimePt
	LDR R0, [R2]
	STR R1, [R0]
	; Incrementing TimePt
	ADD R0, R0, #4
	STR R0, [R2]
Debug_Full
	POP {R0,R1,R2,PC}
	

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
	