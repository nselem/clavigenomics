#!/usr/bin/perl
use strict;
use warnings;
############################################33
# perl makeFamiliesN.pl n RastId1, RastId2.... RastIdN
# Inputs
# N numero entre 0 y 100
# Despues todos los Genomas indicados por sus RastId (Gi)
# Output Archivo usr/src/CLAVIGENOMICS/salida/temp.end de fast Ortho
# Requiere archivos fasta y archivos .blast GivsGj.blast para cada i,j seleccionados 
#
#######################3 Read variables
my $path="/usr/src/CLAVIGENOMICS";
my $inputdir=shift @ARGV;
my $number=shift @ARGV;
my $fileIds= shift @ARGV;
my @RastIds;

print "input dir $inputdir\n";
print "number $number\n";
print "fileIDs $fileIds\n";

open (FILE,"$fileIds") or die "No pude abrir $fileIds\n$!";
foreach my $id(<FILE>){
	chomp $id;
	$id=~s/\r//g;
  	push(@RastIds,$id);
	}

##############################################################################
### Revisando inputs  
################################################################################
ViewInputs($number,@RastIds);
CreateFiles($path,@RastIds);
system("FastOrtho --option_file options.file");
my %FunctionalHash=ReadFunction($path,@RastIds);
Select_n_families($number,$path,\%FunctionalHash,@RastIds);


sub most_frequent
{
  local *_=*_;
  $_[$_{$_}] = $_ for map{$_{$_}++; $_} @_;
  $_[-1];
}
###################3 Subs ###################################
sub ReadFunction{
	my $path=shift;
	my @RastIds=@_;
	my %FunctionalHash;
	
	foreach my $id (@RastIds){
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
	my $number=shift;
	my $path=shift;
	my $FuncHash=shift;
	my @RastIds=@_;
	my $count=0;
	my $total=scalar @RastIds;
	print "Usted escogio $total genomas\n";	
        my $porciento=$number*($total/100);
	if($porciento!=int($porciento)){
		$porciento=int($porciento)+1;
		}
	print"Se muestran las familias con al menos $porciento genomes, (mas del $number% del total de genomas seleccionados)\n";

	my $filename="$path/salida/temp.end";
	open (SALIDA,">$path/salida/temp.n_familias") or die " No pude crear $path/salida/temp.n_familias$!\n";;
	open (JASON,">$path/salida/temp.js") or die " No pude crear $path/salida/temp.js$!\n";;
	print JASON "{\n";
	open (FILE,"$filename") or die "No pude abrir el archivo $filename de fastortho en el directoriio salida\n";	
	foreach my $line (<FILE>){
		chomp $line;
		my @st=split("\t",$line);
		$st[0]=~/(ORTHOMCL\d*)\s*\(\d* genes,(\d*) taxa/;
		my $Familia=$1; my $Taxa=$2;

		#print "Familia:$1, Taxa:$2\n"; ## Finding most common name
                my @ids=split(" ",$st[1]);	
		my @functions;
		foreach my $id(@ids){
			$id=~s/(fig\|\d*\.\d*\.\w*\.\d*)\(\d*\.\d*\)/$1/;
			my $func=$FuncHash->{$id};
			push(@functions,$func);
			}
		my $nombre=most_frequent(@functions);

		if(int($Taxa)>=$porciento){
			my @pegs=split(" ",$st[1]);
			
			print SALIDA "$Familia:$nombre:$st[1]\n";#
			print JASON "\t{\n";
			print JASON "\t\tfamily:\"$nombre\",\n";#
			print JASON "\t\tid:\"$Familia\",\n";#
			print JASON "\t\titems: [\n";#
			foreach my $peg(@pegs){
				print JASON "\t\t\t{\n";
				$peg=~m/(\d*)\.(\d*)\.\w*\.(\d*)/;
				print JASON "\t\t\trast_id: \"$1.$2\",\n";#
				print JASON "\t\t\tgen: \"$3\"\n";#
				print JASON "\t\t\t},\n";
				
				}
			print JASON "\t\t]\n";#
			print JASON "\t},\n";
			$count++;
			## La idea es desplegar una pagina con todos los nombres de las familias
                        ## Y que estos sean hiperlinks
			## En el script InfoFamilia.pl se delegaran todos los genomas que pertenecen a esta familia
			## Todos los ids con hiperlink a la secuencia
			## un arbol de FastTree con estas secuencias
			}	
#		print "0 $st[0] ->  1 $st[1]\n";
		}
	print JASON "}";
	close JASON;
	close SALIDA;
	close FILE;
	}  
#________________________________________________________ 
sub ViewInputs{
	## User inputs n and Rast Ids
	## check n between o and 100 and Rast Ids valid Ids	
	my $number=shift;
	my @RastIds=@_;

	if($number>100 || $number<0){
		print" N debe ser un número entre 0 y 100\n"; 
		exit;
		}
	else{	
		print "Usted quiere saber Familias presencia en el $number%\n";
		}

	foreach my $id(@RastIds){
		if (!($id=~/\d*\.\d*/)){
			print "Id $id must be a valid rastId";
			exit;
			}
		print "Id $id\n";
		}
	}
if (-e "$path/temp.blast"){system("rm $path/temp.blast"); }
############################################################################
sub CreateFiles{
	## rast id numbers
	## Create temp blast file and options file with every rast id 
	my $path=shift;
	my @RastIds=@_;
	if (-e "$path/salida"){system("rm -r $path/salida"); }
	system("mkdir $path/salida");
	if (-e "$path/options.file"){system("rm $path/options.file"); }

	open(FILE, ">$path/options.file");
	print FILE "--mcl_path /root/local/bin/mcl\n";
	print FILE "--blast_file $path/temp.blast\n";
	print FILE "--working_directory $path/salida\n";
	print FILE "--project_name temp\n";

	my $string="";
	foreach my $id_i(@RastIds){
		print FILE "--single_genome_fasta  $path/$id_i.faa\n";
		foreach my $id_j(@RastIds){
			if($id_i ne $id_j){
				my $blastfile=$id_i."_vs_".$id_j.".blast";
				my $blastfilefull="$path/$blastfile";
				if (! (-e $blastfilefull)){ print "no blastfile $blastfilefull";exit;}
				$string=$string.$blastfilefull." ";
				}
			}
		}
	system("cat $string >temp.blast");
	print("cat $string >$path/temp.blast\n");
	close FILE;
	}

###############################################################


