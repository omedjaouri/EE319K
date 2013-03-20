; PLL.s
; Runs on LM3S968
; A software function to change the bus speed using the PLL.
; Commented lines in the function PLL_Init() initialize the PWM
; to either 25 MHz or 50 MHz.  When using an oscilloscope to
; look at LED0, it should be clear to see that the LED flashes
; about 2 (50/25) times faster with a 50 MHz clock than with a
; 25 MHz clock.
; Daniel Valvano
; February 21, 2012

;  This example accompanies the book
;  "Embedded Systems: Introduction to the Arm Cortex M3",
;  ISBN: 978-1469998749, Jonathan Valvano, copyright (c) 2012
;  Example xx, Program 2.10
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

SYSCTL_RIS_R           EQU 0x400FE050
SYSCTL_RIS_PLLLRIS     EQU 0x00000040  ; PLL Lock Raw Interrupt Status
SYSCTL_RCC_R           EQU 0x400FE060
SYSCTL_RCC_SYSDIV_M    EQU 0x07800000  ; System Clock Divisor
SYSCTL_RCC_SYSDIV_4    EQU 0x01800000  ; System clock /4
SYSCTL_RCC_SYSDIV_5    EQU 0x02000000  ; System clock /5
SYSCTL_RCC_SYSDIV_6    EQU 0x02800000  ; System clock /6
SYSCTL_RCC_SYSDIV_7    EQU 0x03000000  ; System clock /7
SYSCTL_RCC_SYSDIV_8    EQU 0x03800000  ; System clock /8
SYSCTL_RCC_SYSDIV_9    EQU 0x04000000  ; System clock /9
SYSCTL_RCC_SYSDIV_10   EQU 0x04800000  ; System clock /10
SYSCTL_RCC_SYSDIV_11   EQU 0x05000000  ; System clock /11
SYSCTL_RCC_SYSDIV_12   EQU 0x05800000  ; System clock /12
SYSCTL_RCC_SYSDIV_13   EQU 0x06000000  ; System clock /13
SYSCTL_RCC_SYSDIV_14   EQU 0x06800000  ; System clock /14
SYSCTL_RCC_SYSDIV_15   EQU 0x07000000  ; System clock /15
SYSCTL_RCC_SYSDIV_16   EQU 0x07800000  ; System clock /16
SYSCTL_RCC_USESYSDIV   EQU 0x00400000  ; Enable System Clock Divider
SYSCTL_RCC_PWRDN       EQU 0x00002000  ; PLL Power Down
SYSCTL_RCC_OEN         EQU 0x00001000  ; PLL Output Enable
SYSCTL_RCC_BYPASS      EQU 0x00000800  ; PLL Bypass
SYSCTL_RCC_XTAL_M      EQU 0x000003C0  ; Crystal Value
SYSCTL_RCC_XTAL_6MHZ   EQU 0x000002C0  ; 6 MHz Crystal
SYSCTL_RCC_XTAL_8MHZ   EQU 0x00000380  ; 8 MHz Crystal
SYSCTL_RCC_OSCSRC_M    EQU 0x00000030  ; Oscillator Source
SYSCTL_RCC_OSCSRC_MAIN EQU 0x00000000  ; MOSC

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT  PLL_Init

;------------PLL_Init------------
; Configure the system to get its clock from the PLL.
; Input: none
; Output: none
; Modifies: R0, R1, R2, R3
PLL_Init
    ; 1) bypass PLL and system clock divider while initializing
    LDR R1, =SYSCTL_RCC_R           ; R1 = SYSCTL_RCC_R
    LDR R0, [R1]                    ; R0 = [R1]
    ORR R0, R0, #SYSCTL_RCC_BYPASS  ; R0 = R0|SYSCTL_RCC_BYPASS
    BIC R0, R0, #SYSCTL_RCC_USESYSDIV;R0 = R0&~SYSCTL_RCC_USESYSDIV
    STR R0, [R1]                    ; [R1] = R0
    ; 2) select the crystal value and oscillator source
    BIC R0, R0, #SYSCTL_RCC_XTAL_M  ; R0 = R0&~SYSCTL_RCC_XTAL_M (clear XTAL field)
    ORR R0, R0, #SYSCTL_RCC_XTAL_8MHZ;R0 = R0|SYSCTL_RCC_XTAL_8MHZ (configure for 8 MHz crystal)
    BIC R0, R0, #SYSCTL_RCC_OSCSRC_M; R0 = R0&~SYSCTL_RCC_OSCSRC_M (clear oscillator source field)
                                    ; R0 = R0|SYSCTL_RCC_OSCSRC_MAIN (configure for main oscillator source)
    ORR R0, R0, #SYSCTL_RCC_OSCSRC_MAIN
    ; 3) activate PLL by clearing PWRDN and OEN
    BIC R0, R0, #SYSCTL_RCC_PWRDN   ; R0 = R0&~SYSCTL_RCC_PWRDN
    BIC R0, R0, #SYSCTL_RCC_OEN     ; R0 = R0&~SYSCTL_RCC_OEN
    ; 4) set the desired system divider and the USESYSDIV bit
    BIC R0, R0, #SYSCTL_RCC_SYSDIV_M; R0 = R0&~SYSCTL_RCC_SYSDIV_M (clear system clock divider field)
    ORR R0, R0, #SYSCTL_RCC_SYSDIV_4; R0 = R0|SYSCTL_RCC_SYSDIV_4 (configure for 50 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_5; R0 = R0|SYSCTL_RCC_SYSDIV_5 (configure for 40 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_6; R0 = R0|SYSCTL_RCC_SYSDIV_6 (configure for 33.33 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_7; R0 = R0|SYSCTL_RCC_SYSDIV_7 (configure for 28.57 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_8; R0 = R0|SYSCTL_RCC_SYSDIV_8 (configure for 25 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_9; R0 = R0|SYSCTL_RCC_SYSDIV_9 (configure for 22.22 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_10;R0 = R0|SYSCTL_RCC_SYSDIV_10 (configure for 20 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_11;R0 = R0|SYSCTL_RCC_SYSDIV_11 (configure for 18.18 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_12;R0 = R0|SYSCTL_RCC_SYSDIV_12 (configure for 16.67 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_13;R0 = R0|SYSCTL_RCC_SYSDIV_13 (configure for 15.38 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_14;R0 = R0|SYSCTL_RCC_SYSDIV_14 (configure for 14.29 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_15;R0 = R0|SYSCTL_RCC_SYSDIV_15 (configure for 13.33 MHz clock)
;    ORR R0, R0, #SYSCTL_RCC_SYSDIV_16;R0 = R0|SYSCTL_RCC_SYSDIV_16 (configure for 12.5 MHz clock) (default setting)
    ORR R0, R0, #SYSCTL_RCC_USESYSDIV;R0 = R0|SYSCTL_RCC_USESYSDIV
    STR R0, [R1]                    ; [R1] = R0
    ; 5) wait for the PLL to lock by polling PLLLRIS
PLL_Init_loop
    LDR R3, =SYSCTL_RIS_R           ; R3 = SYSCTL_RIS_R
    LDR R2, [R3]                    ; R2 = [R3]
    ANDS R2, R2, #SYSCTL_RIS_PLLLRIS; R2 = R2&SYSCTL_RIS_PLLLRIS
    BEQ PLL_Init_loop               ; if(R2 == 0), keep polling
    ; 6) enable use of PLL by clearing BYPASS
    BIC R0, R0, #SYSCTL_RCC_BYPASS  ; R0 = R0&~SYSCTL_RCC_BYPASS
    STR R0, [R1]                    ; [R1] = R0
    BX  LR                          ; return

    ALIGN                           ; make sure the end of this section is aligned
    END                             ; end of file