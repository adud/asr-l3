#ifndef H_SCREEN
#define H_SCREEN

//constants about the environnement
const int WIDTH = 160;
const int HEIGHT = 128;
const int MEM_SCREEN_BEGIN = 0x10000;// -> 0x60000
//de la place pour un aff ascii 0x60000 -> 0x62000
const int MEM_KBD_BEGIN = 0x10000; 

#include <SDL2/SDL.h>
#include <stdio.h>
#include "memory.h"

/* this is the function that runs in the screen thread
 * m -> the simulator's memory
 * force_quit -> shared variable to detect if we must close the screen
 * refresh -> shared variable that instructs the thread to refresh the screen
 */
void simulate_screen(Memory* m, bool *refresh);

#endif
