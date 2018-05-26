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
my $old=$ARGV[0]; ## Fasta file with genomes already on the database
my $new=$ARGV[1]; ## Fasta file with new genome ids (To introduce on the database)

open(NEW,$new) or die "Couldnt open $new\n";
open(OLD,$old) or die "Couldnt open $old\n";

my @oldies;
my @news;

foreach my $oldie (<OLD>){
	chomp $oldie;
	push(@oldies,$oldie);
	}

foreach my $newbie (<NEW>){
	chomp $newbie;
	push (@news,$newbie);
	}
close OLD; close NEW;

my @union=(@news,@oldies);

foreach my $newbie (@news) {
	if(-e "$newbie\.faa"){	
		`makeblastdb -in $newbie\.faa -dbtype prot -out $newbie\.db`;
		}
	else {
		print "ERROR $newbie.faa no existe\n";
		exit;
		}
	}

foreach my $newbie (@news) {
	foreach my $other (@union){
		if(-e "$newbie\.faa" and -e "$other\.faa"){	
			`blastp -db $newbie\.db -query $other\.faa -outfmt 6 -evalue $e -num_threads 4 -out $other\_vs\_$newbie.blast`;
			`blastp -db $other\.db -query $newbie\.faa -outfmt 6 -evalue $e -num_threads 4 -out $newbie\_vs\_$other.blast`;
			}
		}
	}
#__________________________________________________________________________________________________
