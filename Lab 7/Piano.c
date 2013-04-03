
#define SYSCTL_RCGC2_R          (*((volatile unsigned long *)0x400FE108))
#define SYSCTL_RCGC2_GPIOG      0x00000040  // port D Clock Gating Control
#define GPIO_PORTG_DIR_R        (*((volatile unsigned long *)0x40026400))
#define GPIO_PORTG_DEN_R        (*((volatile unsigned long *)0x4002651C))
#define PIANO_IN								(*((volatile unsigned long *)0x400261C0 ))

int Piano_In(void)
{
	return PIANO_IN >> 4;
}

void Piano_Init(void)
{
	int count;
	SYSCTL_RCGC2_R |= SYSCTL_RCGC2_GPIOG;
	count = 0;
	GPIO_PORTG_DIR_R &= ~(0x70);
	GPIO_PORTG_DEN_R |= 0x70;
}
