#include <iostream>
#include <fstream>
#include <vector>
#include <cstdio>
#include <algorithm>
#include <ctime>

#include <SDL2/SDL.h>
#include <stdint.h>
#include <thread>
#include <signal.h>

#include "screen.h"
#include "memory.h"
#include "processor.h"


bool force_quit = false;
bool refresh = true;
int verbose=1; 


// Option parsing stuff from Stack Overflow
// use like this:    char * filename = getCmdOption(argv, argv + argc, "-f");

char* getCmdOption(char ** begin, char ** end, const std::string & option) {
    char ** itr = std::find(begin, end, option);
    if (itr != end && ++itr != end)    {
        return *itr;
    }
    return 0;
}

bool cmdOptionExists(char** begin, char** end, const std::string& option) {
    return std::find(begin, end, option) != end;
}

void usage() {
		std::cerr << "Usage: simu [options] file.obj \n options : -d for debug, -s for step by step, -g for graphical screen, -m <file> to include a memory file, --stats for running stats" << std::endl;
		exit(0);
}

uint64_t rule30(const uint64_t q)
{
	const uint64_t p = (q>>1) + ((q&1)<<63);
	const uint64_t r = (q<<1) + (q>>63);
	return p^(q|r);
}

uint64_t randgen(const uint64_t q)
{
	return (q*43%((1<<19) - 1))+1;
}

int main(int argc, char* argv[]) {
	std::cerr << "emulator for ==" << WORDSIZE << "== architecture\n";  
	if(argc==1) {
		usage();
	}
	bool debug = cmdOptionExists(argv, argv+argc, "-d");
	bool step_by_step = cmdOptionExists(argv, argv+argc, "-s");
	bool graphical_output = cmdOptionExists(argv, argv+argc, "-g");
 
	std::string filename = argv[argc-1];
	/*std::ifstream f(filename.c_str());
	if(!f.good()) {
		std::cerr << "can't access obj file" << std::endl;
		usage();
		}*/
	
	Memory* m;
	Processor* p;
	std::thread* screen(NULL);
		
	m= new Memory();
	p = new Processor(m);

	if(m->fill_with_obj_file(filename)){
		std::cerr << "can't access obj file" << std::endl;
		usage();
	}
	
	/*load more files in memory
	  if file.obj is executed, and there is a file file.mem in the 
	  same directory within each line is <hex address> <filename>\n
	  then, before the program starts, for each line of file.mem
	  the content of <filename> will be stored in memory in 
	  <hex address>
	*/

	if(cmdOptionExists(argv,argv+argc, "-m")){
		//change filename extension
		std::string memname = getCmdOption(argv,argv+argc, "-m");
		int tranche = 1+memname.find_last_of("/");
		std::string chemin = memname.substr(0,tranche);
		std::string nomf;
		uword pos;
		//std::cout << chemin;
		//thx sof
		
		std::ifstream a2mf(memname.c_str());
		if(a2mf){
			while(a2mf >> std::hex >> pos >> nomf)
			{ 
				std::cerr << nomf << " in 0x" << std::hex
					  << pos << " : ";
				if(m->fill_with_obj_file(chemin+nomf,pos))
					exit(1);
			}
			a2mf.close();
		} else 
			std::cerr << "can't access memory file" << std::endl;
	}
	

	// create the screen
	if(graphical_output)
		screen=new std::thread(simulate_screen, m, &refresh);

	
	char sin;//for step-by-step
	int lastopc(0);
	bool ppl(true);
	int prof(0);//for step-by-step


	clock_t beg(clock());
	clock_t act(beg);

	m->m[MEM_RGEN_BEGIN/64]=beg;
		
	uword time_ms(0);
	// The von Neuman cycle	
	while(1+1==2) {
		act = clock();
		time_ms = (uword) (((float)(act-beg))/
			       (CLOCKS_PER_SEC/1000.));
		//std::cout << time_ms << std::endl;
		for(int i=63;i>=0;i--){
			m->write_bit_raw(MEM_CLOCK_BEGIN+63-i,1&time_ms>>i);
		}

		m->m[MEM_RGEN_BEGIN/64]=randgen(m->m[MEM_RGEN_BEGIN/64]);
		
		lastopc = p->von_Neuman_step(debug&&ppl);
		if(lastopc==-1)
			break;
		if(step_by_step){
			if(ppl){
				sin=getchar();
				if(sin!='\n')
					getchar();
				if(sin=='n')//call
				{
					ppl=false;
					prof=1;
				}
			}
			else{
				switch(lastopc){
				case 0x35:prof++;break; //call
				case 0x71:prof--;break; //return
				}
				ppl=(prof==0);
			}
			
		}
	};

	if(cmdOptionExists(argv,argv+argc,"--stats"))
		p->printctrs();

	if(graphical_output)
		screen->join();

	return 0;
}
