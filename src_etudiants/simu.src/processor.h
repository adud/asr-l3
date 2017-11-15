#include "memory.h" 

class Processor {
 public:
	Processor(Memory* m);
	~Processor();
	int von_Neuman_step(bool debug);

 private:
	void read_bit_from_pc(int& var);
	//ajoute en fin de var le bit lu
	void read_reg_from_pc(int& var);
	//stocke dans var le registre indique par 3bits lus
	void read_const_from_pc(uint64_t& var,bool sex);
	//lit la constante, puis stocke sa valeur dans var
	//(sex?avec:sans) extension de signe
	//!!! la constante 1 est toujours prise sans extension
	void read_addr_from_pc(uword& var);
	//lit l'addresse et la stocke dans var
	void read_shiftval_from_pc(int& var);
	//lit la valeur de shift et la stocke dans var
	void read_counter_from_pc(int& var);
	//lit 2bits et stocke le compteur associé dans var
	void read_size_from_pc(int& var);
	//lit 2 ou 3 bits et stocke la taille representee dans var
	void read_cond_from_pc(int& var);
	//lit 3 bits correspondant a une condition
	bool cond_true(int cond);
	//interroge les flags pour savoir si une condition est vraie
	void incr_count(int counter);
	//incremente le counter *du proc* en argument
	void set_count(int counter,uword offset);
	//met a offset le counter *du proc* en argument
	int read_bit_proc(int ctr, bool code);
	//appelle read_bit de la memoire, et incremente les
	//compteurs de lecture
	//si code vaut 1, les bits lus sont consideres comme du
	//code et non-ajoutes a rbitsprgctr
	void write_bit_proc(int ctr, int bit);
	//idem 
	Memory *m;
	uword pc;
	uword sp;
	uword a1;
	uword a2;
	// The registers. Beware, they are defined as unsigned integers:
	// they should be cast to signed when needed
	uword r[8];

	// the flags
	bool zflag;
	bool cflag;
	bool nflag;
	bool vflag; //ajout pour maxint >s minint (ce serait bien)

	//for the stats output
	unsigned int opctr[40]; //compte le nb d'appels a chq op
	unsigned int instr_bits_ctr;//compte le nb de bits d'instr

	unsigned int rbitsctr;//compte le nb de bits lus
	unsigned int rbitsmemctr;//compte le nb de bits lus, en
	//dehors de ceux par le programme
	unsigned int wbitsctr;//compte le nombre de bits ecrits

	
};

int sizeval(int size);//la table 2 size
bool sum_overflow(uword,uword,uword);
bool diff_overflow(uword,uword,uword);
//calcul du flag d'overflow (drapeau de depassement en comp a 2)
int opflat(int opcode);
//aplatit les opcodes : donne leur no dans la table de l'isa
//sauf readsze qui ont ete deplaces apres

char* opname(int opcode);
//retourne une chaine contenant le nom de l'operation de no opcode
