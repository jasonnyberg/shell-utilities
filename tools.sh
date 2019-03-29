#!/bin/bash

vitools() { vi ~/Tools/$1.sh; source ~/Tools/$1.sh; }
lstools() { grep "()" ~/Tools/${1:-*}.sh; }
showtools() { cat ~/Tools/${1:-*}.sh; }

tools() { for script in ~/Tools/*.sh; do source $script; done; }

seq() { echo -n $1; for (( X=$(($1+1)); $X<=$2; X=$X+1 )); do echo -n ",$X"; done; }
