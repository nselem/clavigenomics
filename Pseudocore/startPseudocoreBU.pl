#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

my $file="/usr/src/CLAVIGENOMICS/lista";

#Read lista file
#input lista
##output hash key:RastId content Human name
my %IDS=readFile($file);


## foreach gen on the Reference find its distribution
## input a gen number
## output A hash of arrays with all the Genome Ids where is present.
genomeDistribution(\%IDS);

sub genomeDistribution{
	my $refIDS=shift;
        my %HASH;	
	my $genomeNumber=keys(%{$refIDS});
	#print "Total of genomes $genomeNumber\n";

         # creo un aray para cada gen en el reference core
	for (my $i=1;$i<=590;$i++){
			$HASH{$i}=();
			}

	#lleno este array en orden recorriendo todos los genomas  
	#abrir los archivos de IDS
	my @keys=(sort keys %{$refIDS});
	foreach my $key (sort keys %{$refIDS}){ 
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
	for (my $i=1;$i<=590;$i++){
			print "Getting elements on pseudocore\n";
			if(-exists $HASH{$i}){
				my $isize=scalar@{$HASH{$i}};
#				print "The size of $i is $isize\n";
				if($isize==$genomeNumber){
				#		print "$i\t$isize\t@{$HASH{$i}}}\n";
					open(FILE,">$i") or die "$!\n";
					foreach my $seq (@{$HASH{$i}}){
						$seq=~s/\_/\n/;
						print FILE ">$seq\n";
				#		my $pause=<STDIN>;
					}
					close FILE;
					system(" muscle -in $i -out $i.muscle.pir -fasta -quiet -group");
			#		system ("echo SortAlign.pl $i.muscle.pir");
					system("SortAlign.pl $i.muscle.pir");
				}
			}
		}
		system("Concatenador.pl @keys");

 #open my $zcat, 'zcat seq.fastq.gz |' or die $!;
 # my $in=Bio::SeqIO->new(-fh=>$zcat,     -format=>'fastq');
#  my $out=Bio::SeqIO->new(-file=>'>seq.fasta',                          -format=>'fasta');
 # while (my $seq=$in->next_seq) {
  #    $out->write_seq($seq)
  #}	
}
############################

sub readFile{
	print "Reading genomes list\n...";
	my $file=shift;
	my %hash;
	open (FILE,$file) or die "Couldnt open file $file \n $!";
	foreach my $line(<FILE>){
		chomp $line;
		my @st=split(/\t/,$line);
		$st[1]=~s/\;//g;
		$st[1]=~s/\|//g;
		$st[1]=~s/ /\_/g;
	#	print "$st[0]->$st[1]\n";
		$hash{$st[0]}=$st[1];
	}
	return %hash;
}

