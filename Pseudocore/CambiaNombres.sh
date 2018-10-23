lista=$1
fasta=$2

cut -f2 ${lista} |while read line;do  id=$(grep -w $line ${lista}|cut -f1);echo ${id}; perl -p -i -e 's/'"$line"'\n/'"$id"'\n/' ${fasta};perl -p -i -e 's/'"$line"'_/'"$id"'_/' ${fasta} ; perl -p -i -e 's/'"$line"'\./'"$id"'\./' ${fasta}; done


