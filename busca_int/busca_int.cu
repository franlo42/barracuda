#include <stdio.h>

#define N 16

#define thr_p_block 4

__global__ void contar_gpu_v1(int *A, int *sal, int num1, int num2){
  
  int tid, temp;
  tid = threadIdx.x + blockIdx.x * blockDim.x;
  temp = 0;

  for(int i=0;i<N-1;i++){
    if((A[tid*N + i]==num1)&&(A[tid*N+1 + i]==num2)){
      temp++;
    }
  }
  sal[blockIdx.x]=temp;
}


__global__ void contar_gpu_v2(int *A, int *sal, int num1, int num2){
  
  __shared__ int cache[thr_p_block];
  int tid,cacheIndex,temp;
  tid = threadIdx.x;
  cacheIndex = threadIdx.x;
  temp = 0;

  while(tid<N-1){
    if((A[tid+ blockIdx.x*N]==num1)&&(A[tid+1 + blockIdx.x*N]==num2)){
      temp++;
    }
    tid+=blockDim.x;
  }
  cache[cacheIndex]=temp;

  __syncthreads();

  //sumas distribuidas de todo el bloque
  int i= blockDim.x / 2;
  while(i!=0){
    if(cacheIndex<i){
      cache[cacheIndex]+=cache[cacheIndex+i];
    }
    __syncthreads();
    i=i/2;
  }

  if(threadIdx.x == 0){
    sal[blockIdx.x]=cache[0];
  }

}



void Print_matrix(int C[], int n) {
   int i, j;

   for (i = 0; i < n; i++) {
      for (j = 0; j < n; j++)
         printf("%d ", C[i+j*n]);
      printf("\n");
   }
}  /* Print_matrix */


void contar_int(int *A, int *sal, int num1, int num2)
{  int i,j,cant=0;
    for (j=0;j<N;j++)
       for(i=0;i<N-1;i++)
            if ((A[i+j*N]==num1)&&(A[i+1+j*N]==num2))
              cant++;

 *sal=cant;
}

 
 int main() {

 int i,j;
 
 
  int *A = (int *) malloc( N*N*sizeof(int) );
  int salcpu;


 //rellenar matriz de caracteres en CPU
  for (j=0;j<N;j++)
    for(i=0;i<N;i++)
   {
      A[i+N*j]=rand()% 10;
     
    }
Print_matrix(A,N);
contar_int(A,&salcpu,6,3);
printf(" \n En cpu se cuentan %d secuencias %d %d ",salcpu, 6,3);




//Aqui pon el código para reservar memoria, copiar matriz, llamar kernel, traer resultados,
// y lo que sea necesario

//Comienzo parte GPU

  int *sal= (int *)malloc(N*sizeof(int) ); //variable para copiar resultado de gpu a cpu

  int *sal2=(int *)malloc(N*sizeof(int));
//variables para gpu
  int *dev_A;
  int *dev_sal;
  int *dev_sal2;
  
  cudaMalloc((void **) &dev_A, N*N*sizeof(int));
  cudaMalloc((void **) &dev_sal, N*sizeof(int));
  
  cudaMalloc((void **) &dev_sal2, N*sizeof(int));

  cudaMemcpy( dev_A, A, N*N*sizeof(int), cudaMemcpyHostToDevice);

  //llamada kernel v1
  contar_gpu_v1<<<N,1>>>(dev_A, dev_sal, 6, 3);
  //llamada al kernel v2
  contar_gpu_v2<<<N,thr_p_block>>>(dev_A, dev_sal2, 6, 3);

  cudaMemcpy( sal, dev_sal, N*sizeof(int), cudaMemcpyDeviceToHost);

  cudaMemcpy(sal2, dev_sal2, N*sizeof(int), cudaMemcpyDeviceToHost);

  int sol=0;
  for(int i=0;i<N;i++){
    sol+=sal[i];
  }
  
  printf(" \n En gpu1 se cuentan %d secuencias %d %d \n",sol, 6,3);

  int sol2=0;
  for(int i=0;i<N;i++){
    sol2+=sal2[i];
  }
  printf(" \n En gp2 se cuentan %d secuencias %d %d \n",sol2, 6,3);

  free(A);
 
  cudaFree(dev_A);
  cudaFree(dev_sal);

  cudaFree(dev_sal2);
  }
