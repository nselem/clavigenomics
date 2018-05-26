#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
no warnings 'experimental::smartmatch';

############################################
#$perl allvsall.pl -R 1,2,3 -v 0 -i file.blast

#Variables
my $verbose;
my $e=0.001;
my $file1=$ARGV[0]; ## Fasta file with some genes The reference Core
my $FIds=$ARGV[1]; ## Fasta file with ids of others genomes where to look for BBH (THe genome)

open(FILE2,$FIds) or die "Couldnt open FILE2\n";

foreach my $file2 (<FILE2>){
	chomp $file2;
	#print "\nLooking for BBH between #$file1# on set #$file2#\n ";
	# first  blast p from 1vs2
	#print("makeblastdb -in $file2\.faa -dbtype prot -out $file2\.db\n");
	system("makeblastdb -in $file2\.faa -dbtype prot -out $file2\.db");
	#print("blastp -db $file2\.db -query /root/clavigenomics/Pseudocore/$file1 -outfmt 6 -evalue $e -num_threads 4 -out $file1\_vs\_$file2\n");
	system("blastp -db $file2\.db -query /root/clavigenomics/Pseudocore/$file1 -outfmt 6 -evalue $e -num_threads 4 -out $file1\_vs\_$file2");
	#second blastp 2vs1
	#print("makeblastdb -in /root/clavigenomics/Pseudocore/$file1 -dbtype prot -out $file1\.db\n");
	system("makeblastdb -in /root/clavigenomics/Pseudocore/$file1 -dbtype prot -out $file1\.db");
	#print("blastp -db $file1\.db -query $file2\.faa -outfmt 6 -evalue $e -num_threads 4 -out $file2\_vs\_$file1\n");
	system("blastp -db $file1\.db -query $file2\.faa -outfmt 6 -evalue $e -num_threads 4 -out $file2\_vs\_$file1");
	my $inputblast1vs2="$file1\_vs\_$file2";
	my $outname1="$file1\_vs\_$file2\_BH";
	my %BH1vs2 = (); #Hash de hashes
	my $inputblast2vs1="$file2\_vs\_$file1";
	my $outname2="$file2\_vs\_$file1\_BH";
	my %BH2vs1 = (); #Hash de hashes
	my %BiBestHits;
	my $BBHfile="BBH\_$file1\_$file2";
	#print "Blast done\n\n";

#my @Required=Options(\$verbose,\$inputblast,\$output,\$outname);
#################################################################################################
########################################################
## Main
## 1 Find Best Hits
	#print "\nFinding Hits $file1 ve $file2, takes some minutes, be patient!\n"; 
	&bestHit($outname1,\%BH1vs2,$inputblast1vs2);


	#print "\n\nFinding Hits $file2 ve $file1, takes some minutes, be patient!\n"; 
	&bestHit($outname2,\%BH2vs1,$inputblast2vs1);

	## 2 Find Bidirectional Best Hits
	#print "\n\nNow finding Best Bidirectional Hits List\n";
	&ListBidirectionalBestHits(\%BiBestHits,\%BH1vs2,\%BH2vs1);
	#print "\n\n";

############ ForEvoMining central Code
	my %FASTA;
	readFile($file2,\%FASTA);
	printEvoFormat(\%BiBestHits,\%FASTA,$file2);
}

#####################################################A
############################################################

sub readFile{
	my $file=shift;
	my $refFASTA=shift;
	open (FILE, "$file\.faa") or die "Unable to open file  $file.faa $!\n";
	my $key="";
	foreach my $line (<FILE>){
		chomp $line;
#		print "$line\n";

		if($line=~/>/){
#			print "Line \ $line\n";
			$refFASTA->{$line}="";
			$key=$line;		
			}
		else{
			$refFASTA->{$key}=$refFASTA->{$key}.$line;
			}	

		}
	}

#foreach my $seq (keys %FASTA){
#	print "key:$seq\nSeq:$FASTA{$seq}\n\n";
#	}
#exit;

sub printEvoFormat{
	my $refBBH=shift;
	my $refFASTA=shift;
	my $file2=shift;
	my $FinalName;

	open (FILE,">$file2\.Central") or die "Unable to open file $!\n";
	#print "Este es >$file2\.Central\n";
	for my $query (sort {$a<=>$b} keys %$refBBH){
		my $hit=$refBBH->{$query};
		my $key=">".$hit;
#		my $key=$hit;
#		print "key $key\n";
		$hit=~s/fig\|//;
		$hit=~s/\.peg\.\d*$//;
		my $seq=$refFASTA->{$key};

		#my @sp=split(/\|/,$query);
		#$query=~s/$sp[$#sp]//;

		print FILE">$query"."_"."$hit\n";
		if($hit ne ""){
			#print "$FinalName\n";
			$FinalName=$hit;
			}
		print FILE"$seq\n\n";
		}
	close FILE;
	system ("mv $file2\.Central $FinalName\.Central");
	}



#__________________________________________________________________________________________________
#__________________________________________________________________________________________________
sub bestHit(){
	my $outname=shift;
	my $BH=shift;
	my $input=shift;
	open(FILE, "$input") or die "Couldnt open $input file \n$!";

	foreach my $line(<FILE>) {
		my @sp = split(/\t/, $line);
#		print "Query: ".$sp[0] . "\t Hit" . $sp[1] . "\t\t Similitud:" . $sp[2] . "\n";

	##sp[0] query gen from column A
	#If there are not previous hits for the query
		if(!exists $BH->{$sp[0]}) { $BH->{$sp[0]} = [0]; }## Then I start a list
		#if(!exists $BH->{$sp[0]}{$o2}) { $BH->{$sp[0]}{$o2} = [0]; } ## If it does not exist a hit for genColumnA and orgColumnB 
									     ## Start in 0.

		if($sp[2] > $BH->{$sp[0]}[0]) { ## If for the organism the new line has a better match
			$BH->{$sp[0]}= [$sp[2], $sp[1]]; ## I change it ## If the score is the same
							       ## I will lost paralogs (same score and choose arbitrary one)
							       ## It would be a good idea to improve this part
			} elsif($sp[2] > $BH->{$sp[0]}[0]) {
				push(@{$BH->{$sp[0]}}, $sp[1]);
		}
		
	}
	close(FILE);
	} #### Data Structure BEst Hit (BH) has been fullfilled with the best hit of each gene

#__________________________________________________________________________________________________

sub ListBidirectionalBestHits(){
## Arguments HAsh Best Hits
## Return a hash of hashes with bidirectional best hits for each gen
	my $RefBiBestHits=shift;
	my $RefBH1vs2=shift;
	my $RefBH2vs1=shift;
	my $count=0;
	for my $gen (keys %$RefBH1vs2) {
			my $hit=$RefBH1vs2->{$gen}[1];
			if($hit and( exists $RefBH2vs1->{$hit})) {
				if(exists $RefBH2vs1->{$hit}[1] and $gen eq $RefBH2vs1->{$hit}[1]) {
					$RefBiBestHits->{$gen}=$hit;
					# print " BBH $gen <=> $hit , $RefBiBestHits->{$gen}=$hit\n";
					$count++;
					}
				}
	}}
#__________________________________________________________________________________________________
