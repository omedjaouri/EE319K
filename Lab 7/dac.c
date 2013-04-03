
#define GPIO_PORTF_DIR_R        (*((volatile unsigned long *)0x40025400))
#define GPIO_PORTF_DEN_R        (*((volatile unsigned long *)0x4002551C))
#define GPIO_PORTF_AFSEL_R			*(volatile unsigned long*)0x40025420
#define SYSCTL_RCGC2_R          (*((volatile unsigned long *)0x400FE108))
#define SYSCTL_RCGC2_GPIOF      0x00000020  // port D Clock Gating Control
#define DACOUT									*(volatile unsigned long *)0x400253FC

void DAC_Init()
{
	int count;
	SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOF;
	count = 0;
	GPIO_PORTF_DIR_R = 0xFF;
	GPIO_PORTF_AFSEL_R = 0x00;
	GPIO_PORTF_DEN_R = 0xFF;
}

void DAC_Out(int val)
{
	DACOUT = (char) val;
}
