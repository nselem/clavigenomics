#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $file=$ARGV[0];

#Read lista file
#input lista
##output hash key:RastId content Human name
my @IDS=readFile($file);

## foreach gen on the Reference find its distribution
## input a gen number
## output A hash of arrays with all the Genome Ids where is present.
genomeDistribution(@IDS);
system("FastTree SalidaConcatenada.txt > Salida.tre");
system("rm [0-9]*temp");
system("rm *gb");
system("rm *muscle");
system("rm *pir");

sub genomeDistribution{
	my @array=@_;
        my %HASH;	
	my $genomeNumber=@array;
	#print "Total of genomes $genomeNumber\n";

         # creo un array para cada gen en el reference core
	for (my $i=1;$i<=558;$i++){
			$HASH{$i}=();
			}

	#lleno este array en orden recorriendo todos los genomas  
	#abrir los archivos de IDS
	my @keys=(sort @array);
	foreach my $key (sort @array){ 
		my $file=$key.".Central";
		#print "$file\n";
		my $seqio_obj = Bio::SeqIO->new(-file => "$file",  -format => "fasta" );
		while (my $seq_object = $seqio_obj->next_seq ){
			my $id= $seq_object->display_id;
			my $seq= $seq_object->seq;
			my @st=split(/_/,$id);
			#print "$st[0]\n";
			push(@{$HASH{$st[0]}},"$key\_$seq");
	        	#	print "$key,->$HASH{$st[0]}\n";
			}
		}

	#para cada gen del 1 al 590
 	#Contar el tamaño de su array si es igual que genomeNumber
	#Ponerlo en la lista de pseudocore
	for (my $i=1;$i<=558;$i++){
#			print "Getting elements on pseudocore\n";
	#		print "The size of $i is \n";
			if(-exists $HASH{$i}){
				my $isize=scalar@{$HASH{$i}};
				if($isize==$genomeNumber){
				#		print "$i\t$isize\t@{$HASH{$i}}}\n";
					open(FILE,">$i\.temp") or die "Coudnt open $i file $!\n";
					foreach my $seq (@{$HASH{$i}}){
						$seq=~s/\_/\n/;
						print FILE ">$seq\n";
					}
					close FILE;
					system(" muscle -in $i\.temp -out $i.muscle.pir -fasta -quiet -group");
			#		system ("echo SortAlign.pl $i.muscle.pir");
					system("SortAlign.pl $i.muscle.pir");
				}
			}
		}
		print("echo Concatenador.pl @keys");
		system("Concatenador.pl @keys");

}
############################

sub readFile{
	print "Reading genomes list\n...";
	my $file=shift;
	my @array;
	open (FILE,$file) or die "Couldnt open file $file \n $!";
	foreach my $line(<FILE>){
		chomp $line;
		push(@array,$line);
	}
	return @array;
}

