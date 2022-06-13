#!/bin/bash 

sP=$1
sI=$2
tP=$3
oF=$4

cat $sP > $oF

grep ">" $tP | cut -d ">" -f2 | grep -f - $sI | awk '{if ($2 == "OTHER") print}' | cut -f1 | seqkit grep --pattern-file - $tP >> $oF 
