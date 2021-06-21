# Cleaning the table ----
rm(list = ls())
mainDir <- getwd()
Dir.Data <- file.path(mainDir, "Data")

# Packages ----
require(tidyverse)
require(circlize)

# df ----
min_df <- read.csv(file = file.path(Dir.Data, "Interac_lower.csv"))[,-1]
mean_df <- read.csv(file = file.path(Dir.Data, "Interac_mean.csv"))[,-1]
max_df <- read.csv(file = file.path(Dir.Data, "Interac_upper.csv"))[,-1]
uncertainty_df <- max_df - min_df

# chord diagram ----
min_df<-as.matrix(min_df)
rownames(min_df) = letters[1:5]
colnames(min_df) = letters[1:5]

chordDiagram(t(min_df))
title("Minimum interaction")

chordDiagram(min_df)
chordDiagram(as.matrix(mean_df))
chordDiagram(as.matrix(max_df))
chordDiagram(as.matrix(uncertainty_df))