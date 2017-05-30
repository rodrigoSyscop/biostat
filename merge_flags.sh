#!/bin/bash
set -x
# you should run this script into the same
# directory that flagstat files are

# example of idx file: 35296_GC_Arun4_sorted_flag.txt

# for each flagstat generated file
for flag_file in $(ls *_sorted_flag.txt);do
    echo "Working on $flag_file"
    index_genome=$(basename $flag_file)
    index_genome=$(echo $index_genome |cut -d'_' -f1-3) # 228_GC_Arun4_sorted_flag
    genome=$(echo $index_genome |cut -d'_' -f2-3) # 228_GC_Arun4_sorted

    # for each line in each flagstat file
    echo "${index_genome}_sorted" >> $genome.merged_flagstats.txt
    
    while read line;do
        echo -n ",$line" >> $genome.merged_flagstats.txt
    done < $flag_file
    echo -en "\n" >> $genome.merged_flagstats.txt
done

echo "All set on $genome.merged_flagstats.txt"
