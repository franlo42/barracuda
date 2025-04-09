Queremos implementar en la gpu un filtro para suavizar una imagen (matriz). Dada una matriz Inpde dimensiones M filas por N columnas, queremos calcular una matriz Outde dimensiones M-2 filas por N-2 columnas , de forma que el elemento [i,j] de Outse calcule así:

Out(i,j)=(Inp(i-1,j)+Inp(i+1,j)+Inp(i,j-1)+Inp(i,j+1)+Inp(i,j))/5.0

Escribe un programa y un kernelque hagan esta operación. Puedes usar como base el código del ejercicio de calcular las medias de una matriz, usando M=8 y N=12