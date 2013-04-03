
typedef enum {
	C, Cs,
	Df = Cs, D, Ds,
	Ef = Ds, E, Es,
	F = Es, Fs,
	Gf = Fs, G, Gs,
	Af, A, As,
	Bf = As, B, Bs = C,
	Cf = B, 
	O,
} pitch; //contains 15 elements

typedef struct {
	int freq;
	int length;
} note;

void Sound_Init(void);
void Sound_Play(int);
void Sound_PlaySong(const note*, long, int, unsigned long);
