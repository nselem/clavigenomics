## Download it for the docker hub     
  
`docker pull nselem/clavigenomic`  
  
### Run the docker images  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS nselem/clavigenomic /bin/bash`

### To run a test  
1. mv the files on the example folder to /usr/src/CLAVIGENOMICS inside the docker container.  
`cp /root/clavigenomics/example/* .`  
2. Execute the Pseudocore script  
`Pseudocore.pl`  


## To Create the blast file for a set of genomes .faa   
  
`ls *faa | while read line; do BBH.pl 558ParaCORE $line; done`  

To change the core genes reference file:  
`mv <referencefile> /root/clavigenomics/Pseudocore/.`  
  
## FastOrtho.   
`FastOrtho --option_file options.file`
1) have a blast file ivs j. blast foralli,j  
select some i,j. 
2)concat this files. 
3) give this as an input. 
return fast ortho families, maybe with the name of the most recurrent   

## Para las familias en el n% de genomas    
 `cp /root/clavigenomics/exampleFO/* .`        
`makeFamiliesN.pl 80 6666666.268671 6666666.268675`       
