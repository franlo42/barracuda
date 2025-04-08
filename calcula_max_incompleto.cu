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

__global__ void max_gpu_v1(int *A, int *sal){//1 bloque por columna
  
  int tid,temp;
  tid = threadIdx.x + blockIdx.x * blockDim.x;
  temp = A[tid];

  for(int i=1;i<N-1;i++){
    if(A[tid + blockIdx.x *i] > temp){
      temp=A[tid + blockIdx.x *i];
    }
  }
  sal[blockIdx.x]=temp;
}

__global__ void max_gpu_v2(int *A, int *sal){

}
 
int main() {

  int i,j;
 
 
  int *A = (int *) malloc( N*N*sizeof(int) );
  int salcpu;


  //rellenar matriz de enteros en CPU
  for (i=0;i<N;i++)
    for(j=0;j<N;j++){
      A[i+N*j]=rand()% 1000;
    }
  Print_matrix(A);
  calcula_max(A,&salcpu);
  printf("\nEl maximo calculado en cpu es %d ",salcpu);




//Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
// y lo que sea necesario

//Comienzo parte GPU

  int *sal= (int *)malloc(N*sizeof(int) ); //variable para copiar resultado parcial de gpu a cpu
  int *sal2= (int *)malloc(N*sizeof(int) ); //variable para copiar resultado parcial de gpu a cpu
//variables para gpu
  int *dev_A;
  int *dev_sal;
  int *dev_sal2;

  //Rservar espacio en GPU para vectores que usaremos
  cudaMalloc((void **) &dev_A, N*N*sizeof(int));
  cudaMalloc((void **) &dev_sal, N*sizeof(int));
  
  cudaMalloc((void **) &dev_sal2, N*sizeof(int));
  
  //Llevar a GPU la matriz A ya llena
  cudaMemcpy( dev_A, A, N*N*sizeof(int), cudaMemcpyHostToDevice);

  //llamada kernel v1
  max_gpu_v1<<<N,1>>>(dev_A, dev_sal);

  //Traer de gpu el resultado
  cudaMemcpy( sal, dev_sal, N*sizeof(int), cudaMemcpyDeviceToHost);


  int sol=sal[0];
  for(int i=1;i<N-1;i++){
    if(sal[i]>sol){
      sol=sal[i];
    }
  }
  printf("\nEl maximo calculado en gpuV1 es %d ",sol);

  free(A);
  free(sal);
 
  cudaFree(dev_A);
  cudaFree(dev_sal);
}
	
	
