#!/bin/bash
#-------------------------------------------------------------------------------
# The script is to run svm for a single fold.
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
# CPU number
#BSUB -n 1
# Queue
#BSUB -q short
# CPU Time (hrs)
#BSUB -W 06:00
# MEM (MB)
#BSUB -R "rusage[mem=1200]"
#BSUB -M 2000
# LOG (output and error)
#BSUB -o logs/out_%J_%I
#BSUB -e logs/err_%J_%I
# test environment
#k_run=$1;
#index_job=$2;
# job name should be svm1XXX or svm2XXX, and k_run=1 for 1st or 2 for 2nd 5-fold CV)
k_run=${LSB_JOBNAME:3:1};
# job index are one number from 1 to N (N is the total array job counts.)
index_job=${LSB_JOBINDEX};
# work directory
dir_work=.;
# pcs used
n_pcs=30;

cd ${dir_work};
dir_out=tmp/svm${k_run};
file_para_svm=tmp/para${k_run}.csv;
[ -d ${dir_out} ] || mkdir -p ${dir_out};
out_file=${dir_out}/${index_job}.out;
para_svm=$(awk -F, "NR==${index_job}" ${file_para_svm});

Rscript svm_fold.R ${para_svm} ${n_pcs} ${out_file};
#-------------------------------------------------------------------------------
