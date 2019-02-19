#!/bin/bash
#-------------------------------------------------------------------------------
# This script is to submit jobs via LSF system.
# Only one file "data/data_svm.rdat" are needed that includes one data.frame "data_svm" including columns "IID", "sire", "PC1-30" and "index_fold."
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
# Create temporary and output folder
[ -d tmp ] || mkdir tmp;
[ -d output ] || mkdir ouput;
# 1. Generate parameters for 1st 5-fold cross validation.
[ -f tmp/para1.csv ] || Rscript para1.R;
# 2. Run 150 jobs (5 fold x (5 x 6) parameters) for 1st 5-fold cross validation.
bsub -J "svm1[1-150]" < svm_fold.sh;
# 3. Calculate prediction accuracy via aggregating 5 folds for 1st 5-fold cross validation.
bsub -w "ended(svm1[1-150])" -J "summ1" < svm1summ.sh;
# 4. Run 315 jobs (5 fold x (9 x 7) parameters) for 2nd 5-fold cross validation.
bsub -w "ended(summ1)" -J "svm2[1-315]" < svm_fold.sh;
# 5. Find best parameters in 5-fold cross validation and calculate HARE for all individuals.
bsub -w "ended(svm2[1-315])" -J "summ2" < svm2summ.sh;

