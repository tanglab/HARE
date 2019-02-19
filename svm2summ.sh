#!/bin/bash
#-------------------------------------------------------------------------------
# This scripts is to find best parameter in SVM and calculate HARE for all individuals.
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
# CPU number
#BSUB -n 1
# Queue
#BSUB -q short
# CPU Time (hrs)
#BSUB -W 24:00
# MEM (MB)
#BSUB -R "rusage[mem=4000]"
#BSUB -M 8000
# LOG (output and error)
#BSUB -o logs/out_summ2
#BSUB -e logs/err_summ2
dir_work=.;
cd ${dir_work};
file_out=tmp/svm2raw.csv;
cat ${dir_work}/tmp/svm2/*.out > ${file_out};

Rscript svm2summ.R;
#-------------------------------------------------------------------------------
