#!/bin/bash

: '
Usage:
        bash align.sh index/ trimmed/ align_data/

Args:
        index_dir: directory containing the index generated with STAR
        file_input_dir: directory containing our .fastq files
        file_output_dir: directory to output files

Note: readFilesCommand unzips before aligning
'

index_dir=$1
file_input_dir=$2
file_output_dir=$3
regex='.*/(.[^_]*[0-9])_.*'

mkdir $file_output_dir # created if it does not exist

for file in $file_input_dir/*.f*q*
do
    echo -e "\nAligning $file" 
    [[ $file =~ $regex ]]
    file_prefix=${BASH_REMATCH[1]}

    STAR --genomeDir $index_dir \
    --runThreadN 20 \
    --readFilesIn $file \
    --readFilesCommand gunzip -c \
    --outFileNamePrefix $file_output_dir/$file_prefix \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMunmapped Within \
    --outSAMattributes Standard
done

mkdir bams
cp $file_output_dir/*.bam bams/
# rm -R $file_output_dir