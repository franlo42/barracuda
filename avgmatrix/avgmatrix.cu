#include <stdio.h>

#define M 3
#define N 4

__global__ void mediasmatrizcpu(double *A,  double *sal)
{
  int i,tid;//M=Filas;N=Columnas
  tid= threadIdx.x + blockIdx.x * blockDim.x;
  double suma;
  suma=0;
  for(i=0;i<M;i++){
    suma=suma+A[tid*M+i];
  }
  sal[tid]=suma/double(M);
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
  double *gpu_A, *gpu_sal;

  double *A = (double *) malloc( N*M*sizeof(double) );
  double *sal1 = (double *) malloc( N*sizeof(double) );
 
  cudaMalloc((void **) &gpu_A, N*M*sizeof(double));
  cudaMalloc((void **) &gpu_sal, N*sizeof(double));

  //rellenar matriz en CPU
  for (j=0;j<N;j++){
    for(i=0;i<M;i++)
    {
      A[i+M*j]=i+j ;
     }
  }

  Print_matrix(A,M,N);

  cudaMemcpy(gpu_A, A, N*M*sizeof(double), cudaMemcpyHostToDevice);
  cudaMemcpy(gpu_sal, sal1, N*sizeof(double), cudaMemcpyHostToDevice);

  mediasmatrizcpu<<<1,N>>>(gpu_A,gpu_sal);

  cudaMemcpy(sal1, gpu_sal, N*sizeof(double), cudaMemcpyDeviceToHost);

  for (j=0;j<N;j++){
    printf("media columna %d = %f  \n",j,sal1[j]);
  }

  free(A);
  free(sal1);

  cudaFree(gpu_A);
  cudaFree(gpu_sal);

}
