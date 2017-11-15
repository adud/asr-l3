#include <iostream>
#include <fstream>
#include <vector>
#include <cstdio>
#include <algorithm>

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
		std::cerr << "Usage: simu [options] file.obj \n options : -d for debug, -s for step by step, -g for graphical screen, -m <file> to include a memory file" << std::endl;
		exit(0);
}


int main(int argc, char* argv[]) {
	
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
	std::thread* screen;
		
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
	// The von Neuman cycle
	while(1+1==2) {
		lastopc = p->von_Neuman_step(debug&&ppl);
		if(lastopc==-1)
			break;
		if(step_by_step){
			if(ppl){
				
				sin=getchar();
				if(sin!='\n')
					getchar();
				if(lastopc==0x35&&sin=='n')//call
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

	if(graphical_output)
		screen->join();

	return 0;
}
