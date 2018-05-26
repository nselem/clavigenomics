# Clavigenomics

Casi todos los archivos de IDs contienen solo RAST genome ids:  
> 6666666.1298689  
> 6666666.1298474  
  
excepto el de descargar genomas de RAST, ahi es necesario tambien el job id, por requerimiento de myrast.  
Ejemplo   
> 876438     6666666.138469  
> 358438     2.1140  
  
Usuarios por favor tener cuidado de escribir los últimos ceros, 2.1140 en lugar de 2.114 como aveces los trata excel.  
   
  
### 1 Correr la imagen de docker de modo interactivo  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /bin/bash`

### 2. Introducir un nuevo genoma a la aplicación  
1. Descargar txt faa fna    
`docker run -i -t -v $(pwd):/home nselem/myrast getFiles.pl NewIdsFile`  

Output ẗxt *faa *fna  
2. Crear Central  (Pseudocore files)
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /root/clavigenomics/Pseudocore/BBH.pl 558ParaCORE NewIdsFile`  
Output *Central
Note: 558ParaCORE is located in /root/clavigenomics/Pseudocore/558ParaCORE     
  
3. Crear blast     (Contra todos los genomas)
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /root/clavigenomics/Pseudocore/blasting.pl NewIdsFile OldIdsFile` 
Output *blast   

## 3. Obtener el Pseudocore  
-Correr el PseudoCore  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /root/clavigenomics/Pseudocore/Pseudocore.pl IdsFile` 
Output: Salida.tre  
  
Para un ejemplo mueve los archivos del folder /root/clavigenomics/example/ a /usr/src/CLAVIGENOMICS
`cp /root/clavigenomics/example/* .`  


## 4. Obtener presencia y ausencia hasta cierto porcentaje de familias  
 `cp /root/clavigenomics/exampleFO/* .`        
`makeFamiliesN.pl /usr/src/CLAVIGENOMICS/ 100 Presencia 100 Ausencia`
`DetailFamilu.pl FamiliID /usr/src/CLAVIGENOMICS`
  
### FastOrtho.   
`FastOrtho --option_file options.file`
1) Teniendo un archivo blast file i vs j. blast  para todo i,j  donde i,j son genome RAST Ids-  
seleccionar algunos i,j. 
2)Este script concatena todos los blast relacionados a i,j,. 
3) Y utiliza esto como un input.  
return fast ortho families, maybe with the name of the most recurrent   
