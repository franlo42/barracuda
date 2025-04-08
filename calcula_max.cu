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

  for(int i=0;i<N-1;i++){
    if(A[tid*N+i+1] > temp){
      temp=A[tid*N+i+1];
    }
  }
  sal[blockIdx.x]=temp;
}

__global__ void max_gpu_v2(int *A, int *sal){//Varios threads de cada bloque colaboran
  
  __shared__ int cache[BLOCKSIZE];
  int tid, cacheIndex, temp;
  tid = threadIdx.x;
  cacheIndex = threadIdx.x;
  temp = A[tid+blockIdx.x*N];

  //Calculo parcial de ceda HILO
  while(tid<N){
    if(A[tid+blockIdx.x*N] > temp){
      temp=A[tid+blockIdx.x*N];
    }
    tid+=blockDim.x;
  }
  cache[cacheIndex]=temp;
  
  __syncthreads();//Sincronizar hilos=Asegurar que la cache esta llena para calcularel resultado parcial del BLOQUE

  //Calculo distribuido de todo el bloque
  int i= blockDim.x / 2;
  while(i!=0){
    if(cacheIndex<i){
      if(cache[cacheIndex]<cache[cacheIndex+i]){
        cache[cacheIndex]=cache[cacheIndex+i];
      }
    }
    __syncthreads();//Sincronizacion final para obtener el resultado parcial del BLOQUE en cache[0]
    i=i/2;//REDUCCION
  }

  if(threadIdx.x == 0){//Meter resultado parcial del bloque en vector de resultados parciales de todos los bloques
    sal[blockIdx.x]=cache[0];
  }
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
  printf("\nEl maximo calculado en cpu es %d\n",salcpu);




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
  //llamada kernel v2
  max_gpu_v2<<<N,BLOCKSIZE>>>(dev_A, dev_sal2);

  //Traer de gpu el resultado
  cudaMemcpy( sal, dev_sal, N*sizeof(int), cudaMemcpyDeviceToHost);

  cudaMemcpy( sal2, dev_sal2, N*sizeof(int), cudaMemcpyDeviceToHost);  


  int sol=sal[0];
  for(int i=1;i<N;i++){
    if(sal[i]>sol){
      sol=sal[i];
    }
  }
  printf("\nEl maximo calculado en gpuV1 es %d\n",sol);

  int sol2=sal2[0];
  for(int i=1;i<N;i++){
    if(sal2[i]>sol2){
      sol2=sal2[i];
    }
  }
  printf("\nEl maximo calculado en gpuV2 es %d\n",sol2);

  free(A);
  free(sal);
 
  cudaFree(dev_A);
  cudaFree(dev_sal);
  cudaFree(dev_sal2);
}

	
	
