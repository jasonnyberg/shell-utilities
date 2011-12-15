#!/bin/bash
echo xml.sh

tag() { sed -ne "s:<$1>:\n&:gp" | sed -ne "s:<$1>\(.*\)</$1>.*:\1:gp"; }
pretty() { xmllint --format -; }


