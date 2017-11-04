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
};

int sizeval(int size);//la table 2 size
bool sum_overflow(uword,uword,uword);
bool diff_overflow(uword,uword,uword);
//calcul du flag d'overflow (drapeau de depassement en comp a 2)
char* codename(int opcode);
//retourne une chaine contenant le nom de l'operation de no opcode
