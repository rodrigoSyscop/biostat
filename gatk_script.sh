#!/bin/bash

#install GATK: https://software.broadinstitute.org/gatk/guide/quickstart
#install Picard: https://broadinstitute.github.io/picard/ , https://github.com/broadinstitute/picard/releases/tag/2.8.1

project=PVE_Eichh
prefix=/ohta/nicolay.cunha/all_samples_epan
picard=/ohta/nicolay.cunha/apps/picard.jar
gatk=/ohta/nicolay.cunha/apps/gatk/gatk.jar
names=/ohta/nicolay.cunha/all_samples_epan/names1
ref=/ohta/nicolay.cunha/epan/GC_Arun4.fa
tmp=/ohta/nicolay.cunha/tmp

mkdir -p ${tmp}

#TK: set hard paths as variables so you don't need to touch the script below this section


#TK: loop over names in a file...more reproducible
while read sample
do

#################
#PRE-PROCESSESING
#################
#note, from GATK: "begin by mapping the sequence reads to the reference genome to produce a file in SAM/BAM format sorted by coordinate. Next, we mark duplicates to mitigate biases introduced by dat
#a generation steps such as PCR amplification. Finally, we recalibrate the base quality scores, because the variant calling algorithms rely heavily on the quality scores assigned to the individual ba
#se calls in each sequence read."

#Sort and index
#TK: eichhornia alignments are already bam...shouldn't be keeping sams on the servers

samtools sort -l 9 -O bam -T ~/tmp -o ${prefix}/${sample}.sorted.bam ${prefix}/${sample}.bam >> ~/sort1.out 2>> ~/sort2.out

samtools index -b ${prefix}/${sample}.sorted.bam ${prefix}/${sample}.sorted.bam.bai >> ~/index1.out 2>> ~/index2.err

java -Djava.io.tmpdir=~/tmp -jar $picard AddOrReplaceReadGroups \
       INPUT=${prefix}/${sample}.sorted.bam \
       OUTPUT=${prefix}/${sample}.sorted.rg.bam \
       RGLB=DKCr \
       RGPL=Illumina \
       RGPU=unit1 \
       RGSM=${sample} \
       >> ~/RG.out 2>> ~/RG.err

samtools index -b ${prefix}/${sample}.sorted.rg.bam ${prefix}/${sample}.sorted.rg.bam.bai >> ~/index2.out 2>> ~/index2.err
java -Djava.io.tmpdir=~/tmp -jar $picard BuildBamIndex \
      I=${prefix}/${sample}.sorted.rg.bam

#Splits Cigars
java -Djava.io.tmpdir=~/tmp -jar $gatk -T SplitNCigarReads -R ${ref} -I ${prefix}/${sample}.sorted.rg.bam -o ${prefix}/${sample}.sorted.split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS >${sample}.sorted.split.out 2>${sample}.sorted.split.err

#Mark Duplicates & Index - this is the generalized command
java -Djava.io.tmpdir=~/tmp -jar $picard MarkDuplicates \
       I=${prefix}/${sample}.sorted.split.bam \
       O=${prefix}/${sample}.sorted.split.dedup.bam \
       M=${prefix}/${sample}.metrics.txt

java -Djava.io.tmpdir=~/tmp -jar $picard BuildBamIndex \
       INPUT=${prefix}/${sample}.sorted.split.dedup.bam

#I didn't recalibrate base quality scores but I think I probably should have ... (see link: https://software.broadinstitute.org/gatk/documentation/article?id=2801)
#TK: I didn't do this either

#generalized recalibration commands:

#creates a GATKReport file, Analyze patterns of covariation in the sequence dataset
#java -jar $gatk \
#    -T BaseRecalibrator \
#   -R ${ref} \
#    -I ${prefix}/${sample}.sorted.dedup.bam \
#    -L 20 \
#    -knownSites dbsnp.vcf \
#    -knownSites gold_indels.vcf \
#    -o recal_data.table
#analyze covariation remaining after recalibration
#java -jar $gatk \
#    -T BaseRecalibrator \
#    -R reference.fa \
#    -I realigned_reads.bam \
#    -L 20 \
#    -knownSites dbsnp.vcf \
##    -knownSites gold_indels.vcf \
#    -BQSR recal_data.table \
#    -o post_recal_data.table
# Generate before/after plots
#java -jar $gatk \
#    -T AnalyzeCovariates \
#    -R reference.fa \
#    -L 20 \
#    -before recal_data.table \
#    -after post_recal_data.table \
#    -plots recalibration_plots.pdf
#Apply the recalibration to your sequence data
#java -jar $gatk \
#    -T PrintReads \
#    -R reference.fa \
#    -I realigned_reads.bam \
#    -L 20 \
#    -BQSR recal_data.table \
#    -o recal_reads.bam


###################
#VARIANT DISCOVERY
###################

#Run haplotype caller with GVCF function
java -Djava.io.tmpdir=~/tmp -jar $gatk -T HaplotypeCaller -R ${ref} -I ${prefix}/${sample}.sorted.split.dedup.bam -dontUseSoftClippedBases -stand_call_conf 20.0 -o ${prefix}/${sample}.g.vcf -ERC GVCF >${prefix}/${sample}_hapl.out 2>${prefix}/${sample}_hapl.err


done < $names

#up until now running commands over a loop for each file, the next step joins all files into one.
#CombineGVCFs

all_variants=""
for variant in $(ls ${prefix}/*.g.vcf);do
    variant=$(basename $variant)
    all_variants="$all_variants --variant $v"
done


java -Djava.io.tmpdir=${tmp} -jar $gatk -T CombineGVCFs -R ${ref} ${all_variants} -o ${project}.g.vcf  > combgvcf.out 2> combgvcf.err

#GenotypeGVCF
java -Djava.io.tmpdir=${tmp} -jar $gatk -T GenotypeGVCFs -R ${ref} --variant ${project}.g.vcf --includeNonVariantSites -o ${project}_allsites.vcf

###########
#FILTERING VARIANTS 
###########
#see below for hard filtering
#filter by GQ
java -jar $gatk -R ${ref} -T VariantFiltration --variant ${project}.vcf -o ${project}_GQfilt.vcf --filterExpression 'QUAL<30.0' --FilterName 'lowGQ'  2> filtGQ.er

java -jar $gatk -T SelectVariants -R ${ref} -V ${project}_allsites_GQfilt.vcf -ef  -o ${project}_allsites_excludedGQ30.vcf
