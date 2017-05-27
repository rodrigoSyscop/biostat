#!/bin/bash

# required tools
BEDTOOLS=$(which bedtools)
SAMTOOLS=$(which samtools)

# default directories
SAMPLES_DIR="$HOME/data/eichh"
OUTPUT_DIR="$HOME/all_samples_epan"
# Task: to pair and to map all samples

## reference genome (full path)
GENOME_PATH="$HOME/epan/GC_Arun4.fa"

## that step is alrady done
## in case you need to redo it, comment out the block below

#cd $(dirname $GENOME_PATH)
#$BWA index $GENOME_PATH

# back to home
cd $HOME

# get ref_gen (extract "GC_Arun4" from ...epan/GC_Arun4.fa)
genome_basename=$(basename $GENOME_PATH)
genome_basename=$(echo $genome_basename|cut -d'.' -f1)

## for each sample (.fastq files):
for sample in $(ls $SAMPLES_DIR/*.fastq);do
    echo "working on $sample file"

    # get sample_index (extract "32066" from .../data/eichh/32066.fastq )
    sample_index=$(basename $sample)
    sample_index=$(echo $sample_index|cut -d'.' -f1)

    # we will going to use this name a lot
    index_genome="${sample_index}_GC_${genome_basename}"

    # generates sam file
    $BWA mem $GENOME_PATH $sample > $OUTPUT_DIR/${index_genome}.sam

    cd $OUTPUT_DIR

    # generates bam file
    $SAMTOOLS view -bhS ${index_genome}.sam > $OUTPUT_DIR/${index_genome}.bam

    # sorts bam file
    $SAMTOOLS sort ${index_genome}.bam > $OUTPUT_DIR/${index_genome}_sorted.bam

    # sample_index bam file
    $SAMTOOLS index $OUTPUT_DIR/${index_genome}_sorted.bam

    # extract some statistics
    $SAMTOOLS idxstats $OUTPUT_DIR/${index_genome}_sorted.bam > $OUTPUT_DIR/${index_genome}_sorted.txt
    $SAMTOOLS flagstat $OUTPUT_DIR/${index_genome}_sorted.bam > $OUTPUT_DIR/${index_genome}_sorted_flag.bam

done
