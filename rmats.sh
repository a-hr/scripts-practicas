#!/bin/bash

group1=$1 # txt
group2=$2
gtf=$3
strand=$4

mkdir output_novel
mkdir tmp

python /dipc/blazquL/.conda/envs/rmats_410/rMATS/rmats.py --b1 $group1 --b2 $group2 \
--gtf $gtf --nthread 12 --cstat 0.005 --od output --tmp tmp --libType $strand --novelSS
--bi ../../../index1 \
-t paired --readLength 100 \

rm -R tmp