#!/bin/bash

' : 
usage: 
    bash script.sh index_dir/ output_dir/ sample_file

e.g.:
    bash get_orientation.sh index/ ref/ trimmed/SRR1645060_trimmed.fq.gz 

'

gDir=$1
ref_genome_dir=$2
sample=$3

# sample the sequences
mkdir tmp
mkdir out
zcat $sample | head -n 1000000 > tmp/sample.fq

# align to index ref
STAR --runThreadN 8 --genomeDir $gDir \
--readFilesIn tmp/sample.fq \
--outFileNamePrefix out/get_orientation \
--outSAMunmapped Within \
--outFilterType BySJout \
--outSAMattributes NH HI AS NM MD \
--outFilterMultimapNmax 20 \
--outFilterMismatchNmax 999 \
--outFilterMismatchNoverReadLmax 0.04 \
--alignIntronMin 20 \
--alignIntronMax 1000000 \
--alignMatesGapMax 1000000 \
--alignSJoverhangMin 8 \
--alignSJDBoverhangMin 1 \
--sjdbScore 1 \
--outSAMtype BAM SortedByCoordinate

# convert .gtf to .bam
annot_file_name=$(basename $(find $ref_genome_dir/*.gtf) .gtf)
cat  $ref_genome_dir/$annot_file_name.gtf | grep transcript_id | grep gene_id | convert2bed --do-not-sort --input=gtf - > $ref_genome_dir/$annot_file_name.bed

# get orientation based on STAR output
infer_experiment.py -i $(find out/*sortedByCoord.out.bam) -r $(find $ref_genome_dir/*.bed)

# clear temporal dirs
rm -R tmp/
rm -R out/