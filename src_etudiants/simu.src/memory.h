#ifndef memory_hpp
#define memory_hpp
#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include <string>
#include <list>
#include <cstdlib>
#include <stdint.h>
#include <stdio.h>

#include "types.h"

//decrit la position d'objets dans la memoire

const uint32_t MEM_SCREEN_BEGIN = INOUT;// size : 0x50000
const uint32_t MEM_SCREEN_END = MEM_SCREEN_BEGIN + 0x50000;
//de la place pour un aff ascii : size : 0x2000
const uint32_t MEM_KBD_BEGIN = MEM_SCREEN_END + 0x2000;
const uint32_t MEM_KBD_END = MEM_KBD_BEGIN + 0x80;
//la reception du clavier : size : 0x80
const uint32_t MEM_CLOCK_BEGIN = MEM_KBD_END;
const uint32_t MEM_CLOCK_END = MEM_CLOCK_BEGIN + 0x40;
//l'horloge : size : 0x40
//et on serre les dents pour la compatibilite
//ca passe de justesse

const uint32_t MEM_RGEN_BEGIN = MEM_CLOCK_END;
const uint32_t MEM_RGEN_END = MEM_RGEN_BEGIN + 0x40;
//le generateur pseudo-aleatoire (Wolfram garanti non-lineaire rule 30)
//size : 0x40

const uint64_t MEMSIZE=1<<24; // please keep this a multiple of 64
const int PC=0;
const int SP=1;
const int A0=2;
const int A1=3;
const uword spinit(0x10000);

class Memory {
 public:

	/** ctr should be one of PC, SP, A0, A1 */
	int read_bit(int ctr);

	/** ctr should be one of PC, SP, A0, A1 */
	void write_bit(int ctr, int bit);
	void write_bit_raw(uint64_t addr,int bit);

	/** ctr should be one of PC, SP, A0, A1 */
	void set_counter(int ctr, uword val);

	/** method called to initialize the memory 
	 0 : all right; 1: can't open file*/
	int fill_with_obj_file(std::string filename,uint64_t pos=0);

	Memory();
	~Memory();
	
	// should be private but I am too lazy
	int counter[4]; 
	uint64_t m[MEMSIZE/64];

};


#endif
