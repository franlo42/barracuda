
#include <stdio.h>
#define N 12
#define BLOCKSIZE 4


void Print_matrix(int C[], int n) {
   int i, j;

   for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++)
         printf("%d ", C[i+j*n]);
      printf("\n");
   }
}  /* Print_matrix */


void comprobar_cpu(int *A, int *sal)
{  int i,j,res=1;
    for (j=0;j<N-1;j++)
       for(i=0;i<N-1;i++)
            if (A[i+j*N]!=A[i+1+(j+1)*N])
              res=0;

    
 *sal=res;
}



 int main() {

 int i,j; 
 int *A = (int *) malloc( N*N*sizeof(int) );
int *sal = (int *) malloc( N*sizeof(int) );
 int salcpu;

 //rellenar matriz de numeros en CPU
  for (j=0;j<N;j++)
    for(i=0;i<N;i++)
   {
      A[i+N*j]=j-i;
     
    }
//A[3+N*4]=77;
Print_matrix(A,N);
comprobar_cpu(A,&salcpu);
if (salcpu==1)
printf(" \n La matriz es toeplitz \n");
else
 printf(" \n La matriz no es toeplitz \n");



//Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
// y lo que sea necesario

//Comienzo parte GPU
int *dev_A, *dev_sal;
  }
	
	
