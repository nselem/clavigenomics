
#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long 'HelpMessage';
###############################################3
#ask for perecentage n
#ask for file with RastIds
#usage  perl Familias.pl -p 80 -f archivo -i /home/nelly/clavigenomic
####################################################################

=head1 NAME
Familias - pass your inputs trough the command line!

=head1 SYNOPSIS 
  --percentage,n	Numero, el script seleccionara las familias con por lo presencia en por lo menos N% de los genomas
  --file,f		Archivo que contiene un rast id de genoma por linea
  --inpath,g		Directorio input debe contener txt files de cada rast id y blast files Gi_vs_Gj.blast para cada Gi rastId
=head1 VERSION
0.01
=cut

####################################################################################################
################       get options ##############################################################
GetOptions(
	'percentage=s' => \(my $percentage="0"),
        'file=s' => \(my $file="") ,
        'inpath=s' => \(my $inpath="") ,
	'help'     =>   sub { HelpMessage(0) },
       ) or HelpMessage(1);

open (FILE,"$file") or die "No pude abrir $file\n$!";
my $string="";
foreach my $id(<FILE>){
	chomp $id;
	$id=~s/\r//g;
	$string=$string."$id ";
	}

system("echo docker run --rm -i -t -v $inpath:/usr/src/CLAVIGENOMICS clavilocal makeFamiliesN.pl $percentage $string");
system("docker run --rm -i -t -v $inpath:/usr/src/CLAVIGENOMICS clavilocal makeFamiliesN.pl $percentage $string");
