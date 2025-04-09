El objetivo del ejercicio es escribir un programa en CUDA que calcule el número total de veces que una cierta secuencia de longitud 2 (por ejemplo 6,3) que aparecen en una matriz cuadrada de números enteros entre 0 y 9 (Problema relacionado con secuenciación de ADN). Las secuencias se deben buscar por columnas.

1) hay una función, llamada “contar_int”, que calcula en la CPU el número de apariciones de una cierta secuencia de longitud 2. Hay otra función para imprimir la matriz.

2) El main genera la memoria en la CPU, genera una matriz de números enteros aleatorios, la imprime y llama a la función contar_int, mostrando por pantalla el resultado.

Completar ese código con lo necesario para que se calcule en la gpu el número de apariciones de la secuencia.

Para facilitar el trabajo, se pueden entregar dos versiones, de orden creciente de dificultad:

- una básica, versión 1, en la que se usa un thread o bloque por columna, y solo se buscan las secuencias por columnas.

- versión 2, en la que usa un bloque por columna y varios threads colaboran para contar las secuencias en su columna.
Como en los ejemplos vistos en clase, se tiene que hacer una última reducción en la CPU.