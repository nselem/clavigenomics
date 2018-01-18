Download it for the docker hub   
`docker pull nselem/clavigenomic`  
  
Run the docker images  
`docker run -i -t -v $(pwd):/usr/src/CLAVIGENOMICS clavigenomics /bin/bash`

To run a test  
1. mv the files on the example folder to /usr/src/CLAVIGENOMICS inside the docker container.  
`cp /root/clavigenomics/example/* .`  
2. Execute the Pseudocore script  
`Pseudocore.pl`  
