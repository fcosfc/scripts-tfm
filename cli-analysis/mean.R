#!/usr/bin/env Rscript
#
# -------------------------------------------------
# mean.R: script para cálculo de medias aritméticas
#
# author: Paco Saucedo.
# -------------------------------------------------

args = commandArgs(trailingOnly=TRUE)
if (length(args) == 1) {
  v1 <- sapply(as.data.frame(strsplit(args[1], ",")), as.numeric)
} else {
  stop("No data provided", call.=FALSE)
}

m <- mean(v1)

cat(m)