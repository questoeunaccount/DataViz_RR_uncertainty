rm(list = ls())
mainDir <- getwd()
Dir.Data <- file.path(mainDir, "Data")

min_df <- read.csv(file = file.path(Dir.Data, "Interac_lower.csv"))[,-1]
mean_df <- read.csv(file = file.path(Dir.Data, "Interac_mean.csv"))[,-1]
max_df <- read.csv(file = file.path(Dir.Data, "Interac_upper.csv"))[,-1]

uncertainty_df <- max_df - min_df
