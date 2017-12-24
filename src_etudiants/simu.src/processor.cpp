#include "processor.h"
using namespace std;

char t[39][7] = {"add2","add2i","sub2","sub2i","cmp","cmpi","let","leti","shift","tsnh","jump","jumpif","readze","readse",
		 "or2","or2i","and2","and2i","write","call","setctr","getctr","push","return","add3","add3i","sub3","sub3i",
		 "and3","and3i","or3","or3i","xor3","xor3i","asr3","?","?","?","???"};

char rcat[RCAT][7] = {"ins","dat","scr","kbd","clk"};
char wcat[WCAT][7] = {"dat","scr"};


void settoz(unsigned int *tb, int size)
{
	for(int i(0);i<size;tb[i++]=0){}
	return;
}

Processor::Processor(Memory* m): m(m) {
	pc=0;
	sp=spinit;
	a1=0;
	a2=0;
	for (int i=0; i<7; i++)
		r[i]=0;
	resetctrs();
}

Processor::~Processor()
{
  delete m;
}


int Processor::von_Neuman_step(bool debug) {
	// numbers read from the binary code
	int opcode=0;
	int regnum1=0;
	int regnum2=0;
	int regnum3=0;
	int shiftval=0;
	int condcode=0;
	int counter=0;
	int size=0;
	uword offset; 
	uint64_t constop=0; 
	int dir=0;
	// each instruction will use some of the following variables:
	// all unsigned, to be cast to signed when required.
	uword uop1;
	uword uop2;
	uword ur=0;
	doubleword fullr=0;
	bool manage_flags=false; // used to factor out the flag management code
	int instr_pc = pc; // for the debug output
	// read 4 bits.
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);

	switch(opcode) {

	case 0x0: // add2
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop1 = r[regnum1];
		uop2 = r[regnum2];
		fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
		ur = uop1 + uop2;
		r[regnum1] = ur;
		vflag = sum_overflow(uop1,uop2,ur);
		manage_flags=true;
		break;

	case 0x1: // add2i
		read_reg_from_pc(regnum1);
		read_const_from_pc(constop,false);
		uop1 = r[regnum1];
		uop2 = constop; 
		fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
		ur = uop1 + uop2;
		r[regnum1] = ur;
		vflag = sum_overflow(uop1,uop2,ur);
		manage_flags=true;
		break;

	case 0x2://sub2
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop1=r[regnum1];
		uop2=r[regnum2];
		fullr = ((doubleword) uop1) - ((doubleword) uop2);
		ur = uop1 - uop2;
		r[regnum1] = ur;
		vflag = diff_overflow(uop1,uop2,ur);
		manage_flags=true;
		break;
	case 0x3://sub2i
		read_reg_from_pc(regnum1);
		read_const_from_pc(constop,false);
		uop1=r[regnum1];
		uop2=constop;
		fullr = ((doubleword) uop1) - ((doubleword) uop2);
		ur = uop1 - uop2;
		r[regnum1] = ur;
		vflag = diff_overflow(uop1,uop2,ur);
		manage_flags=true;
		break;
	case 0x4://cmp
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop1=r[regnum1];
		uop2=r[regnum2];
		fullr = ((doubleword) uop1) - ((doubleword) uop2);
		ur = uop1 - uop2;
		vflag = diff_overflow(uop1,uop2,ur);
		manage_flags=true;
		break;
	case 0x5://cmpi
		read_reg_from_pc(regnum1);
		read_const_from_pc(constop,true);
		uop1=r[regnum1];
		uop2=constop;
		fullr = ((doubleword) uop1) - ((doubleword) uop2);
		ur = uop1 - uop2;
		vflag = diff_overflow(uop1,uop2,ur);
		manage_flags=true;
		break;
	case 0x6://let
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		r[regnum1] = r[regnum2];
		manage_flags=false;
		break;
	case 0x7://leti
		read_reg_from_pc(regnum1);
		read_const_from_pc(constop,true);
		r[regnum1] = constop;
		manage_flags=false;
		break;

	case 0x8: // shift
		read_bit_from_pc(dir);
		read_reg_from_pc(regnum1);
		read_shiftval_from_pc(shiftval);
		uop1 = r[regnum1];
		if(dir==1){ // right shift
			ur = uop1 >> shiftval;
			cflag = ( ((uop1 >> (shiftval-1))&1) == 1);
		}
		else{
			cflag = ( ((uop1 << (shiftval-1)) & (1L<<(WORDSIZE-1))) != 0);
			ur = uop1 << shiftval;
		}
		r[regnum1] = ur;
		zflag = (ur==0);
		// no change to nflag ????
		nflag = (sword) ur < 0;
		vflag = false;
		manage_flags=false;		
		break;

	case 0x9:
		read_bit_from_pc(opcode); //read 1 more bit
		switch(opcode){
		case 0b10010://readze
			read_counter_from_pc(counter);
			read_size_from_pc(size);
			read_reg_from_pc(regnum1);
			
			for(int i=0;i<size;i++){
				ur = (ur<<1) + read_bit_proc(counter,
					      idrru(m->counter[counter]));
				incr_count(counter);
			}
			r[regnum1] = ur;
			manage_flags = false;
			break;
			
		case 0b10011://readse
			read_counter_from_pc(counter);
			read_size_from_pc(size);
			read_reg_from_pc(regnum1);
			
			for(int i=0;i<size;i++){
				ur = (ur<<1) +
					read_bit_proc(counter, 
					    idrru(m->counter[counter]));
				incr_count(counter);
			}
			
			int fbit = (ur >> (size-1));
			for(int i=size;i<WORDSIZE;i++)
			{
				ur += (fbit << i); 
			}
			r[regnum1] = ur;
			manage_flags = false;
			break;
		}
		
		break;
	case 0xa: // jump
		read_addr_from_pc(offset);
		pc += offset;
		m -> set_counter(PC, (uword)pc);
		manage_flags=false;		
		break;
		
	case 0xb: //jumpif
		read_cond_from_pc(condcode);
		read_addr_from_pc(offset);
		if(cond_true(condcode)){
			pc += offset;
			m->set_counter(PC, (uword)pc);
		}
		manage_flags=false;
		break;
		
	case 0xc:
		//read two more bits
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		switch(opcode){
		case 0b110000://or2
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			ur = uop1|uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;

		case 0b110001://or2i
			read_reg_from_pc(regnum1);
			read_const_from_pc(constop,false);
			uop1 = r[regnum1];
			uop2 = constop;
			ur = uop1|uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;
			
		case 0b110010://and2
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			ur = uop1&uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;

		case 0b110011://and2i
			read_reg_from_pc(regnum1);
			read_const_from_pc(constop,false);
			uop1 = r[regnum1];
			uop2 = constop;
			ur = uop1&uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;
			
		}
		break;
	case 0xd:
		//read two more bits
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		switch(opcode) {
			
		case 0b110100: // write
			// begin sabote
			read_counter_from_pc(counter);
			read_size_from_pc(size);
			read_reg_from_pc(regnum1);
			uop1 = r[regnum1];
			for(int i=size-1;i>=0;i--)
			{
				write_bit_proc(counter,1 & (uop1>>i),idwru(m->counter[counter]));
				incr_count(counter);
			}
			//end sabote
			manage_flags = false;
			break;
			
		case 0b110101: //call
			read_addr_from_pc(offset);
			r[7] = pc;
			m->set_counter(PC,offset);
			pc = offset;
			manage_flags = false;
			break;
		case 0b110110: //setctr
			read_counter_from_pc(counter);
			read_reg_from_pc(regnum1);
			uop1 = r[regnum1];
			m->set_counter(counter,uop1);
			set_count(counter,uop1);
			manage_flags = false;
			break;
			
		case 0b110111: //getctr
			read_counter_from_pc(counter);
			read_reg_from_pc(regnum1);
			r[regnum1] = m->counter[counter];
			manage_flags = false;
			break;
		}
		break; // Do not forget this break! 
		
	case 0xe:
		//read 3 more bits
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		switch(opcode){
		case 0b1110000://push (sans size !!!)
			read_reg_from_pc(regnum1);
			uop1 = r[regnum1];
   			sp -= WORDSIZE;
			m->set_counter(SP,sp);
			for(int i=WORDSIZE-1;i>=0;i--)
				write_bit_proc(SP,(uop1>>i)&1,0);
			m->set_counter(SP,sp);
			manage_flags = false;
			break;
		case 0b1110001://return
			m->set_counter(PC,r[7]);
			set_count(PC,r[7]);
			manage_flags = false;
			break;
		case 0b1110010://add3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop1 = r[regnum2];
			uop2 = r[regnum3];
			fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
			ur = uop1 + uop2;
			r[regnum1] = ur;
			vflag = sum_overflow(uop1,uop2,ur);
			manage_flags=true;
			break;
		case 0b1110011://add3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop,false);
			uop1 = r[regnum2];
			uop2 = constop; 
			fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
			ur = uop1 + uop2;
			r[regnum1] = ur;
			vflag = sum_overflow(uop1,uop2,ur);
			manage_flags=true;
			break;
		case 0b1110100://sub3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop1=r[regnum2];
			uop2=r[regnum3];
			fullr = ((doubleword) uop1) - ((doubleword) uop2);
			ur = uop1 - uop2;
			r[regnum1] = ur;
			vflag = diff_overflow(uop1,uop2,ur);
			manage_flags=true;
			break;
		case 0b1110101://sub3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop,false);
			uop1=r[regnum2];
			uop2=constop;
			fullr = ((doubleword) uop1) - ((doubleword) uop2);
			ur = uop1 - uop2;
			r[regnum1] = ur;
			vflag = diff_overflow(uop1,uop2,ur);
			manage_flags=true;
			break;
			
		case 0b1110110://and3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop1 = r[regnum2];
			uop2 = r[regnum3];
			ur = uop1&uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;

		case 0b1110111://and3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop,false);
			uop1 = r[regnum2];
			uop2 = constop;
			ur = uop1&uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;
			
			
		}
		break;
	case 0xf:
		//read 3 more bits
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		switch(opcode){
		case 0b1111000://or3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop1 = r[regnum2];
			uop2 = r[regnum3];
			ur = uop1|uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;

		case 0b1111001://or3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop,false);
			uop1 = r[regnum2];
			uop2 = constop;
			ur = uop1|uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;
			
		case 0b1111010://xor3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop1 = r[regnum2];
			uop2 = r[regnum3];
			ur = uop1^uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;

		case 0b1111011://xor3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop,false);
			uop1 = r[regnum2];
			uop2 = constop;
			ur = uop1^uop2;
			r[regnum1] = ur;
			vflag = false;
			manage_flags=true;
			break;

		case 0b1111100://asr3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_shiftval_from_pc(shiftval);
			uop1=r[regnum2];
			
			ur = (uword)(((sword)uop1) >> shiftval);
			r[regnum1] = ur;
						
			cflag = ( ((uop1 >> (shiftval-1))&1) == 1);
			zflag = (ur==0);
			nflag = (0 > (sword) ur);
			vflag = false;
			manage_flags=false;
			break;
		}

		break;

		
	}
	// flag management
	if(manage_flags) {
		zflag = (ur==0);
		cflag = (fullr > ((doubleword) 1)<<WORDSIZE);
		nflag = (0 > (sword) ur);
	}

	if (debug) {
	  int ws = WORDSIZE/4;
	  cout << "after instr: " << opname(opcode) 
	       << " at pc=" << hex << setw(ws) << setfill('0') << instr_pc
	       << " (newpc=" << hex << setw(ws) << setfill('0') << pc << ")" <<  endl;
	  cout << " zncv = " << (zflag?1:0) << (nflag?1:0) << (cflag?1:0) << (vflag?1:0) << endl;
	  cout << " pc=" << hex << setw(ws) << setfill('0') << m->counter[0] 
				 << " sp=" << hex << setw(ws) << setfill('0') << m->counter[1] 
				 << " a0=" << hex << setw(ws) << setfill('0') << m->counter[2] 
	       << " a1=" << hex << setw(ws) << setfill('0') << m->counter[3] << endl ;
			//				 << " newpc=" << hex << setw(9) << setfill('0') << pc;
	  
		for (int i=0; i<4; i++)
			cout << " r"<< dec << i << "=" << hex << setw(ws) << setfill('0') << r[i];
		cout << endl;
		for (int i=4;i<8;i++)
			cout << " r"<< dec << i << "=" << hex << setw(ws) << setfill('0') << r[i];
		cout << endl;
	}
	if((int)pc==instr_pc){
		if(opcode==0xa){//boucle infinie terminale
			cerr << "end detected\n";
			return -1;
		} else if(opcode==0b1110001){//return invalide
			cout << "r7 may be erased at " << pc << endl;
			return -1;
		}
	}
	opctr[opflat(opcode)]++;
	instr_bits_ctr+=opsize(opcode);
	return opcode;
}


// form now on, helper methods. Read and understand...

void Processor::read_bit_from_pc(int& var) {
	var = (var << 1) +read_bit_proc(PC,0); // the read_bit updates the memory's PC
	pc++;                             // this updates the processor's PC
	
}

void Processor::read_reg_from_pc(int& var) {
	var=0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


//unsigned
void Processor::read_const_from_pc(uint64_t& var,bool sex) {
	var=0;
	int header=0;
	int size;
	read_bit_from_pc(header);
	if(header==0)
		size=1;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=8;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + read_bit_proc(PC,0);
		pc++;
	}
	if(sex){
		if((var >> (size-1)) & 1)
		{
			for (int i=size; i<WORDSIZE; i++)
			{
				var += ((uword) 1 << i);
			}
		}
	}
}


// Beware, this one is sign-extended
void Processor::read_addr_from_pc(uword& var) {
	var=0;
	int header=0;
	int size;
	var=0;
	read_bit_from_pc(header);
	if(header==0)
		size=8;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=16;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}
	// cerr << "before signext " << var << endl;
	// sign extension
	int sign=(var >> (size-1)) & 1;
	if(sign)
		var -= (1<<size);
	// cerr << "after signext " << var << " " << (int)var << endl;

}




void Processor::read_shiftval_from_pc(int& var) {
	// begin sabote
	var=0;
	read_bit_from_pc(var);
	if(!var){
		for(int i=0;i<6;read_bit_from_pc(var),i++){}
	}	
	//end sabote
}

void Processor::read_cond_from_pc(int& var) {
	var =0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


bool Processor::cond_true(int cond) {
	switch(cond) {
	case 0 :
		return (zflag);
		break;
	case 1 :
		return (! zflag);
		break;
		// begin sabote
	case 2 :
		return (nflag == vflag)&&(!zflag);
	case 3 :
		return nflag!=vflag;
	case 4 :
		return !(zflag||cflag);
	case 5 :
		return !cflag;
	case 6 :
		return cflag;
	case 7 :
		return vflag;
		
// end sabote
		
	}
	throw "Unexpected condition code";
}


void Processor::read_counter_from_pc(int& var) {
	// begin sabote
	var=0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	// end sabote
}


void Processor::read_size_from_pc(int& size) {
	// begin sabote
	int ss=0;//la taille de size
	size=0;
	read_bit_from_pc(ss);
	read_bit_from_pc(ss);
	if(ss>>1)
		read_bit_from_pc(ss);
	size = sizeval(ss);
	// end sabote
}


void Processor::incr_count(int counter){
	switch(counter){
	case 0:pc++;break;
	case 1:sp++;break;
	case 2:a1++;break;
	case 3:a2++;break;
	}
	
}

void Processor::set_count(int counter,uword offset){
	switch(counter){
	case 0:pc=offset;break;
	case 1:sp=offset;break;
	case 2:a1=offset;break;
	case 3:a2=offset;break;
	}
}

int Processor::read_bit_proc(int ctr,int type)
{
	int i(m->read_bit(ctr));
	rbitsspc[type]++;
	return i;
}

void Processor::write_bit_proc(int ctr, int bit, int type)
{
	m->write_bit(ctr,bit);
	wbitsspc[type]++;
	return;
}

void Processor::resetctrs()
{
	settoz(opctr,39);
	settoz(rbitsspc,RCAT);
	settoz(wbitsspc,WCAT);
	instr_bits_ctr = 0;
	return;
}

void Processor::printctrs()
{
	cout << "stats :\n\n";
	cout << "operations :\n\n";
	printstats(t,opctr,40);
	cout << "memory interaction :\n\nread :\n\n";
	printstats(rcat,rbitsspc,RCAT);
	cout << "write :\n\n";
	printstats(wcat,wbitsspc,WCAT);
				       
}
		

int sizeval(int size){
	switch(size){
	case 0b00:return 1;
	case 0b01:return 4;
	case 0b100:return 8;
	case 0b101:return 16;
	case 0b110:return 32;
	case 0b111:return 64;
	}
	return 0;
}

bool sum_overflow(uword uop1, uword uop2, uword ur)
{
	return ((uop1>>(WORDSIZE-1))==(uop2>>(WORDSIZE-1)))&&((ur>>(WORDSIZE-1))!=(uop1>>(WORDSIZE-1)));
}

bool diff_overflow(uword uop1, uword uop2, uword ur)
{
	return sum_overflow(ur,uop2,uop1);
}
/*
char t0[12][7] = {"add2","add2i","sub2","sub2i","cmp","cmpi","let","leti","shift","tsnh","jump","jumpif"};
char t9[2][7] = {"readze","readse"};
char t6[8][7] = {"or2","or2i","and2","and2i","write","call","setctr","getctr"};
char t7[16][7] = {"push","return","add3","add3i","sub3","sub3i","and3","and3i","or3","or3i","xor3","xor3i","asr3","?","?","?"};
*/

int opflat(const int opcode)
{
	switch(opcode>>4){
	case 0: return opcode;//t0[opcode];
	case 1: return (opcode&1)+12;//t9[opcode&1];
	case 3: return (opcode&7)+14;//t6[opcode&7];
	case 7: return (opcode&15)+22;//t7[opcode&15];
	}
	return -1;
}

int opsize(const int opcode)
{
	switch(opcode>>4){
	case 0:return 4;
	case 1:return 5;
	case 3:return 7;
	case 7:return 11;
	}
	return 0;
}

char* opname(const int opcode)
{
	return t[opflat(opcode)];
}

int idwru(int addr)
{
	if(MEM_SCREEN_BEGIN <= addr
	   && addr < MEM_SCREEN_END)
		return 1;
	return 0;
		       
}

int idrru(int addr)
{
	if(MEM_SCREEN_BEGIN <= addr
	   && addr < MEM_SCREEN_END)
		return 2;
	else if(MEM_KBD_BEGIN <= addr
		&& addr < MEM_KBD_END)
		return 3;
	else if(MEM_CLOCK_BEGIN <= addr
		&& addr < MEM_CLOCK_END)
		return 4;
	else
		return 1;
}

unsigned int sum(unsigned int *tb, int size)
{
	unsigned int s(0);
	for(int i(0);i<size;s+=tb[i++]){}
	return s;
}


void printstats(char champ[][7], unsigned int *vals, int size)
{
	unsigned int s(0);
	for(int i(0);i<size;s+=vals[i++]){}
	cout << "total : " << s << endl;
	for(int i(0);i<size;i++)
		if(vals[i])
			cout << "\t" << champ[i] << "\t" << vals[i]
			     << "\t" << vals[i]*100./s << "%\n";
	cout << endl;
	return;
}
