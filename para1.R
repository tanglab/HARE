#!/bin/env Rscript
#-------------------------------------------------------------------------------
# This script is to generate a list for (gamma, cost, id_fold, index_used). Column "index_used" is to indicate whether the combination (gamma, cost, id_fold) has been used (index_used = 1) or not (index_used = 0).
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
file_para1 <- "tmp/para1.csv";
n_fold <- 5;
step1st <- c(4, 3);
gamma1 <- seq(-12, 4, by = step1st[1]);
cost1 <- seq(-3, 12, by = step1st[2]);
para1 <- cbind(gamma = rep(gamma1, each = n_fold), cost = rep(cost1, each = length(gamma1) * n_fold), id_fold = rep(1:n_fold, length(gamma1) * length(cost1)), index_used = 0);
write.table(para1, file = file_para1, sep = ",", quote = F, row.names = F, col.names = F);
#-------------------------------------------------------------------------------
quit("no");
