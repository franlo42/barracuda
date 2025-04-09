El objetivo del ejercicio es escribir un programa en CUDA que calcule el máximo valor en una matriz cuadrada de enteros.

- hay una función, llamada “calcula_max”, que calcula en la CPU el máximo de la matriz. Hay otra función para imprimir la matriz.

- El main genera la memoria en la CPU, genera una matriz de enteros aleatorios, la imprime, y llama a la función “calcula_max”, mostrando por pantalla el resultado.

Debéis completar ese código con lo necesario para que se calcule en la GPU el valor máximo (que por supuesto debe coincidir con el número calculado en la CPU). Como en los ejemplos vistos en clase, se recomienda hacer la última reducción en la CPU.

Se pueden hacer dos versiones: 
1) en la que se usa un thread o bloque por columna 
2) en la que varios threads de un mismo bloque colaboran para obtener el máximo de una columna.