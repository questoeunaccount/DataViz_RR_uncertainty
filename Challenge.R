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
## mean interaction----
mean_df<-as.matrix(mean_df)
rownames(mean_df) = letters[1:5]
colnames(mean_df) = letters[1:5]
mean_df<-t(mean_df)

grid.col = c(a = "yellow", b = "purple", c = "blue", d = "orange", e = "pink")

mean_df_2 = data.frame(from = rep(rownames(mean_df), times = ncol(mean_df)),
                to = rep(colnames(mean_df), each = nrow(mean_df)),
                value = as.vector(mean_df),
                stringsAsFactors = FALSE,
                )
mean_df_2 %<>% drop_na()

chordDiagram(mean_df_2, link.border = ifelse(mean_df_2$value > 0, "green", "red"), link.lwd = 2, link.lty = 2)
title("Chord Diagram of Interac_mean", cex = 0.6)

## Uncertainty ----
uncertainty_df<-as.matrix(uncertainty_df)

rownames(uncertainty_df) = letters[1:5]
colnames(uncertainty_df) = letters[1:5]
uncertainty_df<-t(uncertainty_df)

uncertainty_df_2 <- data.frame(from = rep(rownames(uncertainty_df), times = ncol(uncertainty_df)),
                       to = rep(colnames(uncertainty_df), each = nrow(uncertainty_df)),
                       value = as.vector(uncertainty_df),
                       stringsAsFactors = FALSE,
)
uncertainty_df_2 %<>% drop_na()

chordDiagram(uncertainty_df_2, link.border = ifelse(uncertainty_df_2$value > 0, "green", "red"), link.lwd = 2, link.lty = 2)
title("Chord Diagram of Uncertainty", cex = 0.6)
