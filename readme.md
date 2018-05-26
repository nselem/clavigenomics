## Download it for the docker hub     
  
`docker pull nselem/clavigenomic`  
  
### Run the docker images  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /bin/bash`

### Introduce new genome
Asi quiero que queden:
-Descargar txt faa fna  
`docker run -i -t -v $(pwd):/home nselem/myrast getFiles.pl NewIdsFile`  
-Obtener central  fi
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /root/clavigenomics/Pseudocore/BBH.pl 558ParaCORE NewIdsFile`   OK
558ParaCORE is located in /root/clavigenomics/Pseudocore/558ParaCORE     


-Obtener blast  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /root/clavigenomics/Pseudocore/BBH.pl NewIdsFile OldIdsFile`  

-Correr el PseudoCore  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /root/clavigenomics/Pseudocore/Pseudocore.pl IdsFile`  


### To run a test  
1. mv the files on the example folder to /usr/src/CLAVIGENOMICS inside the docker container.  
`cp /root/clavigenomics/example/* .`  
2. Execute the Pseudocore script  
`Pseudocore.pl`  


  
## FastOrtho.   
`FastOrtho --option_file options.file`
1) Teniendo un archivo blast file i vs j. blast  para todo i,j  donde i,j son genome RAST Ids-  
seleccionar algunos i,j. 
2)Este script concatena todos los blast relacionados a i,j,. 
3) Y utiliza esto como un input.  
return fast ortho families, maybe with the name of the most recurrent   

## Para las familias en el n% de genomas    
 `cp /root/clavigenomics/exampleFO/* .`        
`makeFamiliesN.pl /usr/src/CLAVIGENOMICS Present 100 Absent 100`
`Detail Families`
