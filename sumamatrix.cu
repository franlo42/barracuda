#include <stdio.h>

#define M 8
#define N 12

dim3 block_p_grd(2,3);
dim3 thr_p_block(4,4); 

__global__ void add(int *a, int *b, int *c)
{
  int tidx= threadIdx.x + blockIdx.x * blockDim.x;
  int tidy= threadIdx.y + blockIdx.y * blockDim.y;
  
  c[tidx+tidy*8]=a[tidx+tidy*8] + b[tidx+tidy*8];
}

int main(){
  int a[M][N], b[M][N], c[M][N], i, j;
  int *gpu_a, *gpu_b, *gpu_c;//Los arrays en GPU

  cudaMalloc((void **) &gpu_a, M*N*sizeof(int));
  cudaMalloc((void **) &gpu_b, M*N*sizeof(int));//Reservar memoria en GPU para los vectores
  cudaMalloc((void **) &gpu_c, M*N*sizeof(int));

  for(i=0;i<M;i++){
    for(j=0;j<N;j++){
      a[i][j] = i*10+j;
      b[i][j] = j*i;
    }
  }

  cudaMemcpy(gpu_a, a, M*N*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_b, b, M*N*sizeof(int), cudaMemcpyHostToDevice);//Enviar los vectores a GPU
  cudaMemcpy(gpu_c, c, M*N*sizeof(int), cudaMemcpyHostToDevice);

  add<<<block_p_grd,thr_p_block>>>(gpu_a,gpu_b,gpu_c);//Llamar al kernel y ejecutar en GPU

  cudaMemcpy(c, gpu_c, M*N*sizeof(int), cudaMemcpyDeviceToHost);//Copiar resultado a CPU

  for(i=0;i<M;i++){
    for(j=0;j<N;j++){
      printf("%d + %d = %d\n", a[i][j], b[i][j], c[i][j]);
    }
  }

  cudaFree(gpu_a);
  cudaFree(gpu_b);//Liberar la memoria en GPU
  cudaFree(gpu_c);
}
