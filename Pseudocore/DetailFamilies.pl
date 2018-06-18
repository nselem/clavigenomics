#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;

############################################33
# perl DetailFamilu.pl FamiliID Outputfile RASTIds
# Inputs
# Family Id 
# Output Archivo usr/src/CLAVIGENOMICS/salida
# Requiere archivo .family
#
#######################3 Read variables

my $FamId=shift @ARGV; # Example ORTHOMCL2243
my $dir=shift @ARGV;   # Output file
#my $rast=shift @ARGV;   # RastIds File

#print "Fam $FamId\n";
#print "file $dir\n";
readFamilies($dir,$FamId); ## Read family ids and then opens fasta file, extract sequences and write a family fasta file
system("muscle -in $dir/salida/$FamId.fasta -out $dir/salida/$FamId.fasta.muscle.pir -fasta -quiet -group");
system "Gblocks $dir/salida/$FamId.fasta.muscle.pir -b4=5 -b5=n -b3=5";
system("FastTree $dir/salida/$FamId.fasta.muscle.pir-gb > $dir/salida/$FamId.tre");

############### subs ###############################
#------------------------------------
sub readFamilies{
	my $dir=shift;
	my $FamId=shift;
	open (FILE,"$dir/salida/temp.n_familias") or die "NO pude abrir $dir $!\n";
	open (OUTPUTFASTA,">$dir/salida/$FamId.fasta") or die "NO pude abrir $dir $!\n";
	open (OUTPUTFASTA_DNA,">$dir/salida/$FamId.fna") or die "NO pude abrir $dir $!\n";
		foreach my $line (<FILE>){
			chomp $line;
			my @st=split(":",$line);
			if($FamId eq $st[0]){
				print "$st[0]\n$line\n";
				#my $pause=<STDIN>;
				my @Preids=split(" ",$st[5]);	
				my @ids;
				foreach my $id(@Preids){
					$id=~s/fig\|(\d*\.\d*)\.(\w*\.\d*)\(\d*\.\d*\)/fig\|$1\.$2/;
					push(@ids,$id);
					my $genomeId=$1;	
					#print "genome $genome \n";
					#print "uno # $1 #\n";
					#print "GEnome $1->$id\n";
					my $seqio_obj = Bio::SeqIO->new(-file => "$dir/$genomeId.faa",  -format => "fasta" );
					while(my $seq=$seqio_obj->next_seq){
						my $seqid=$seq->id;
						my $am=$seq->seq();
						#print "$id mm $seqid\n";
						if($id eq $seqid){
							#print $seq->id.'='.$seq->seq()."\n";
							print OUTPUTFASTA ">$seqid\n";
							print OUTPUTFASTA "$am\n";
							next;
							}
						}
					$seqio_obj->close();

					my $seqio_objdna = Bio::SeqIO->new(-file => "$dir/$genomeId.fna",  -format => "fasta" );
					while(my $seq=$seqio_objdna->next_seq){
						my $seqid=$seq->id;
						my $am=$seq->seq();
						#print "$id mm $seqid\n";
						if($id eq $seqid){
							#print $seq->id.'='.$seq->seq()."\n";
							print OUTPUTFASTA_DNA ">$seqid\n";
							print OUTPUTFASTA_DNA "$am\n";
							next;
							}
						}
					$seqio_objdna->close();

					}
				next;				
				}
			}
		close FILE;
		close OUTPUTFASTA;
		close OUTPUTFASTA_DNA;
		}


