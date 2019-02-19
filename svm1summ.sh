#!/bin/bash
#-------------------------------------------------------------------------------
# This script is to generate parameters for 2nd 5-fold cross validation.
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
# CPU number
#BSUB -n 1
# Queue
#BSUB -q short
# CPU Time (hrs)
#BSUB -W 01:00
# MEM (MB)
#BSUB -R "rusage[mem=1000]"
#BSUB -M 2000
# LOG (output and error)
#BSUB -o logs/out_summ1
#BSUB -e logs/err_summ1

dir_work=.;
cd ${dir_work};
file_out=tmp/svm1raw.csv;
cat ${dir_work}/tmp/svm1/*.out > ${file_out};
# generate parameters used in 2nd cross validation
R --vanilla << RCmdHere
n_fold <- 5;
step1st <- c(4, 3);
step2nd <- c(1, 1);
dir_tmp <- "tmp/";
file_out <- paste0(dir_tmp, "svm1raw.csv");
file_para2 <- paste0(dir_tmp, "para2.csv");
file_1aggr <- paste0(dir_tmp, "summ1.csv");

acc1 <- read.table(file_out, head = F, sep = ",");
acc1aggr <- aggregate(acc1[, 5], by = list(acc1[, 1], acc1[, 2]), FUN = sum);
best1 <- which.max(acc1aggr[, 3])[1];
gamma2 <- seq(acc1aggr[best1, 1] - step1st[1], acc1aggr[best1, 1] + step1st[1], by = step2nd[1]);
cost2 <- seq(acc1aggr[best1, 2] - step1st[2], acc1aggr[best1, 2] + step1st[2], by = step2nd[2]);
para2 <- cbind(rep(gamma2, each = n_fold), rep(cost2, each = length(gamma2) * n_fold), rep(1:n_fold, length(gamma2) * length(cost2)), 0);
key1 <- paste0(acc1aggr[,1], ":", acc1aggr[,2]);
key2 <- paste0(para2[,1], ":", para2[,2]);
para2[key2 %in% key1, 4] <- 1;
para2 <- para2[order(para2[, 4]), ];
write.table(para2, file = file_para2, sep = ",", quote = F, row.names = F, col.names = F);
write.table(acc1aggr, file = file_1aggr, sep = ",", quote = F, row.names = F, col.names = F);
RCmdHere
