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

const int MEM_SCREEN_BEGIN = 0x10000;// -> 0x60000
const int MEM_SCREEN_END = 0x60000;
//de la place pour un aff ascii 0x60000 -> 0x62000
const int MEM_KBD_BEGIN = 0x62000;
const int MEM_KBD_END = 0x62080;
//la reception du clavier 0x62000 -> 0x62080
const int MEM_CLOCK_BEGIN = 0x62080;
const int MEM_CLOCK_END = 0x620c0;
//l'horloge : 0x62080 -> 0x620c0
//et on serre les dents pour la compatibilite
//ca passe de justesse

const int MEM_RGEN_BEGIN = 0x620c0;
const int MEM_RGEN_END = 0x62100;
//le generateur pseudo-aleatoire (Wolfram garanti non-lineaire rule 30)

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
