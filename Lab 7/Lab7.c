// PeriodicSysTickInts.c
// Runs on LM3S1968
// Use the SysTick timer to request interrupts at a particular period.
// Daniel Valvano
// June 27, 2011

/* This example accompanies the book
   "Embedded Systems: Real Time Interfacing to the Arm Cortex M3",
   ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2011

   Program 5.12, section 5.7

 Copyright 2011 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */

// oscilloscope or LED connected to PD0 for period measurement
#include "inc/hw_types.h"
#include "driverlib/sysctl.h"
#include "SysTickInts.h"
#include "Sound.h"
#include "Piano.h"

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
long StartCritical (void);    // previous I bit, disable interrupts
void EndCritical(long sr);    // restore I bit to previous value
void WaitForInterrupt(void);  // low power mode

const note green_greens[90] = {
	{C,12},{C,3},{E,1},
	{G,2},{C+O,2},{B,2},{A,2},{G,4},{E,3},{G,1},
	{F,4},{D,3},{E,1},{D,4},{E,3},{D,1},
	{C,12},{G-O,3},{G-O,1},
	{C,12},{C,3},{E,1},
	{G,2},{C+O,2},{B,2},{A,2},{G,4},{E,3},{G,1},
	{F,4},{D,3},{E,1},{D,4},{E,3},{D,1},
	{C,16},
	{C,3},{C,1},{D,2},{E,2},{-1,2},{C,2},{D,2},{C,2},
	{-1,8},//{Rest,16},{Rest,16},
	// Key change (Bf, Ef, Af)
	{Ef,4},{D,3},{Ef,1},{F,4},{Ef,3},{F,1},
	{G,4},{F,3},{G,1},{C,4},{C,3},{D,1},
	{Ef,4},{D,3},{Ef,1},{F,4},{Ef,3},{F,1},
	{G,8},{C+O,4},{C,3},{D,1},
	{Ef,4},{D,3},{Ef,1},{F,4},{Ef,3},{F,1},
	{G,4},{F,3},{G,1},{C,4},{C,3},{D,1},
	{Ef,4},{D,3},{Ef,1},{F,4},{Ef,3},{F,1},
	{D,8},{G,4},{A-O,3},{A-O,1}
};

int main(void){
	int tone;// bus clock at 50 MHz
  SysCtlClockSet(SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_OSC_MAIN |
                 SYSCTL_XTAL_8MHZ);
  SysTick_Init(50000);     // initialize SysTick timer
  EnableInterrupts();
	Piano_Init();
	Sound_Init();
	while(1){
		tone = Piano_In();
		if (tone==1){Sound_Play(D);}
		else if (tone==2){Sound_Play(F);}
		else if (tone==4){Sound_Play(A);}
		else{Sound_Play(-1);}
	}
	
	
	Sound_PlaySong(green_greens, 90, 1, 21);
  while(1){                // interrupts every 1ms
    WaitForInterrupt();
  }
}
