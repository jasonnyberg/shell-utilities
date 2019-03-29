#!/bin/bash

# Copyright (c) 2011 Jason Nyberg <jasonnyberg@gmail.com>
#
# Requires cscope; compatibility with various cscope versions not guaranteed.
# Graphviz is also very useful but there are situations where command-line alone is useful
#
# These shell functions simply dump applicable function names as advertised in comments:
#
#   all_callers all_callees common_callers common_callees call_graph call_leaks all_callerees*
# 
# ...And graphviz/dot-based graphical versions:
#
#   upstream downstream cupstream cdownstream relate leaks upndown**
#
# *no graphical equivalent
# **no text equivalent
#
# Several "viewer" options are provided for the graphical shell functions, "ctviewer" wraps the one you prefer.

echo calltree.sh

#use cscope to build reference files (./cscope.out by default, use set_graphdb to override name or location)
set_graphdb() { export GRAPHDB=$1; }
unset_graphdb() { unset GRAPHDB; }
build_graphdb() { cscope -bkRu ${GRAPHDB:+-f $GRAPHDB} && echo Created ${GRAPHDB:-cscope.out}...; }

# cscope queries
lsyms() { cscope ${GRAPHDB:+-f $GRAPHDB} -L0 $1 | grep -v "<global>" | grep "="; }
fdefine() { cscope ${GRAPHDB:+-f $GRAPHDB} -L1 $1; }
callees() { cscope ${GRAPHDB:+-f $GRAPHDB} -L2 $1; }
callers() { cscope ${GRAPHDB:+-f $GRAPHDB} -L3 $1; }

# show which functions refer to a set of symbols
filter_syms() { local sym cscope_line
    while read -a sym; do
        lsyms $sym | while read -a cscope_line; do
            printf "${cscope_line[1]}\n"
        done
    done
}

# given a set of function names, find out how they're related
filter_edges() { local sym cscope_line
    while read -a sym; do
        fdefine $sym | while read -a cscope_line; do
            grep -wq ${cscope_line[1]} ${1:-<(echo)} &&
            printf "${cscope_line[1]}\t[href=\"${cscope_line[0]}:${cscope_line[2]}\"]\t/*fdefine*/\n"
        done
        callees $sym | while read -a cscope_line; do
            grep -wq ${cscope_line[1]} ${1:-<(echo)} &&
            printf "$sym->${cscope_line[1]}\t[label=\"${cscope_line[0]}:${cscope_line[2]}\"]\t/*callee*/\n"
        done
        callers $sym | while read -a cscope_line; do
            grep -wq ${cscope_line[1]} ${1:-<(echo)} &&
            printf "${cscope_line[1]}->$sym\t[label=\"${cscope_line[0]}:${cscope_line[2]}\"]\t/*caller*/\n"
        done
    done
}

# dump args one-per-line
largs() { for a; do echo $a; done; }
toargs() { local symbol
    while read -a symbol; do
        printf "%s " $symbol
    done
    echo
}

# present list of symbols to filter_syms properly
refs() { local tfile=/tmp/refs.$RANDOM
    cat ${1:+<(largs $@)} > $tfile
    filter_syms $tfile <$tfile | sort -u
    rm $tfile
}

# present list of function names to filter_edges properly
edges() { local tfile=/tmp/edges.$RANDOM
    cat ${1:+<(largs $@)} > $tfile
    filter_edges $tfile <$tfile
    rm $tfile
}

# append unknown symbol names out of lines of cscope output
filter_cscope_lines() { local cscope_line
    while read -a cscope_line; do
        grep -wq ${cscope_line[1]} ${1:-/dev/null} || echo ${cscope_line[1]}
    done 
}

# given a set of function names piped in, help spit out all their callers or callees that aren't already in the set
descend() { local symbol
    while read -a symbol; do
        $1 $symbol | filter_cscope_lines $2
    done
}

# discover functions upstream of initial set
all_callers() { local tfile=/tmp/all_callers.$RANDOM
    cat ${1:+<(largs $@)} > $tfile
    descend callers $tfile <$tfile >>$tfile
    sort -u $tfile; rm $tfile
}

# discover functions downstream of initial set
all_callees() { local tfile=/tmp/all_callees.$RANDOM
    cat ${1:+<(largs $@)} > $tfile
    descend callees $tfile <$tfile >>$tfile
    sort -u $tfile; rm $tfile
}

# discover common callers of two functions
common_callers() { local tfile=/tmp/subgraph.$RANDOM;
    all_callers $1 > $tfile
    comm -12 $tfile <(all_callers $2)
    rm $tfile
}

# discover common callees of two functions
common_callees() { local tfile=/tmp/subgraph.$RANDOM;
    all_callees $1 > $tfile
    comm -12 $tfile <(all_callees $2)
    rm $tfile
}

# all the ways to get from (a,b,...z) to (a,b,...z), i.e. intersect all_callers and all_callees of initial set
call_graph() { local tfile=/tmp/subgraph.$RANDOM; local args=/tmp/subgraph_args.$RANDOM
    cat ${1:+<(largs $@)} > $args
    cat $args | all_callers > $tfile
    comm -12 $tfile <(cat $args | all_callees)
    rm $tfile $args
}

# all functions downstream of callers of argument
all_callerees() { callers $1 | filter_cscope_lines | all_callees; }

# odd experimental set of calls that might help spot potential memory leaks
call_leaks() { local tfile=/tmp/graph_filter.$RANDOM
    all_callerees $1 > $tfile
    comm -2 $tfile <(all_callers $2)
    rm $tfile
}

# wrap dot-format node and edge info with dot-format whole-graph description
graph() { printf "digraph iftree {\ngraph [\n rankdir=LR,\n ratio=compress,\n concentrate=true\n];\nnode [shape=record, style=filled]\nedge [color="navy"];\n"; cat | sort -u; printf "}\n"; }

# filter out unwanted (as specified in “~/calltree.deny”) and/or unnecessary edges
graph_filter() { local tfile=/tmp/graph_filter.$RANDOM
    cat > $tfile
    grep fdefine $tfile
    grep $1 $tfile | grep -vf ~/calltree.deny | cut -f1,3
    rm $tfile
}

# how to invoke zgrviewer as a viewer
zgrviewer() { ~/Downloads/zgrviewer/run.sh -Pdot $@; }
# how to invoke xfig as a viewer
figviewer() { xfig <(dot -Tfig $@); }
# how to create and view a png image
pngviewer() { dot -Tpng $@ -o /tmp/ct.png && gqview -t /tmp/ct.png; }

# specify a viewer
ctviewer() { zgrviewer -opengl -volatile $@; }

# cut&paste viewer
ctview() { cat | graph > /tmp/tfile; ctviewer /tmp/tfile; }

# add color to specified nodes
colornodes() { (cat; for x in $@; do echo "$x [color=red]"; done;) }

# generate dot files
_upstream() { all_callers $@ | edges | graph_filter caller | colornodes $@ | graph; }
_downstream() { all_callees $@ | edges | graph_filter callee | colornodes $@ | graph; }
_upndown() { (all_callers $@; all_callees $@) | edges | graph_filter callee | colornodes $@ | graph; }
_relate() { call_graph $@ | edges | graph_filter callee | colornodes $@ | graph; }
_leaks() { call_leaks $1 $2 | edges | graph_filter callee | colornodes $1 $2 | graph; }
_cupstream() { common_callers $1 $2 | edges | graph_filter caller | colornodes $1 $2 | graph; }
_cdownstream() { common_callees $1 $2 | edges | graph_filter callee | colornodes $1 $2 | graph; }

# generate dot files and invoke ctviewer
upstream() { _upstream $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }
downstream() { _downstream $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }
upndown() { _upndown $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }
relate() { _relate $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }
leaks() { _leaks $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }
cupstream() { _cupstream $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }
cdownstream() { _cdownstream $@ > /tmp/tfile; ctviewer /tmp/tfile; rm -f /tmp/tfile; }

# dot file conversions
dot2png() { dot -s36 -Tpng -o $1; }
dot2jpg() { dot -Tjpg -o $1; }
dot2html() { dot -Tpng -o $1.png -Tcmapx -o $1.map; (echo "<IMG SRC="$1.png" USEMAP="#iftree" />"; cat $1.map)  > $1.html; }

