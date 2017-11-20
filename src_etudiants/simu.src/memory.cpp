#include "memory.h"

Memory::Memory():counter{0}
{
	counter[SP] = 0x10000; //par defaut pile juste avant l'ecran
}
Memory::~Memory(){}


int Memory::read_bit(int ctr){
	uint64_t word_addr = counter[ctr]>>6;
	uint64_t word = m[word_addr]; // extract the word that contains our bit
	int shift = counter[ctr] & 63; // this is a bitwise and -- could have been % 64
	int bit = (word>>shift) & 1; //shift the good bit to position 0, then mask the other bits
	counter[ctr] ++;
	return bit;
}


void Memory::write_bit(int ctr, int bit){
	if(bit!=0 && bit!=1)  {
		throw "Expecting a bit (0 or 1)";
	} 
	uint64_t word_addr = counter[ctr]>>6;
	uint64_t word = m[word_addr]; // extract the word where our bit should go
	int shift = counter[ctr] & 63; // this is a bitwise and -- could have been % 64

	uint64_t bit64 = bit;
	bit64 = bit64 << shift;
	uint64_t mask = ~(((uint64_t)1) << shift);
	word = (word & mask) + bit64;
	//std::cerr << std::hex << std::setw(16) <<  m[word_addr] << "  " << word <<std::endl; 
	m[word_addr] = word;
	counter[ctr] ++;
}

void Memory::set_counter(int ctr, uword val){
	counter[ctr]=val;
}

int Memory::fill_with_obj_file(std::string filename,uint64_t pos) {
	std::cerr << "loading... " ;
	counter[0] = pos; // this is pc
	std::fstream fin(filename, std::fstream::in);
	char c;
	if(fin){
		while (fin >> c) {
			if (c=='0') {
				//std::cerr << c;
				write_bit(0, 0);
			}
			if (c=='1'){
				//std::cerr << c;
				write_bit(0, 1);
			} 
			// all the other characters are skipped
		}
		fin.close();
		std::cerr << " done" << std::endl;
		counter[0] = 0; // this is pc
		return 0;
	} else {
		std::cerr << " error : can't open file"<< std::endl;
		return 1;
	}
}

