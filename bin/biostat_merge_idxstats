#!/bin/bash
#
# you should run this script into the same
# directory that idxstats files are

# example of idx file: 228_GC_Arun4_sorted.txt

# for each idxstats generated file
for idx_file in $(ls *_sorted.txt);do
    echo "Working on $idx_file"
    index_genome=$(basename $idx_file)
    index_genome=$(echo $index_genome |cut -d'.' -f1) # should store: 230_GC_Arun4_sorted
    genome=$(echo $index_genome |cut -d'_' -f2,3) # # should store: GC_Arun4
    
    # check if output file already exists
    [ -f $genome.merged_idxstats.txt ] && echo "$genome.merged_idxstats.txt exists! Aborting..." && exit 1

    # for each line in each idxstats file
    while read line;do
        echo "$index_genome $line" >> $genome.merged_idxstats.txt
    done < $idx_file
done

echo "All set on $genome.merged_idxstats.txt"
