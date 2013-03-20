; main.s
; Runs on LM3S1968
; Lab 6 Test of LCD driver
; March 2, 2013 (Spring 2013 version)
; Select switch PG7 (negative logic) used to cycle through outputs
; Status LED PG2 (positive logic) used for heart beat

       AREA      DATA, ALIGN=2
; Global variables go here
       ALIGN          
       AREA     |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT   Start
       IMPORT   PLL_Init
       IMPORT   LCD_Open
       IMPORT   LCD_Clear
       IMPORT   LCD_OutChar
       IMPORT   LCD_GoTo
       IMPORT   LCD_OutString
       IMPORT   LCD_OutChar
       IMPORT   LCD_OutDec
       IMPORT   LCD_OutFix       
       IMPORT   IO_Init
       IMPORT   IO_Touch
       IMPORT   IO_HeartBeat
	   IMPORT   LCD_NewChar

Number_fonts EQU 6
Fonts ; First font is clear b/c 0 is null terminator.
	DCD 0, 0
MusicNote
	DCB 0x01, 0x03, 0x05, 0x09
	DCB 0x0B, 0x0B, 0x18, 0x18
LongHorn
	DCB 0x00, 0x00, 0x11, 0x0E
	DCB 0x04, 0x04, 0x00, 0x00
Smiley
	DCB 0x00, 0x00, 0x0A, 0x00
	DCB 0x11, 0x0E, 0x00, 0x00
Winky
	DCB 0x00, 0x12, 0x1A, 0x00
	DCB 0x11, 0x0E, 0x00, 0x00
Pipe
	DCB 0x00, 0x00, 0x11, 0x11
	DCB 0x0A, 0x0A, 0x0A, 0x00 
Sigma
	DCB 0x1F, 0x10, 0x08, 0x04
	DCB 0x04, 0x08, 0x10, 0x1F
	
Start  BL   PLL_Init    ; running at 50 MHz
       BL   IO_Init     ; ***Your function that initialize switch and LED
       BL   LCD_Open    ; ***Your function that initializes LCD interface
   
run    BL   LCD_Clear     ;***Your function that clears the display
       LDR  R0,=Welcome
       BL   LCD_OutString ;***Your function that outputs a string

	   MOV  R4, #0
	   LDR  R5, =Fonts
setfonts
       MOV  R0, R4
       LSL  R1, R4, #3
	   ADD  R1, R1, R5
	   BL   LCD_NewChar
	   CMP  R4, #Number_fonts
	   ADD  R4, R4, #1
	   BLE  setfonts

       ;BL   IO_Touch

       LDR  R4,=TestData
       LDR  R5,=TestEnd
       BL   IO_Touch     ;***Your function that waits for release and touch 
loop   BL   IO_HeartBeat ;***Your function that toggles LED
       BL   LCD_Clear    ;***Your function that clears the display
       LDR  R0, [R4]
       BL   LCD_OutDec   ;***Your function that outputs an integer
       MOV  R0, #0x40    ;Cursor location of the 8th position
       BL   LCD_GoTo     ;***Your function that moves the cursor
       LDR  R0, [R4],#4
       BL   LCD_OutFix   ;***Your function that outputs a fixed-point
       BL   IO_Touch     ;***Your function that waits for release and touch 
       CMP  R4, R5
       BNE  loop
	   
	   BL   LCD_Clear
	   LDR  R0, =Truths
	   BL   LCD_OutString
	   BL   IO_Touch
	   
	   BL   LCD_Clear
	   LDR  R0, =Symbols
	   BL   LCD_OutString
	   BL   IO_Touch
	   
       B    run
       ALIGN
Welcome  DCB "Welcome "
         DCB "                                " ;32 spaces
         DCB "to 319K",0x02,0
         ALIGN
Symbols  DCB 1,2,3,4,5,6, 0
		 ALIGN
Truths	 DCB "Internet"
         DCB "                                " ;32 spaces
		 DCB "=",6,5," ",3,0
		 ALIGN
TestData DCD 0,7,34,199,321,654,4789,9999,10000,21896,65535,12345678
TestEnd  DCD 0
         ALIGN                       
         

    ALIGN
    END                             ; end of file
    