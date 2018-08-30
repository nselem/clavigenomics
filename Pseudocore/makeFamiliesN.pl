#!/usr/bin/perl
use strict;
use warnings;
############################################33
# perl makeFamiliesN.pl /input/dir n file1 nOut fileOut
# Inputs
# N numero entre 0 y 100
# Despues todos los Genomas indicados por sus RastId (Gi)
# Output Archivo usr/src/CLAVIGENOMICS/salida/temp.end de fast Ortho
# Requiere archivos fasta y archivos .blast GivsGj.blast para cada i,j seleccionados 
#
# Puede usarse con archivos vacios para ver que familias estan ausentes de un cierto grupo (Dejando vacio file1)
# perl makeFamiliesN.pl /input/dir n file1 100 empty
# Inputs
# O bien que familias estan presentes en cierto grupo, dejando vacio fileOut
# perl makeFamiliesN.pl /input/dir n empty 100 file2

#######################3 Read variables
#if(-e [0-9]*){system("rm [0-9]*");}
my $path="/usr/src/CLAVIGENOMICS";
my $inputdir=shift @ARGV;
my $number=shift @ARGV; ## percentage of organism where family must be shared
my $fileIds= shift @ARGV;  ## organism where the family must be shared
my $numberOut=shift @ARGV;  ## percentage of organism where the family must be absent
my $fileIdsOut= shift @ARGV; ## Organisms where family must be absent  
## universe is the union between desired ids and ids desired out 
my @RastIds;  
my @RastIdsOut;  
fillIds($fileIds,\@RastIds);
fillIds($fileIdsOut,\@RastIdsOut);
##############################################################################
### Revisando inputs  
################################################################################
ViewInputs($number,\@RastIds,$numberOut,\@RastIdsOut);
#CreateFiles($path,\@RastIds,\@RastIdsOut);
#system("FastOrtho --option_file options.file");
my %FunctionalHash=ReadFunction($path,\@RastIds,\@RastIdsOut);
Select_n_families($number,$path,\%FunctionalHash,\@RastIds,$numberOut,\@RastIdsOut);
gradiente($number,$path,\%FunctionalHash,\@RastIds,$numberOut,\@RastIdsOut);
system ("rm /usr/src/RESULTS/salida/*");
system("mv $path/salida/* /usr/src/RESULTS/salida/.");
#system("rm *blast");

###################3 Subs ###################################
sub gradiente{
	my $number=shift;
	my $path=shift;
	my $FunctionalHash=shift;
	my $RastIds=shift;
	my $numberOut=shift;
	my $RastIdsOut=shift;
	## if wc temp.n_familis ==0 repetir selec_n families con number (presencia menor) misma ausencia e imprimir un archivo de GRADIENTE
	my $Encontradas= `wc -l < /usr/src/CLAVIGENOMICS/salida/temp.n_familias`;
	print "Encontradas $Encontradas\n";
	my $gradient=$number;
	my $Deseadas=0;


	while ($Encontradas <= $Deseadas){
		$gradient=$gradient-10;
		if($gradient>0){
			Select_n_families($gradient,$path,$FunctionalHash,$RastIds,$numberOut,$RastIdsOut);
			$Encontradas= `wc -l < /usr/src/CLAVIGENOMICS/salida/temp.n_familias`;
			print "Presencia\t$gradient\nAusencia\t$numberOut\nEncontradas\t$Encontradas\n";

			}
		else{
			$Encontradas=1;
			}
		}
			print "Pausa\n";
			my $pause=<STDIN>;
	if (-e "/usr/src/CLAVIGENOMICS/salida/gradiente"){system("rm /usr/src/CLAVIGENOMICS/salida/gradiente");} ## reportar si tuvo que hacer gradiente
	open (GRADIENTE,">/usr/src/CLAVIGENOMICS/salida/gradiente");
	print GRADIENTE "Presencia\t$gradient\nAusencia\n$numberOut\tEncontradas\n$Encontradas\n";
	close GRADIENTE;

	}
#----------------------------------------------------------------------------------------------------------
sub fillIds{
	my $fileIds=shift;
	my $refRastIds=shift;

	open (FILE,"$fileIds") or die "No pude abrir $fileIds\n$!";
	foreach my $id(<FILE>){
		chomp $id;
		$id=~s/\r//g;
  		push(@{$refRastIds},$id);
		}
}
#____________________________________________________________________

sub most_frequent{
	my @items=@_;
	my %count;


	@items = grep defined, @items;


	foreach my $item (@items){
	#	print "Item $item\n";
		if (exists $count{$item}){
			$count{$item}++;
			}
		else{
			$count{$item}=1;
			}
		}
	#$count{$_}++ for @items;
	#foreach my $item (@items){print "item $item\n";}
	# presuming at least one item in @items:
	my ($winner, $winner_count) = each %count;
	while (my ($maybe, $maybe_count) = each %count) {
		#print "Maybe $maybe $maybe_count\n";
		#print "Winer $winner $winner_count\n";
  		if ($maybe_count > $winner_count) {
    			$winner = $maybe;
    			$winner_count = $maybe_count;
  			}
		}
	return $winner;

	}

#______________________________________________________________________________________
sub ReadFunction{
	my $path=shift;
	my $RastIds=shift;
	my $RastIdsOut=shift;
	my %FunctionalHash;
	
	my %union; 
	foreach my $e (@RastIdsOut, @RastIds) {
    		$union{$e}++ ;
		}

	foreach my $id (keys %union){
		# print "$id\n";
		open (FILE,"$path/$id.txt") or die "No pude abrir $path/$id.txt $!\n";
			foreach my $line(<FILE>){
				chomp $line;
				#print "$line\n";
				my @st=split("\t",$line);
				$st[7]=~s/://g;
				$FunctionalHash{$st[1]} = $st[7];
			}

		}

	return %FunctionalHash;
	}


#____________________________________________________________________
sub Select_n_families{
	## Select all families with at least n% of presence in genomes
	my $number=shift;  ## percentage of presence
	my $path=shift;      ## input path
	my $FuncHash=shift; ## Families names
	my $RastIds=shift; ## ##Ids of presence (genomes not genes)
	my $numberOut=shift;  ##Percentage of ausence
	my $RastIdsOut=shift; ##Ids of the absence
	my $count=0;
	my $total=scalar @{$RastIds}; ## number of genomes
	my $totalOut=scalar @{$RastIdsOut}; ##number of genomes
#	print "Total number where you desired presence is: $total genomes\n";	
        my $porciento=$number*($total/100); ## Number of genomes desired to acomplish the percentage indicated by $number
#	print "Percentage $number is equivalent to: $porciento genomes\n";	
	if($porciento!=int($porciento)){$porciento=int($porciento)+1;}
        my $porcientoOut=$numberOut*($totalOut/100);
#	print "Total number of genomes where absence is desired: $totalOut genomes\n";	
	if($porcientoOut!=int($porcientoOut)){$porcientoOut=int($porcientoOut)+1;}
#	print "Percentage $numberOut is equivalent to: $porcientoOut genomes\n";	
#	print"Families with presence on at least $porciento of selected genomes, (more than $number% of selected genomes are shown)\n";
#	print"Families with presence on at least $porciento of selected genomes, (more than $number% of selected genomes are shown)\n";

	my $filename="$path/salida/temp.end";
	open (SALIDA,">$path/salida/temp.n_familias") or die " No pude crear $path/salida/temp.n_familias$!\n";
	open (JASON,">$path/salida/temp.js") or die " No pude crear $path/salida/temp.js$!\n";
	my $jason="[\n";
	open (FILE,"$filename") or die "No pude abrir el archivo $filename de fastortho en el directoriio salida\n";	

	foreach my $line (<FILE>){  ##Analizamos cada linea(familia) para ver que porcentaje tiene de los deseados y el porcentaje de ausencia de los no deseados
		chomp $line;
		my @Organisms;
		my @st=split("\t",$line);
		$st[0]=~/(ORTHOMCL\d*)\s*\(\d* genes,(\d*) taxa/;
		my $Familia=$1; my $Taxa=$2;

		#print "Familia:$1, Taxa:$2\n"; ## Finding most common name
                my @ids=split(" ",$st[1]);	
		my @functions;
		foreach my $id(@ids){
			$id=~s/(fig\|)(\d*\.\d*)(\.\w*\.\d*)\(\d*\.\d*\)/$1$2$3/;	## Que algo asi como fig|666.34536.peg.407 (Ejemplo)
			my $org=$2;     #org seria por ejemplo 666.34536
			#print "$org - $id\n";
			#my $pause=<STDIN>;
			my $func=$FuncHash->{$id};
			push(@functions,$func);
			push(@Organisms,$org);
		#	print TEMP "$func\n";
			}
			my @unique = do { my %seen; grep { !$seen{$_}++ } @Organisms }; #Hash de organismos no repetidos
			my $bool=1;

			my %union; my %isect; my %unionOUT; my %isectOUT;
			foreach my $e (@unique, @{RastIds}) {
    				$union{$e}++ && $isect{$e}++;
				}
			foreach my $e (@unique, @{$RastIdsOut}) {
	    			$unionOUT{$e}++ && $isectOUT{$e}++
				}
		my $size = keys %isect; ##Number of organisms where this family is present
		##
#		print "present on organisms where should be present\n";
		foreach my $key (keys %isect){
				# print "$key\n";
					}	
			#Present on real percentage
		my $Realporciento=100;
		if($total!=0){
	        	$Realporciento=$size*(100/$total); ## Percentage of desired organisms where this family is present
			##Percentage of organism where this family is absent (From the desired absent organisms)
			}
		#Absent on 
		my $sizeout = keys %isectOUT;  #Number of organisms where this family is desired absent but is present
#		print "present on organisms where should be absent\n";
		foreach my $key (keys %isectOUT){
			#print "$key\n";
				}
		my $RealporcientoOut=100;
		if($totalOut!=0){
        		$RealporcientoOut=100-$sizeout*(100/$totalOut); 
			##Percentage of organism where this family is absent (From the desired absent organisms)
			}
		else{#print"mmm"; my $pause=<STDIN>;
			}

		#print "Present on $Realporciento absent on $RealporcientoOut\n" ;
		#foreach my $func (@functions){print "Funcion $func\n";}
		my $nombre=most_frequent(@functions);
		#print "name $nombre\n";
#		system("rm $path/salida/name");
		if((int($Realporciento)>=$number) and (int($RealporcientoOut)>=$numberOut)){
			my @pegs=split(" ",$st[1]);
			print SALIDA "$Familia:$Realporciento:$porciento:$RealporcientoOut:$nombre:$st[1]\n";#
			$jason=$jason."\t{\n";
			$nombre=~s/\(//g;
			$nombre=~s/\)//g;
			#$nombre=~s/\&//g;
			$nombre=~s/\"//g;
			$nombre=~s/\///g;
			$nombre=~s/\r//g;
			#$nombre=~s/\;//g;
			$jason=$jason."\t\t\"family\":\"$nombre\",\n";#
			$jason=$jason."\t\t\"id\":\"$Familia\",\n";#
			$jason=$jason."\t\t\"items\": [\n";#
			foreach my $peg(@pegs){
				$jason=$jason."\t\t\t{\n";
				$peg=~m/(\d*)\.(\d*)\.\w*\.(\d*)/;
				$jason=$jason."\t\t\t\"rast_id\": \"$1.$2\",\n";#
				$jason=$jason."\t\t\t\"gen\": \"$3\"\n";#
				$jason=$jason."\t\t\t},\n";
				}
			$jason=substr($jason, 0, -2)."\n";
			$jason=$jason."\t\t]\n";#
			$jason=$jason."\t},\n";
			$count++;
			## La idea es desplegar una pagina con todos los nombres de las familias
                        ## Y que estos sean hiperlinks
			## En el script InfoFamilia.pl se delegaran todos los genomas que pertenecen a esta familia
			## Todos los ids con hiperlink a la secuencia
			## un arbol de FastTree con estas secuencias
			}	
#		print "0 $st[0] ->  1 $st[1]\n";
		}
	$jason=substr($jason, 0, -2)."\n";
	my $test=$jason;
	chomp $test;
	if($test ne ""){
		$jason=$jason."]";
		print JASON "$jason";
		close JASON;
		}
	else{
		close JASON;
		system("rm $path/salida/temp.js");
		}
	close SALIDA;
	close FILE;
	}  
#________________________________________________________ 
sub ViewInputs{
	## User inputs n and Rast Ids
	## check n between o and 100 and Rast Ids valid Ids	
	my $number=shift;
	my $RastIds=shift;
	my $NumOut=shift;
	my $RastIdsOut=shift;

	if($number>100 || $number<0){
		print" N=$number debe ser un número entre 0 y 100\n"; 
		exit;
		}
	elsif($NumOut>100 || $NumOut<0){
		print" N?$NumOut debe ser un número entre 0 y 100\n"; 
		exit;
		}
	else{	
		print "Usted quiere saber las familias con presencia en el $number del archivo1 con ausencia en el $NumOut del archivo 2\n";
		}

	foreach my $id(@{$RastIds}){
		if (!($id=~/\d*\.\d*/)){
			print "Id $id must be a valid rastId";
			exit;
			}
		print "Id $id\n";
		}
	my $sizeIn=@{$RastIds}; 
	if($sizeIn==0){print "ERROR: Presence genome file is empty\n"; exit;}
	if($sizeIn==1){print "ERROR: Presence genome contains only one genome Id, this software does not identify singletones\n"; exit;}

	print "Ausente\n";	
	foreach my $id(@{$RastIdsOut}){
		if (!($id=~/\d*\.\d*/)){
			print "Id $id must be a valid rastId";
			exit;
			}
		print "Id $id\n";
		}
	if (-e "$path/temp.blast"){system("rm $path/temp.blast"); }
	my %isect;my %union;
	foreach my $e (@{$RastIds}, @{$RastIdsOut}) {
	    	$union{$e}++ && $isect{$e}++;
				}
	my $size=keys %isect;
	if($size>0){
		print "ERROR:There is a non empty intersection between the selected present - absent genomes \n";
		foreach my $key (keys %isect){
		print"$key\n";
			}
		exit;
		}	
	}
############################################################################
sub CreateFiles{
	## rast id numbers
	## Create temp blast file and options file with every rast id 
	my $path=shift;
	my $RastIds=shift;
	my $RastIdsOut=shift;
	if (-e "$path/salida"){system("rm -r $path/salida"); }
	system("mkdir $path/salida");
	if (-e "$path/options.file"){system("rm $path/options.file"); }

	open(FILE, ">$path/options.file");
	print FILE "--mcl_path /root/local/bin/mcl\n";
	print FILE "--blast_file $path/temp.blast\n";
	print FILE "--working_directory $path/salida\n";
	print FILE "--project_name temp\n";

	my %union; my %isect; 
	foreach my $e (@{$RastIdsOut}, @{$RastIds}) {
    		$union{$e}++ && $isect{$e}++;
			}
	my $string="";
	foreach my $id_i(keys %union){
		print FILE "--single_genome_fasta  $path/$id_i.faa\n";
		foreach my $id_j(keys %union){
			if($id_i ne $id_j){
				my $blastfile=$id_i."_vs_".$id_j.".blast";
				my $blastfilefull="$path/$blastfile";
				if (! (-e $blastfilefull)){ print "no blastfile $blastfilefull";exit;}
				$string=$string.$blastfilefull." ";
				print("cat $blastfilefull >>$path/temp.blast\n");
				system("cat $blastfilefull >>$path/temp.blast");
				}
			}
		}
	close FILE;
	}

###############################################################


