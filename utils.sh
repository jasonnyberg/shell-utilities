row2col() { sed -e "s/[ \n\t]\+/ /g" | tr ' ' '\n'; }
col2row() { sed -e "s/[ \t]\+/ /g" | cut -d' ' -f $1 | tr '\n' ' '; echo; }
plot_cols() { gnuplot -p -e "set key outside; plot for [col=1:$2:1] \"$1\" using col with lines title columnheader"; }
 
rrm() { rm -rf $1; chmod -R 777 $1; rm -rf $1; }
