#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (length(args) == 2) {
  v1 <- sapply(as.data.frame(strsplit(args[1], ",")), as.numeric)
  v2 <- sapply(as.data.frame(strsplit(args[2], ",")), as.numeric)
} else {
  stop("No data provided", call.=FALSE)
}

library(exactRankTests)

result <- wilcox.exact(v1,v2, paired = TRUE)

cat(result$p.value)