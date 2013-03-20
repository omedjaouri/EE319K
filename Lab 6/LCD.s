; LCD.s
; Runs on LM3S1968
; EE319K lab 6 device driver for the LCD
; Valvano
; March 2, 2013 (Spring 2013 version)
;
;  size is 1*16
;  because we do not need to read busy, then we will tie R/W=ground
;  10k potentiometer (not the slide pot for Lab 8)
;      one end of pot is +5V, 
;      center of pot to pin 3 of LCD,
;      other end of pot is ground
;  ground = pin 1    Vss
;  power  = pin 2    Vdd   +5V (EE319K LCDs)
;  pot    = pin 3    Vlc   connected to center of pot
;  PF4    = pin 4    RS    (1 for data, 0 for control/status)
;  ground = pin 5    R/W   (1 for read, 0 for write)
;  PF5    = pin 6    E     (enable)
;  PF0    = pin 11   DB4   (4-bit data)
;  PF1    = pin 12   DB5
;  PF2    = pin 13   DB6
;  PF3    = pin 14   DB7
;16 characters are configured as 2 rows of 8
;addr  00 01 02 03 04 05 06 07 40 41 42 43 44 45 46 47


        EXPORT   LCD_Open
        EXPORT   LCD_Clear
        EXPORT   LCD_OutChar
        EXPORT   LCD_GoTo
        EXPORT   LCD_OutString
        EXPORT   LCD_OutChar
        EXPORT   LCD_OutDec
        EXPORT   LCD_OutFix
		EXPORT   LCD_NewChar
		
SYSCTL_RCGC2_R          EQU 0x400FE108
SYSCTL_RCGC2_GPIOF      EQU 0x00000020   ; port F Clock Gating Control

LCD_DATA_NIBBLE_R		EQU 0x4002503C
LCD_LATCH				EQU 0x40025080
LCD_RS					EQU 0x40025040
GPIO_PORTF_DIR_R        EQU 0x40025400
GPIO_PORTF_AFSEL_R      EQU 0x40025420
GPIO_PORTF_DEN_R        EQU 0x4002551C

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      ALIGN
	  
OutFixedOFString
		DCB "*.***",0
		ALIGN

;--------------- outCsrNibble ------------------
; Sends 4 bits to the LCD control/status
; Input: R0 is 4-bit command, in bit positions 3,2,1,0 of R0
; Output: none
; This is a private function
; Invariables: This function must not permanently modify registers R4 to R11
outCsrNibble
    PUSH {R4,R5,R14}
	MOV R4, R0
	LDR R5, =LCD_DATA_NIBBLE_R
	STR R4, [R5]
	BL wait6us
	LDR R4, =LCD_LATCH
	MOV R0, #0xFF
	STR R0, [R4]
	BL wait6us
	MOV R0, #0
	STR R0, [R4]
	BL wait6us
    POP {R4,R5,PC}
	

;---------------------outCsr---------------------
; Sends one command code to the LCD control/status
; Input: R0 is 8-bit command to execute
; Output: none
;* Entry Mode Set 0,0,0,0,0,1,I/D,S
;*     I/D=1 for increment cursor move direction
;*        =0 for decrement cursor move direction
;*     S  =1 for display shift
;*        =0 for no display shift
;*   Display On/Off Control 0,0,0,0,1,D,C,B
;*     D  =1 for display on
;*        =0 for display off
;*     C  =1 for cursor on
;*        =0 for cursor off
;*     B  =1 for blink of cursor position character
;*        =0 for no blink
;*   Cursor/Display Shift  0,0,0,1,S/C,R/L,*,*
;*     S/C=1 for display shift
;*        =0 for cursor movement
;*     R/L=1 for shift to left
;*        =0 for shift to right
;*   Function Set   0,0,1,DL,N,F,*,*
;*     DL=1 for 8 bit
;*       =0 for 4 bit
;*     N =1 for 2 lines
;*       =0 for 1 line
;*     F =1 for 5 by 10 dots
;*       =0 for 5 by 7 dots 
; This is a private function
; Invariables: This function must not permanently modify registers R4 to R11
outCsr
	PUSH {R4,LR}
	MOV R4, R0
	
	MOV R0, #0
	LDR R1, =LCD_RS
	STR R0, [R1]
	BL wait6us
	
	LSR R0, R4, #4
	BL outCsrNibble
	MOV R0, R4
	BL outCsrNibble
	
	MOV R1, #15
	BL wait90us
	POP  {R4,PC}

;---------------------LCD_Open---------------------
; initialize the LCD display, called once at beginning
; Input: none
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_Open 
   PUSH {LR}
   ; Code footprint is lighter with 4 branches than a loop.
   BL wait5ms
   BL wait5ms
   BL wait5ms
   BL wait5ms
   ; Initialize clock.
   LDR R1, =SYSCTL_RCGC2_R
   LDR R0, [R1]
   LDR R2, =SYSCTL_RCGC2_GPIOF
   ORR R0, R0, R2
   STR R0, [R1]
   NOP
   NOP
   ; Configure pins.
   LDR R1, =GPIO_PORTF_AFSEL_R
   LDR R0, [R1]
   BIC R0, R0, #0x3F
   STR R0, [R1]
   LDR R1, =GPIO_PORTF_DIR_R
   LDR R0, [R1]
   ORR R0, R0, #0x3F
   STR R0, [R1]
   LDR R1, =GPIO_PORTF_DEN_R
   LDR R0, [R1]
   ORR R0, R0, #0x3F
   STR R0, [R1]
   ; Set RS to command write (outCsrNibble does not)
   MOV R0, #0
   LDR R1, =LCD_RS
   STR R0, [R1]
   BL wait6us
   
   MOV R0, #0x03
   BL outCsrNibble
   BL wait5ms
   MOV R0, #0x03
   BL outCsrNibble
   BL wait100us
   MOV R0, #0x03
   BL outCsrNibble
   BL wait100us
   MOV R0, #0x02
   BL outCsrNibble
   BL wait100us
   MOV R0, #0x28
   BL outCsr
   MOV R0, #0x14
   BL outCsr
   MOV R0, #0x06
   BL outCsr
   MOV R0, #0x0C
   BL outCsr
   
   POP {PC}


;---------------------LCD_OutChar---------------------
; sends one ASCII to the LCD display
; Input: R0 (call by value) letter is 8-bit ASCII code
; Outputs: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutChar
    PUSH {R4,LR}
	MOV R4, R0
	; Set RS to data write
	MOV R0, #0xFF
	LDR R1, =LCD_RS
	STR R0, [R1]
	BL wait6us
	
	LSR R0, R4, #4
	BL outCsrNibble
	MOV R0, R4
	BL outCsrNibble
	BL wait90us
	
    POP {R4,PC}

;---------------------LCD_Clear---------------------
; clear the LCD display, send cursor to home
; Input: none
; Outputs: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_Clear
    PUSH {LR}         
	MOV R0, #0x01
	BL outCsr
	BL wait5ms
	MOV R0, #0x02
	BL outCsr
	BL wait5ms
    POP  {PC}


;-----------------------LCD_GoTo-----------------------
; Move cursor (set display address) 
; Input: R0 is display address (DDaddr) is 0 to 7, or 0x40 to 0x47 
; Output: none
; errors: it will check for legal address
;  0) save any registers that will be destroyed by pushing on the stack
;  1) go to step 3 if DDaddr is 0x08 to 0x3F or 0x48 to 0xFFFFFFFF
;  2) outCsr(DDaddr+0x80)     
;  3) restore the registers by pulling off the stack
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_GoTo
    PUSH {LR}
	AND R0, R0, #0xFF
	CMP R0, #0x08
	BLS GOMove
	CMP R0, #0x3F
	BLS GODone
	CMP R0, #0x48
	BGE GODone
GOMove
	ADD R0, R0, #0x80
	BL outCsr
GODone
    POP  {PC}

; ---------------------LCD_OutString-------------
; Output character string to LCD display, terminated by a NULL(0)
; Inputs:  R0 (call by reference) points to a string of ASCII characters 
; Outputs: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutString
    PUSH {R4,LR}
	MOV R4, R0
	MOV R2, #0
STLoop
	LDRB R0, [R4, R2]
	CMP R0, #0
	BEQ STDone
	BL LCD_OutChar
	ADD R2, #1
	B STLoop
STDone
    POP {R4,PC}


;-----------------------LCD_NewChar--------------------
; Set new font (single character) 
; Input: R0 is CGaddr or font number (0-7), R1 is address of 8-byte font.
; Output: none; the font can be printed with LCD_OutChar(CGaddr)
; errors: it will check for legal address
;  0) save any registers that will be destroyed by pushing on the stack
;  1) go to step 4 if CGaddr is 0x08 to 0xFFFFFFFF
;  2) outCsr((CGaddr<<3)+0x40)
;  3) output each line of the font
;  4) restore the registers by pulling off the stack
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_NewChar
	PUSH {R4,LR}
	CMP R0, #7
	BHI DoneNewChar
	MOV R4, R1
	LSL R0, R0, #3
	ADD R0, R0, #0x40
	BL outCsr
	MOV R2, #0
NCLoop
	LDRB R0, [R4, R2]
	BL LCD_OutChar
	ADD R2, #1
	CMP R2, #8
	BEQ DoneNewChar
	B NCLoop
	MOV R0, #0x80
	BL outCsr
DoneNewChar
	POP {R4,PC}

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number 
; Output: none
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
    PUSH {R4,LR}
	SUB SP, #4
	CMP R0, #10
	BLO ODendcase
	MOV R1, #10
	UDIV R4, R0, R1
	BL MOD
	STR R0, [SP]
	MOV R0, R4
	BL LCD_OutDec
	LDR R0, [SP]
ODendcase
	ADD R0, #0x30
	BL LCD_OutChar
	ADD SP, #4
    POP  {R4,PC}


; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999 
; Inputs:  R0 is an unsigned 16-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 " 
;       R0=3,    then output "0.003 " 
;       R0=89,   then output "0.089 " 
;       R0=123,  then output "0.123 " 
;       R0=9999, then output "9.999 " 
;       R0>9999, then output "*.*** "
; This is a public function
; Invariables: This function must not permanently modify registers R4 to R11
		
LCD_OutFix
         PUSH {R4,LR}
		 LDR R1, =9999
		 CMP R0, R1
		 BHI OFOverflow
		 
		 MOV R4, R0
		 MOV R1, #1000
		 UDIV R0, R4, R1
		 ADD R0, #0x30
		 BL LCD_OutChar
		 
		 MOV R0, #0x2E
		 BL LCD_OutChar
		 
		 MOV R0, R4
		 MOV R1, #1000
		 BL MOD
		 MOV R4, R0
		 
		 MOV R1, #100
		 UDIV R0, R4, R1
		 ADD R0, #0x30
		 BL LCD_OutChar
		 MOV R0, R4
		 MOV R1, #100
		 BL MOD
		 MOV R4, R0
		 
		 MOV R1, #10
		 UDIV R0, R4, R1
		 ADD R0, #0x30
		 BL LCD_OutChar
		 MOV R0, R4
		 MOV R1, #10
		 BL MOD
		 
		 ADD R0, #0x30
		 BL LCD_OutChar
		 
         POP {R4,PC}
OFOverflow
		 LDR R0, =OutFixedOFString
		 BL LCD_OutString
		 POP {R4,PC}

MOD
	UDIV R2, R0, R1
	MUL R1, R2
	SUB R0, R1
	BX LR

wait6us
	PUSH {LR}
	MOV R0, #100
wait6us_loop
	SUBS R0, #1
	BNE wait6us_loop
	POP {PC}

wait90us
wait100us
; 100us waits 90us, there is little difference
	PUSH {LR}
	MOV R1, #15
wait90us_loop
	BL wait6us
	SUBS R1, #1
	BNE wait90us_loop
	POP {PC}
   
wait1ms
	PUSH {LR}
	LDR R0, =0x411A
busy_loop
	SUBS R0, R0, #0x01
	BNE busy_loop
	POP {PC}

wait5ms
	PUSH {LR}
	BL wait1ms
	BL wait1ms
	BL wait1ms
	BL wait1ms
	BL wait1ms
	POP {PC}

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file
    