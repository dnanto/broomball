#!/usr/bin/env Rscript

args <- commandArgs()
root <- dirname(sub("^--file=", "", args[grep("^--file=", args)]))

args <- commandArgs(trailingOnly = T)
path <- args[1]

input <- file.path(root, "season.Rmd")

rmarkdown::render(input, params = list(path = path))
