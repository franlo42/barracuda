#include <stdio.h>
#define N 12
//#define BLOCKSIZE 4


void Print_matrix(int C[], int n) {
   int i, j;

   for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++)
         printf("%d ", C[i+j*n]);//SE GUARDA POR COLUMNAS
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

__global__ void comprobar_gpu(int *A, int *sal){
  int tid, temp;
  tid = blockIdx.x * N;
  temp = 1;

  for(int i=0;i<N-1;i++){
    if(tid<(N-1)*N){
      if(A[tid + i] != A[tid+i+1+N]){
        temp=0;
      }
    }
  }
  sal[blockIdx.x]=temp;
}

int main() {

  int i,j; 
  int *A = (int *) malloc( N*N*sizeof(int) );
  int *sal = (int *) malloc( N*sizeof(int) );
  int salcpu;

  //rellenar matriz de numeros en CPU
  for (j=0;j<N;j++)
    for(i=0;i<N;i++){
      A[i+N*j]=j-i;
    }

  A[3+N*4]=77;
  Print_matrix(A,N);
  comprobar_cpu(A,&salcpu);
  if (salcpu==1)
    printf("\n Segun CPU, la matriz SI es toeplitz \n");
  else
    printf("\n Segun CPU, la matriz NO es toeplitz \n");


  //Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
  // y lo que sea necesario
  //Comienzo parte GPU
  int *dev_A, *dev_sal;

  //Rservar espacio en GPU para vectores que usaremos
  cudaMalloc((void **) &dev_A, N*N*sizeof(int));
  cudaMalloc((void **) &dev_sal, N*sizeof(int));

  //Llevar a GPU la matriz A ya llena
  cudaMemcpy( dev_A, A, N*N*sizeof(int), cudaMemcpyHostToDevice);

  //llamada kernel
  comprobar_gpu<<<N,1>>>(dev_A, dev_sal);
  
  //Traer de gpu el resultado
  cudaMemcpy( sal, dev_sal, N*sizeof(int), cudaMemcpyDeviceToHost);

  //Bucle de obtencion de resultado final en CPU
  int sol=1;
  for(int i=1;i<N;i++){
    if(sal[i]<sol){
      sol=0;
    }
  }
  if (sol==1)
    printf("\n Segun GPU, la matriz SI es toeplitz \n");
  else
    printf("\n Segun GPU, la matriz NO es toeplitz \n");


  free(A);
  free(sal);
   
  cudaFree(dev_A);
  cudaFree(dev_sal);    
}
