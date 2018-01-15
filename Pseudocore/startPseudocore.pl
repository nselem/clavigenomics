#!/usr/bin/perl
use strict;
use warnings;
use lib qw(/usr/local/lib/perl5/site_perl/5.20.3/);
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
	
	my $genomeNumber=keys(%{$refIDS});
	print "Total of genomes $genomeNumber\n";

	#abrir los archivos de IDS 
	for (my $i=1;$i<=590;$i++){
		#print "Esta es $i\n";
		#buscar el gen $i
		#hacer push al array
		}

	#para cada gen del 1 al 590
 	#Contar el tamaño de su array si es igual que genomeNumber
	#Ponerlo en la lista de pseudocore
	
}
############################

sub readFile{
	my $file=shift;
	my %hash;
	open (FILE,$file) or die "Couldnt open file $file \n $!";
	foreach my $line(<FILE>){
		chomp $line;
		my @st=split(/\t/,$line);
		$st[1]=~s/\;//g;
		$st[1]=~s/\|//g;
		$st[1]=~s/ /\_/g;
		print "$st[0]->$st[1]\n";
		$hash{$st[0]}=$st[1];
	}
	return %hash;
}

sub mmm{
my $seqio_obj = Bio::SeqIO->new(-file => "$file",  -format => "fasta" );

while (my $seq_object = $seqio_obj->next_seq ){
my $id= $seq_object->display_id;
print "$id\n";
}

}
