#include <stdio.h>

#define N 8
#define BLOCKSIZE 4


void Print_matrix(int C[]) {
   int i, j;

   for (i = 0; i < N; i++) {
      for (j = 0; j < N; j++)
         printf("%d ", C[i+j*N]);
      printf("\n");
   }
}  /* Print_matrix */


void calcula_max(int *A, int *sal)
{  int i,j,maximo;
    maximo=A[0];
    for (i=0;i<N;i++)
       for(j=0;j<N;j++)
            if ((A[i+j*N]>maximo))
              maximo=A[i+j*N];


 *sal=maximo;
}

 
 int main() {

 int i,j;
 
 
  int *A = (int *) malloc( N*N*sizeof(int) );
  int salcpu;


 //rellenar matriz de enteros en CPU
  for (i=0;i<N;i++)
    for(j=0;j<N;j++)
   {
      A[i+N*j]=rand()% 1000;
     
    }
Print_matrix(A);
calcula_max(A,&salcpu);
printf(" \n El maximo calculado en cpu es %d ",salcpu);




//Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
// y lo que sea necesario

//Comienzo parte GPU

  int *sal= (int *)malloc(N*sizeof(int) ); //variable para copiar resultado parcial de gpu a cpu
//variables para gpu
  int *dev_A;
  int *dev_sal;
  

  free(A);
free(sal);
 
  }
	
	
