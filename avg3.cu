#include <stdio.h>

#define N 10

__global__ void avg3(int *a, int *b)
{
  int tid= threadIdx.x + blockIdx.x * blockDim.x;//El num del hilo global entre TODOS los hilos que hay
  while(tid < (N-2)){
    b[tid]= (a[tid] + a[tid+1] + a[tid+2])/3;
    tid+= gridDim.x * blockDim.x;//Sumas el num TOTAL de hilos pa pasar al siguiente que te tocaría
  }
}

int main(){
  int a[N], b[N],i;
  int *gpu_a, *gpu_b;//Los arrays en GPU

  cudaMalloc((void **) &gpu_a, N*sizeof(int));
  cudaMalloc((void **) &gpu_b, N*sizeof(int));//Reservar memoria en GPU para los vectores

  for(i=0;i<N;i++){
    a[i] = i;
  }

  cudaMemcpy(gpu_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_b, b, N*sizeof(int), cudaMemcpyHostToDevice);//Enviar los vectores a GPU

  avg3<<<N,1>>>(gpu_a,gpu_b);//Llamar al kernel y ejecutar en GPU

  cudaMemcpy(b, gpu_b, N*sizeof(int), cudaMemcpyDeviceToHost);//Copiar resultado a CPU

  printf("vector entrada=[ ");
  for(i=0;i<N;i++){
    printf("%d ", a[i]);
  }
  printf("]\n");
  printf("vector salida=[ ");
  for(i=0;i<(N-2);i++){
    printf("%d ", b[i]);
  }
  printf("]\n");

  cudaFree(gpu_a);
  cudaFree(gpu_b);//Liberar la memoria en GPU
}