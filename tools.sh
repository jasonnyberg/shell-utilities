#!/bin/bash

tools() { . ~/tools; }
vitools() { vi ~/tools.d/$1.sh; }
lstools() { grep "()" ~/tools.d/${1:-*}.sh; }
showtools() { cat ~/tools.d/${1:-*}.sh; }

for script in ~/tools.d/*.sh; do source $script; done
