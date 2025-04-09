#include <stdio.h>


#define CUDA_SAFE_CALL( call ) {                                         \
 cudaError_t err = call;                                                 \
 if( cudaSuccess != err ) {                                              \
   fprintf(stderr,"CUDA: error occurred in cuda routine. Exiting...\n"); \
   exit(err);                                                            \
 } }

 
#define	BLOCKSIZE 32


__global__ void prod_esc_gpu(float *x, float *y, float *sal){

  __shared__ float cache[BLOCKSIZE];
  int tid, cacheIndex;
  tid = threadIdx.x + blockIdx.x * blockDim.x;
  cacheIndex = threadIdx.x;
  float temp=0.0;

  while(tid<1024000){
    temp+=x[tid]*y[tid];
    tid+= gridDim.x * blockDim.x;
  }
  cache[cacheIndex]=temp;

  __syncthreads();

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


float prodesc_cpu(unsigned int n, float *x, float *y)
{int j;
 float suma=0.0;
   for( j=0; j<1024000; j++ ) 
     suma+=x[j]*y[j];
  return suma;
}
        


int main( int argc, char *argv[] ) {
  unsigned int n;
  unsigned int j;

  n =1024000;

  //reserva de espacio en memoria CPU
  float *x = (float *) malloc(   n*sizeof(float) );
  float *y = (float *) malloc(   n*sizeof(float) );
  
  for( j=0; j<n; j++ ) {//bucle de llenado
    x[ j ] = 2.0f * ( (float) rand() / RAND_MAX ) - 1.0f;
    y[ j ] = 2.0f * ( (float) rand() / RAND_MAX ) - 1.0f;
  }

  cudaEvent_t start, stop;//PA medir tiempos
  CUDA_SAFE_CALL( cudaEventCreate(&start) );
  CUDA_SAFE_CALL( cudaEventCreate(&stop) );

  printf(" x*y en CPU...\n");
  CUDA_SAFE_CALL( cudaEventRecord(start, NULL) ); // Record the start event
  float res=prodesc_cpu( n, x, y );
  CUDA_SAFE_CALL( cudaEventRecord(stop, NULL) );  // Record the stop event
  CUDA_SAFE_CALL( cudaEventSynchronize(stop) );   // Wait for the stop event to complete
  float msecCPU = 0.0f;
  CUDA_SAFE_CALL( cudaEventElapsedTime(&msecCPU, start, stop) );



  printf(" x*y en GPU...\n");
  int n_blocks = n / BLOCKSIZE ;
  float *dev_x, *dev_y;
  float *dev_sal;
  float *sal= (float *)malloc(n_blocks*sizeof(float) );


 cudaMalloc((void **) &dev_x, n*sizeof(float) ) ;
 cudaMalloc((void **) &dev_y, n*sizeof(float) ) ;
 cudaMalloc((void **) &dev_sal, n_blocks*sizeof(float) ) ;

 CUDA_SAFE_CALL( cudaEventRecord(start, NULL) ); // Record the start event
 CUDA_SAFE_CALL( cudaMemcpy( dev_x, x,   n*sizeof(float), cudaMemcpyHostToDevice ));
 CUDA_SAFE_CALL( cudaMemcpy( dev_y, y,   n*sizeof(float), cudaMemcpyHostToDevice ));

 //llamada kernel producto escalar
 prod_esc_gpu<<<n_blocks,BLOCKSIZE>>>(dev_x, dev_y, dev_sal);


 CUDA_SAFE_CALL( cudaMemcpy( sal, dev_sal, n_blocks *sizeof(float), cudaMemcpyDeviceToHost ));

 //calculos adicionales ...obtener resultado en variable res_gpu
 float res_gpu;
 for(int i=0;i<n_blocks;i++){
  res_gpu+=sal[i];
 }


  CUDA_SAFE_CALL( cudaEventRecord(stop, NULL) );  // Record the stop event
  CUDA_SAFE_CALL( cudaEventSynchronize(stop) );   // Wait for the stop event to complete
  float msecGPU = 0.0f;
  CUDA_SAFE_CALL( cudaEventElapsedTime(&msecGPU, start, stop) );
  printf("CPU time = %.2f msec.\n",msecCPU);
  printf("GPU time = %.2f msec.\n",msecGPU);


  printf("res_cpu %f \n",res);
  printf("res_gpu %f \n",res_gpu);
 

  free(x);
  free(y);
  cudaFree(dev_x) ;
  cudaFree(dev_y) ;
}

