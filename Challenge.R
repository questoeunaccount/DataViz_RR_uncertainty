rm(list = ls())
mainDir <- getwd()
Dir.Data <- file.path(mainDir, "Data")

min_df <- read.csv(file = file.path(Dir.Data, "Interac_lower.csv"))
mean_df <- read.csv(file = file.path(Dir.Data, "Interac_mean.csv"))
max_df <- read.csv(file = file.path(Dir.Data, "Interac_upper.csv"))

uncertainty_df <- max_df - min_df
