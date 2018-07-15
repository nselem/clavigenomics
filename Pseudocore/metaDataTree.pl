#!/usr/bin/perl -I/usr/local/lib/perl5/site_perl/5.20.3
use SVG;
use strict;
use warnings;

###################################
system("rm /usr/src/CLAVIGENOMICS/*svg");

###### reading color and tree files
my $colorFile=$ARGV[0];
my %leaves=readColor($colorFile);
my $nClust=keys %leaves;
my $h=40*($nClust)+40; 	
#------------------------------------
my $treeFile=$ARGV[1]; 
my $sepHoja=40;
#my @SortLeaves=;
system("nw_topology -b -IL $treeFile | nw_display -S -b 'opacity:0'  -i ’font-size:8’ -v $sepHoja -s - >$treeFile.svg");
my $labels=`nw_labels -I $treeFile`;
my @SortLeaves=split(/\n/,$labels);


######## settings ######################
#my $w=2500; #ancho del canvas
my $w=1500; #ancho del canvas
my $t =400; # traslacion horizontal debida al arbol

############## create an SVG object with a size of 1200x$h pixels
my $svg = SVG->new(  width  => $w,	height => $h+150,onload=>'Init(evt)',onmousemove=>' GetTrueCoords(evt); 
			ShowTooltip(evt, true)',onmouseout=>'ShowTooltip(evt, false)');
my $tag = $svg->script(-type=>"text/ecmascript");

######## Main 
drawSquares($sepHoja,\%leaves,\@SortLeaves,$t);	



#####################################################################
##Html output (Sending files to firefox
#####################################################################
open (OUT, ">Metadata.svg") or die "Couldn't open Metadata.svg \n$!";
    # now render the SVG object, implicitly use svg namespace
print OUT $svg->xmlify;
close OUT;
	#system "firefox $file.svg";

`perl -p -i -e 'if(/\<polygon/)\{s/title=\"/\>\n\<title\>/g;if(m{\/\>\$})\{s{\" \/\>}{\<\/title\>\<\/polygon\>};\}\}else\{if((!/^\t/) and m{\/\>})\{s{\" \/>}{<\/title><\/polygon>};\}\}' Metadata.svg`;

my $file = "$treeFile.svg";
my $document2 = do {
    local $/ = undef;
    open my $fh, "<", $file
        or die "could not open $file: $!";
    <$fh>;
};

$file = "Metadata.svg";
my $document1_3 = do {
    local $/ = undef;
    open my $fh, "<", $file
        or die "could not open $file: $!";
    <$fh>;
};

my @parts=split(/<script\s*\/>/,$document1_3);

my @svg= split('<defs>',$document2);
$svg[1]=~s/<\/svg>//;

#print "################33";

my $joined=$parts[0]."<script \/>\n<defs>". $svg[1].$parts[1];

open (OUT, ">Joined.svg") or die "Couldn't open Joined.svg \n$!";
print OUT $joined;
close OUT;

################################## subs ###############################################
sub readColor{
	my $file=shift;
	my %leaves;

	open (COLORS,"$file") or die "No pude abrir el archivo de colores de metadatos\n";
	foreach my $line(<COLORS>){
		chomp $line;
#		print "$line\n";
#		my $pause=<STDIN>;
		my @st=split(/\t/,$line);
		my $key=shift @st;
		$leaves{$key}=join ("\t",@st);
		}

	close COLORS;
	return %leaves;
}

#-------------------------------------------------------------------------------
sub drawSquares{
	#my $refY=shift;
	my $sepHoja=shift;
	my $refleaves=shift;
	my $refSortLeaves=shift;
	my $t=shift;
	
	my @Y=@$refSortLeaves;	
	my %leaves=%{$refleaves};
	my $wSquare="20";
	#my $w=1500;
        my $w=500;	
	for (my $i=0;$i<@Y;$i++){ ##renglones
		my $top=20+$sepHoja*$i-$wSquare/2;
		my $down=$top+$wSquare/2;
		#print "$i\t$Y[$i]\t$leaves{$Y[$i]}\n";
		my @st=split(/\t/,$leaves{$Y[$i]});
		my $columnas=@st;
		$svg->text( x  => $t-80, y  => $down, style=>{'text-anchor'=>'start', 'font-size'=>'5',  'font-family'=>'Arial', 'font-style'=>'italic'})->cdata("$Y[$i]");
 
		for( my $j=0;$j<(@st-1);$j++){ ##columnas
			if($j%2==0){
				my $label=$st[$j+1];
				my $color=$st[$j];
				my $left=$t+$w*($j/($columnas));
				my $right=$left+$wSquare;
			#	print "[$left,$down\t$right,$down\t$right,$top\t$left,$top]\n";
				my $path = $svg->get_path(x => [$left, $left, $right,$right],   y => [$top,$down,$down,$top], -type => 'polygon');
       				$svg->polygon(  %$path,title=>"$label",style => {'fill'=> "#$color",'stroke' => '#$color', 'stroke-width' =>2,'stroke-opacity' =>  1,},);
			#	$svg->text( x  => $right+5, y  =>$down, style=>{'text-anchor'=>'start', 'font-size'=>'5',  'font-family'=>'Arial', 'font-style'=>'italic'})->cdata("$label"); 

			}
			} 
		}
	}

