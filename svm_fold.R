#!/bin/env Rscript
#-------------------------------------------------------------------------------
# This script is to run svm for a single fold.
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
require(e1071);
# input/input_sirePC.rdat has one data.frame "data_svm" including columns "IID", "sire", "PC1-30" and "index_fold".
load("input/input_sirePC.rdat");
class(data_svm) <- "data.frame";
# remove individuals with sire=NA
data_svm <- data_svm[!is.na(data_svm$sire), ];
data_svm$sire <- as.factor(data_svm$sire);
# arguments from command line: para_svm n_pcs file_out
args_cmd <- commandArgs(trailingOnly = T);
para_svm <- as.numeric(strsplit(args_cmd[1], ",")[[1]]);
# quit R if current parameter has been used before.
# para_svm = (gamma, cost, k_fold, index_used)
if(para_svm[4] > 0.5) {
    cat("The parameters have been used:\t", para_svm, ".\n", sep = ",");
    quit("no");
}
n_pcs <- as.integer(args_cmd[2]);
if(n_pcs < 1 || n_pcs > 30) {
    cat("The n_pcs is out of [1, 30].\n");
    quit("no");
}
file_out <- args_cmd[3];
fml_svm <- as.formula(paste0("sire~", paste0("PC", 1:n_pcs, collapse = "+")));
# training and testing data
index01_test <- data_svm$index_fold == para_svm[3];
mod_svm <- svm(fml_svm, data = data_svm[!index01_test, ], probability = F, fitted = F, kernel = "radial", type = "C-classification", gamma = 2^para_svm[1], cost = 2^para_svm[2]);
pred_test <- predict(mod_svm, newdata = data_svm[index01_test, paste0("PC", 1:n_pcs)], decision.values = F, probability = F);
prop_test <- sum(pred_test == data_svm$sire[index01_test]) / nrow(data_svm);
cat(para_svm, prop_test, "\n", sep = ",", file = file_out);
#-------------------------------------------------------------------------------
quit("no");
