#include <stdio.h>

#define M 8
#define N 12

dim3 thr_p_block((M-2),(N-2));

__global__ void filter(double *A,  double *Out)
{
  int tidx, tidy;
  tidx=threadIdx.x + blockIdx.x * blockDim.x;
  tidy=threadIdx.y + blockIdx.y * blockDim.y;
  Out[tidx+tidy*(M-2)]=( A[tidx-1+tidy*M] + A[tidx+1+tidy*M] + A[tidx+(tidx-1)*M] + A[tidx+(tidy+1)*M] + A[tidx+tidy*M] ) / 5.0;
 }

void Print_matrix(double C[], int m, int n) {
   int i, j;

   for (i = 0; i < m; i++) {
      for (j = 0; j < n; j++)
         printf("%.2e ", C[i+j*m]);
      printf("\n");
   }
}  /* Print_matrix */

int main() {
  int i,j;
  double *gpu_A, *gpu_Out;

  double *A = (double *) malloc( M*N*sizeof(double) );
  double *Out = (double *) malloc( (M-2)*(N-2)*sizeof(double) );
 
  cudaMalloc((void **) &gpu_A, N*M*sizeof(double));
  cudaMalloc((void **) &gpu_Out, (M-2)*(N-2)*sizeof(double));

  //rellenar matriz en CPU
  for (j=0;j<N;j++){
    for(i=0;i<M;i++)
    {
      A[i+M*j]=i+j ;
     }
  }

  Print_matrix(A,M,N);

  cudaMemcpy(gpu_A, A, N*M*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_Out, Out, (M-2)*(N-2)*sizeof(double), cudaMemcpyHostToDevice);

  filter<<<1,thr_p_block>>>(gpu_A,gpu_Out);

  cudaMemcpy(Out, gpu_Out, (M-2)*(N-2)*sizeof(double), cudaMemcpyDeviceToHost);
  
  printf("\n");
  Print_matrix(Out,M-2,N-2);

  free(A);
  free(Out);

  cudaFree(gpu_A);
  cudaFree(gpu_Out);

  }
