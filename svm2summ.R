#!/bin/env Rscript
#-------------------------------------------------------------------------------
# This script is to find best parameter from cross validation, train/predict SVM for all individuals, and calculate HARE.
# Contact: Huaying Fang (hyfang@stanford.edu)
# Date: 20190213
#-------------------------------------------------------------------------------
require(e1071);
n_pcs <- 30;
dir_tmp <- "tmp/";
file_out=paste0(dir_tmp, "svm2raw.csv");
file_1aggr <- paste0(dir_tmp, "summ1.csv");
file_2aggr <- paste0(dir_tmp, "summ2.csv");
# threshold for P1/Psire
thr_has_sire <- 40;
# threshold for P1/P2
thr_no_sire <- 20;
dir_output <- "output/";
file_hare <- paste0(dir_output, "HARE_output.txt");
file_rdat <- paste0(dir_output, "HARE_output.rdat");
# data/data_svm.rdat has one data.frame "data_svm" including columns "IID", "sire", "PC1-30" and "index_fold".
load("input/input_sirePC.rdat");
class(data_svm) <- "data.frame";
has_sire <- !is.na(data_svm$sire);
data_svm$sire <- as.factor(data_svm$sire);
fml_svm <- as.formula(paste0("sire~", paste0("PC", 1:n_pcs, collapse = "+")));

# best parameter from cross validation
acc1aggr <- read.table(file_1aggr, head = F, sep = ",");
best1 <- which.max(acc1aggr[, 3]);
acc2 <- read.table(file_out, head = F, sep = ",");
acc2aggr <- aggregate(acc2[, 5], by = list(acc2[, 1], acc2[, 2]), FUN = sum);
best2 <- which.max(acc2aggr[, 3]);
names(acc1aggr) <- names(acc2aggr);
acc_aggr <- rbind(acc1aggr, acc2aggr);
para_best <- unlist(acc_aggr[which.max(acc_aggr[, 3])[1], ]);
acc_aggr[, 4] <- 2;
acc_aggr[1:nrow(acc1aggr), 4] <- 1;
write.table(acc_aggr, file = file_2aggr, sep = ",", quote = F, row.names = F, col.names = F);

# svm for all individuals with sire
mod_svm <- svm(fml_svm, data = data_svm[has_sire, ], probability = T, fitted = T, kernel = "radial", type = "C-classification", gamma = 2^para_best[1], cost = 2^para_best[2]);
pred_svm <- predict(mod_svm, newdata = data_svm[, paste0("PC", 1:n_pcs)], decision.values = T, probability = T);
# calculate P1/P2 and P1/Psire
data_svm$sire <- as.character(data_svm$sire);
prob_pred <- attr(pred_svm, "probabilities");
P1P2Psire <- data.frame(t(sapply(1:nrow(prob_pred), function(k) {
	x1 <- sort(prob_pred[k, ], decreasing = T);
	P1Psire <- ifelse(has_sire[k], x1[1]/max(x1[data_svm$sire[k]], 1e-6), NA);
	return(c(x1[1]/max(x1[2], 1e-6), P1Psire, names(x1)[1]));
})), stringsAsFactors = F);
names(P1P2Psire) <- c("P1P2", "P1Psire", "L1");
for(k in 1:2) P1P2Psire[[k]] <- as.numeric(P1P2Psire[[k]]);

# assign hare for all individuals
data_hare <- data.frame(IID = data_svm$IID, sire = data_svm$sire, hare = NA, stringsAsFactors = F);
# HARE = SIRE for individuals with sire and P1/Psire <= thr_has_sire
idtmp0 <- has_sire & P1P2Psire$P1Psire <= thr_has_sire;
data_hare$hare[idtmp0] <- data_hare$sire[idtmp0];
# HARE = L1 for individuals without sire and P1/P2 > thr_no_sire
idtmp0 <- !has_sire & P1P2Psire$P1P2 > thr_no_sire;
data_hare$hare[idtmp0] <- P1P2Psire$L1[idtmp0];

# save results
write.table(data_hare, file = file_hare, sep = ",", quote = F, row.names = F, col.names = T);
save(mod_svm, pred_svm, P1P2Psire, data_hare, file = file_rdat);
#-------------------------------------------------------------------------------
quit("no");
