#!/usr/bin/env Rscript

library(argparse)

parser <- ArgumentParser(description = "Process broomball stats into a season report...")
parser$add_argument("db", help = "the path to the broomball database")
parser$add_argument("year", help = "the path to the assay result directory", type = "integer")
parser$add_argument("season", help = "the path to the assay result directory", type = "integer")
parser$add_argument("-out", help = "the output file name")
args <- parser$parse_args()

argv <- commandArgs(trailingOnly = F)
path <- dirname(sub("--file=", "", argv[grep("^--file=", argv)]))
input <- file.path(path, "season.Rmd")

rmarkdown::render(input, output_file = args$out, params = args)
