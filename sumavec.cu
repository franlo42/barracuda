#include <stdio.h>

#define N 10

__global__ void add(int *a, int *b, int *c)
{
  int tid= threadIdx.x + blockIdx.x * blockDim.x;//El num del hilo global entre TODOS los hilos que hay
  while(tid < N){
    c[tid]=a[tid] + b[tid];
    tid+= gridDim.x * blockDim.x;//Sumas el num TOTAL de hilos pa pasar al siguiente que te tocaría
  }
}

int main(){
  int a[N], b[N], c[N], i;
  int *gpu_a, *gpu_b, *gpu_c;//Los arrays en GPU

  cudaMalloc((void **) &gpu_a, N*sizeof(int));
  cudaMalloc((void **) &gpu_b, N*sizeof(int));//Reservar memoria en GPU para los vectores
  cudaMalloc((void **) &gpu_c, N*sizeof(int));

  for(i=0;i<N;i++){
    a[i] = -i;
    b[i] = i*i;
  }

  cudaMemcpy(gpu_a, a, N*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_b, b, N*sizeof(int), cudaMemcpyHostToDevice);//Enviar los vectores a GPU
  cudaMemcpy(gpu_c, c, N*sizeof(int), cudaMemcpyHostToDevice);

  add<<<2,5>>>(gpu_a,gpu_b,gpu_c);//Llamar al kernel y ejecutar en GPU

  cudaMemcpy(c, gpu_c, N*sizeof(int), cudaMemcpyDeviceToHost);//Copiar resultado a CPU

  for(i=0;i<N;i++){
    printf("%d + %d = %d\n", a[i], b[i], c[i]);
  }

  cudaFree(gpu_a);
  cudaFree(gpu_b);//Liberar la memoria en GPU
  cudaFree(gpu_c);
}