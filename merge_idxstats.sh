#!/bin/bash
#
# you should run this script into the same
# directory that idxstats files are

# example of idx file: 228_GC_Arun4_sorted.txt

# for each idxstats generated file
for idx_file in $(ls *_sorted.txt);do
    echo "Working on $idx_file"
    index_genome=$(basename $idx_file)
    index_genome=$(echo $index_genome |cut -d'.' -f1)
    genome=$(echo $index_genome |cut -d'_' -f2,3)
    
    # for each line in each idxstats file
    for line in $(cat $idx_file);do
        echo "$index_genome $line" >> $genome.merged_idxstats.txt
    done
done
