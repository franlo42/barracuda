#include <stdio.h>

__global__ void suma(int a, int b, int *c)
{
    *c=a+b;
}

int main()
{
    int c;//Donde guardamos el valor de la suma
    int *dev_c;//Puntero a memoria en GPU donde estará el resultado de la suma

    cudaMalloc((void **)&dev_c, sizeof(int));//Reservar memoria en GPU

    suma<<<1,1>>>(2,7,dev_c);//Llamar a la funcion a ejecucion en GPU
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("Error en el lanzamiento del kernel: %s\n", cudaGetErrorString(err));
    }
cudaDeviceSynchronize(); // Espera a que se complete el kernel

    cudaMemcpy(&c, dev_c, sizeof(int), cudaMemcpyDeviceToHost);//Copiar resultado de memoria de la GPU a memoria de la CPU

    printf("2+7=%d\n", c);

    cudaFree(dev_c);//Liberar memoria de la GPU
    return 0;
}