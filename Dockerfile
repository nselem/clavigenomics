# DOCKER-VERSION 0.3.4
FROM perl:5.20

###____________________________________________
RUN if [ ! -d /opt ]; then mkdir /opt; fi
###____________________________________________
# Installing blast
RUN mkdir /opt/blast && curl ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.30/ncbi-blast-2.2.30+-x64-linux.tar.gz | tar -zxC /opt/blast --strip-components=1
######_____________________________________________________________________________________
# Instaling muscle
 RUN wget -O /opt/muscle3.8.tar.gz http://www.drive5.com/muscle/downloads3.8.31/muscle3.8.31_i86linux64.tar.gz
 RUN mkdir /opt/muscle && tar -C /opt/muscle -xzvf /opt/muscle3.8.tar.gz && ln -s /opt/muscle/muscle3.8.31_i86linux64 /opt/muscle/muscle  
####__________________________________________________________________
# Installing GBlocks
RUN curl -SL http://molevol.cmima.csic.es/castresana/Gblocks/Gblocks_Linux64_0.91b.tar.Z | tar -xzC /opt && ln -s /opt/Gblocks_0.91b/Gblocks /usr/bin/Gblocks
####___________________________________________________________________
## Instaling FastTree
RUN mkdir /opt/fasttree && wget -O /opt/fasttree/FastTree http://www.microbesonline.org/fasttree/FastTree && chmod +x /opt/fasttree/FastTree
#________________________________________________________________________________
# Installing NewickTools
RUN wget -O /opt/newick-utils-1.6.tar.gz http://cegg.unige.ch/pub/newick-utils-1.6-Linux-x86_64-disabled-extra.tar.gz 
RUN mkdir /opt/nw && tar -C /opt/nw -xzvf /opt/newick-utils-1.6.tar.gz && cd /opt/nw/newick-utils-1.6 && cp src/nw_* /usr/local/bin
##___________________________________________________
#### Vim
RUN cd ~
RUN git clone https://github.com/vim/vim.git
RUN cd vim && ./configure && make VIMRUNTIMEDIR=/usr/share/vim/vim74 && make install

##___________________________________________________
#### MCL  
RUN wget -O /opt/mcl-14-137.tar.gz https://micans.org/mcl/src/mcl-14-137.tar.gz
RUN mkdir /opt/mcl && tar -C /opt/mcl -xzvf /opt/mcl-14-137.tar.gz && cd /opt/mcl/mcl-14-137 &&  ./configure --prefix=$HOME/local && make install

#_________________________________________________________________________________________________
## Clavigenomics
RUN git clone https://github.com/nselem/clavigenomics
RUN mkdir /opt/CLAVIGENOMICS
## Installing perl module
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm SVG
RUN cpanm Bio::SeqIO;
RUN cpanm Bio::SeqFeature::Generic;
RUN chmod -R 777 /root/clavigenomics/Pseudocore



######### PATHS ENVIRONMENT
ENV PATH /opt/blast/bin:$PATH:/opt/muscle:/opt/Gblocks:/opt/quicktree/quicktree_1.1/bin:/root/clavigenomics/Pseudocore:/opt/fasttree:/root/clavigenomics/FastOrtho/src/
ENV PERL5LIB /usr/local/lib/perl5/site_perl/5.20.3/
WORKDIR /usr/src/CLAVIGENOMICS

## Como paso variables ?
CMD ["perl", "/root/EvoDivMet/CORASON/SSHcorason.pl"]
## Volumen para escribir la salida
