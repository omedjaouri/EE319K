
#include "dac.h"
#include "Sound.h"
#include "SysTickInts.h"

#define GPIO_PORTG2             (*((volatile unsigned long *)0x40026010))

int count;	// Index to sine.
short inc;	// Flag to disable incrementing count.

const unsigned char sine[32] = {
	128,153,177,199,218,234,245,253,255,253,
	245,234,218,199,177,153,128,103,79,57,38,
	22,11,3,1,3,11,22,38,57,79,103
};
const unsigned long freqs[] = {
	0, 0, 0, 0,
	0, 0, 3352, 3163,
	3986, 3762, 3551, 3352,
	3163, 2986, 2818, 2660,
	2511, 2370, 2237, 2112,
	1993, 1881, 1775, 1676,
	1582, 1493, 1409, 1330
};

__asm void wait1ms(void){
	LDR R0, =0x411A;
busy_loop;
	SUBS R0, R0, #0x01;
	BNE busy_loop;
	BX LR;
}

void waitsecs(unsigned long dur){
	int i;
	for (i = 0; i < dur; i++)
		wait1ms();
}

void Sound_Init(void){
	count = 0;
	DAC_Init();
	SysTick_Init(50000);
}

void Sound_Play(int note){
	if (note == -1) inc = 0;
	else inc = 1;
	SysTick_SetReload(freqs[note]);
}

void Sound_PlaySong(
	const note *song, 
	long len, int offset, 
	unsigned long wait)
{
	int i;
	note *songptr = (note*) song;
	for (i = 0; i < len; i++)
	{
		Sound_Play((*songptr).freq+O*offset);
		songptr++;
		waitsecs((*songptr).length*wait);
	}
}

// Interrupt service routine
// Executed every 20ns*(period)
void SysTick_Handler(void){
  GPIO_PORTG2 ^= 0x04;        // toggle PD0
	if (count >= 32) count = 0;
	DAC_Out(sine[count]);
	count += inc;
}
