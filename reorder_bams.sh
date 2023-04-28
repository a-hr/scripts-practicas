#!/bin/bash
: '
Re-sort by name .bam files.

Usage:
        bash reorder_bams.sh bams/
'

dir=$1
regex='.*/(.*).sortedByCoord.out.*'
mkdir sorted_bams

for file in $dir/*.bam
do
    [[ $file =~ $regex ]]
    file_prefix=${BASH_REMATCH[1]}
    samtools sort -n $file -o sorted_bams/$file_prefix.bam
done