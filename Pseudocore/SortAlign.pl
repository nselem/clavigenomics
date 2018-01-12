my $nombre=$ARGV[0];

open(FILE2,$nombre)or die "Couldnt open $nombre $!\n";

#print("Se abrio el archivo $nombre\n");

my @content=<FILE2>;

my $headerFasta;

my $clust;

my %hashFastaH;


foreach my $line (@content){

	#print" $line";

	if($line =~ />/){
                                chomp $line;
                                $headerFasta=$line;
                                $clust=$line;

			chomp $clust;
                        
$clust=~s/>\d*_//g; #Obtengo el indicador del cluster
                                $hashFastaH{$clust}=$headerFasta."\n";;
                        }
                        else{
                               # $line =~ s/\*//g;

			if(! -exists $hashFastaH{$clust}){$hashFastaH{$clust}="";}

		#	push(@sorted_clusters,$clust);
                                $hashFastaH{$clust}=$hashFastaH{$clust}.$line;
                                #print"$headerFasta => $hashFastaH{$headerFasta}\n";

                        }



}



open ORDEN,">$nombre.orden.muscle" or die $!;


 foreach my $key (sort{$a<=>$b} keys %hashFastaH ){

	print ORDEN "$hashFastaH{$key}";

}

close ORDEN;

#print @content;  ### Anaaa que eran las opciones del Gblocks??

system "Gblocks $nombre.orden.muscle -b4=5 -b5=n -b3=5";

system("rm $nombre.orden.muscle-gb.htm");

close(FILE2);
