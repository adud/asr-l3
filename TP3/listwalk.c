#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <string.h>
#include <assert.h>

void swap(int64_t *tb,int i,int j){
  int64_t tmp=tb[i];
  tb[i] = tb[j];
  tb[j] = tmp;
  return;
}
 
double benchmark(int64_t N, int64_t R)
{
	//init tablal
	int64_t *tabl = malloc(sizeof(int64_t)*N);
	assert(tabl!=0);
	
	for(int i=0;i<N;i++){
	    tabl[i]=i;
	}
	//melange
	srand(time(NULL));
	
	int k=0;
	for(int i=1;i<N;i++){
	    k = rand()%i;
	    swap(tabl,i,k);
	}
	
	//for(int i=0;i<N;i++){printf("%ld\n",tabl[i]);}
	
	//printf("now the game begins\n");
	
	int64_t pt=0;
	
	int64_t deb=clock();
	
	for(int i=0;i<R;i++){
	    do{
		pt = tabl[pt];
		//printf("%ld\n",pt);
	    }
	    while(pt!=0);
	}
	int64_t fin=clock();
	
	//printf("%ld %lf\n",sizeof(tabl)*N,1e9*(double)(fin-deb)/(double)(CLOCKS_PER_SEC*N*R));

	free(tabl);
	
	return 1e9*(double)(fin-deb)/(double)(CLOCKS_PER_SEC*N*R);
}

int main(){
	for(int64_t N 
}
