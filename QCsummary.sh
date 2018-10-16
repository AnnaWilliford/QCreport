#!/bin/bash

########################################################################
#
# Script Name: QCsummary.sh
#
# Author: Anna Williford
#
# Date: 15/10/2018
#
# Description:
#			This script uses FastQC, fqtools, Nozzle.R1 R package and in-house Rscripts to generate report
#			with basic quality metrics for every fastq file in a given folder called 'Data_1', for example.
#			All outputs are written to 'Data_1_FastQC_out' folder that is created in the directory that
#			contains a folder with input fastq.gz files('Data_1').
#			'Data_1_FastQC_out' folder contains 'FastqReports' folder with QCreport.html for easy viewing of the results. 
#
# Usage: script.sh NameOfFolderWithFastq  #example: ./QCsummary.sh Data_1
#
# Software required to run this script:
#			fastqc: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
#			fqtools: https://github.com/alastair-droop/fqtools
#			R: https://cran.r-project.org/
#			R Nozzle package: https://cran.rstudio.com/web/packages/Nozzle.R1/index.html 
#
########################################################################

FASTQ_DIR=$1  

OUT_DIR=$FASTQ_DIR"_FastQC_out"
mkdir -p $OUT_DIR

#--------- get QC metrics -------------

echo -e "FileName\tReadCount\tPercentDistinctReads\tReadLength\tQ30" > $OUT_DIR/Summary.txt 

for file in $FASTQ_DIR/*fastq.gz
	do
		
        file_base=$(basename -s .fastq.gz $file) 

		#run fastqc on each file
		fastqc $file --extract --outdir=$OUT_DIR
		totalReads=$(grep '^Total Sequences' $OUT_DIR/$file_base"_fastqc"/fastqc_data.txt |awk '{print $3}')
		collapsedReads=$(grep '^#Total Deduplicated Percentage' $OUT_DIR/$file_base"_fastqc"/fastqc_data.txt |awk '{print substr ($4, 1, 4)}')
        seqLength=$(grep '^Sequence length' $OUT_DIR/$file_base"_fastqc"/fastqc_data.txt |awk '{print $3}')

		#get distribution of quality scores and Q30
		fqtools qualtab $file > $OUT_DIR/$file_base.qual.tab		
        Rscript GetQ30.R $OUT_DIR/$file_base.qual.tab  $OUT_DIR $file_base 
        
        Q30=$(cat $OUT_DIR/$file_base"_Q30".txt)

        echo -e "$(basename $file)\t$totalReads\t$collapsedReads\t$seqLength\t$Q30" >>$OUT_DIR/Summary.txt
				
done

#--------- rearrange output for writing report --------------

mkdir -p $OUT_DIR/QualityFig
cp $OUT_DIR/*Quality.png $OUT_DIR/QualityFig

mkdir -p $OUT_DIR/QualityPerPosFig
mkdir -p $OUT_DIR/DupLevelsFig

for file in $FASTQ_DIR/*fastq.gz
	do
        file_base=$(basename -s .fastq.gz $file) 
        cp $OUT_DIR/$file_base"_fastqc"/Images/per_base_quality.png $OUT_DIR/QualityPerPosFig/$file_base"_per_base_quality.png"
		cp $OUT_DIR/$file_base"_fastqc"/Images/duplication_levels.png $OUT_DIR/DupLevelsFig/$file_base"_duplication_levels.png"
done

#--------- remove unused files -----------
rm -r $OUT_DIR/*fastqc
rm $OUT_DIR/*tab
rm $OUT_DIR/*png
rm $OUT_DIR/*Q30.txt

#--------- write report ------------------

Rscript MakeNozzleReport.R $FASTQ_DIR $OUT_DIR

