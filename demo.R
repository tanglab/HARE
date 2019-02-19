#!/bin/env Rscript
#-------------------------------------------------------------------------------
# This script is to generate the file "input/input_sirePC.rdat" from demo data "input/pop1_30pcs.txt" and "input/pop1_sire.txt." "input/input_sirePC.rdat" contains a data.frame "data_svm" that includes columns "IID", "sire", "PC1-30", and "index_fold" that is individuals' fold indexes in the following cross validations.
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190218
#-------------------------------------------------------------------------------
set.seed(20190218);
n_fold <- 5;
data_svm <- read.table("input/pop1_30pcs.txt", head = T);
data_sire <- read.table("input/pop1_sire.txt", head = T);
data_svm <- merge(data_svm, data_sire, by = "IID", all.x = T, sort = F);
data_svm$index_fold <- NA;
data_svm$index_fold[!is.na(data_svm$sire)] <- sample(1:n_fold, sum(!is.na(data_svm$sire)), replace = T);
save(data_svm, file = "input/input_sirePC.rdat");
#-------------------------------------------------------------------------------
quit("no");
