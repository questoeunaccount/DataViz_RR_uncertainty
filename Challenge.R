# ####################################################################### #
# PROJECT: [Rostock Retreat on Visualising Uncertainty] 
# CONTENTS: IGraph-Based Network Visualisation
# AUTHOR: Erik Kusch
# EDIT: 21/06/2021
# ####################################################################### #
rm(list=ls())
set.seed(42)
####### PACKAGES ---------------------------------------------------------
#### Packages
install.load.package <- function(x) {
  if (!require(x, character.only = TRUE))
    install.packages(x, repos='http://cran.us.r-project.org')
  require(x, character.only = TRUE)
}
package_vec <- c(
  "tidyverse",
  # "igraph",
  "scales",
  # "colorspace",
  # "vioplot",
  # "snow",
  # "corrplot",
  # "writexl",
  "dagitty",
  "ggdag",
  # "tidygraph",
  # "ggraph",
  "visNetwork"
  
)
sapply(package_vec, install.load.package)

####### DIRECTORIES ---------------------------------------------------------
mainDir <- getwd()
Dir.Data <- file.path(mainDir, "Data")

####### FUNCTIONALITY ---------------------------------------------------------
`%nin%` <- Negate(`%in%`)

####### DATA LOADING ---------------------------------------------------------
min_df <- read.csv(file = file.path(Dir.Data, "Interac_lower.csv"))[,-1]
mean_df <- read.csv(file = file.path(Dir.Data, "Interac_mean.csv"))[,-1]
max_df <- read.csv(file = file.path(Dir.Data, "Interac_upper.csv"))[,-1]

####### DATA MANIPULATION ---------------------------------------------------------
uncertainty_df <- max_df - min_df
rownames(mean_df) <- colnames(mean_df)
rownames(uncertainty_df) <- colnames(mean_df)
Interactions_igraph <- data.frame(Actor = rep(colnames(mean_df), each = nrow(mean_df)),
                                  Subject = rep(rownames(mean_df), ncol(mean_df)),
                                  Estimate = as.vector(unlist(mean_df)),
                                  Uncertainty = as.vector(unlist(uncertainty_df))
)
Interactions_DAG <- Interactions_igraph
Interactions_DAG <- na.omit(Interactions_DAG)

####### PLOTTING ---------------------------------------------------------
opacity <- 1-Interactions_DAG$Uncertainty/abs(Interactions_DAG$Estimate) # alpha = 1-percentage of uncertainty to corresponding estimate; this is questionable because uncertainties now get treated differently depending on estimate of the effect they are associated with
opacity[opacity<.2] <- 0.2 # make all edges for which uncertainty is bigger than the effect (opacity < 0) or very large slightly visible

width <- abs(Interactions_DAG$Estimate)
width <- rescale(width, to = c(0.05, 1.2))
###. GGDAG ----
Dag_Paths <- paste(paste(Interactions_DAG$Actor, "->", Interactions_DAG$Subject), collapse = " ")
dag <- dagitty(x = paste0("dag {", Dag_Paths, "}"))
tidy_dag <- tidy_dagitty(dag)
tidy_dag$data$weight <- width
tidy_dag$data$label <- round(Interactions_DAG$Estimate, 2)
tidy_dag$data$colour <- ifelse(Interactions_DAG$Estimate > 0, "#009933", "#cc0000")
tidy_dag$data$alpha <- opacity
GGDAG_graph <- ggplot(tidy_dag, aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_dag_point(colour = "white") +
  geom_dag_text(colour = "black", size = 7) +
  theme_dag() + 
  geom_dag_edges_arc(aes(edge_colour = colour, 
                         edge_width = weight, 
                         # label = label,
                         edge_alpha = alpha
  ), 
  angle_calc = 'along', label_dodge = grid::unit(8, "points")) + 
  ggtitle("Network + Uncertainty")
ggsave(filename = "GGDAD.png", plot = GGDAG_graph, units = "cm", width = 12, height = 12)

###. VISNETWORTK ---- 
node_list <- tibble(id = unique(colnames(mean_df)))
node_list <- node_list %>%
  mutate(label = id)

edge_list <- tibble(from = Interactions_DAG$Actor, to = Interactions_DAG$Subject)
edge_list <- edge_list %>%
  add_column(width = width) %>%
  add_column(color.color = ifelse(Interactions_DAG$Estimate > 0, "#009933", "#cc0000")) %>%
  add_column(color.highlight = ifelse(Interactions_DAG$Estimate > 0, "#009933", "#cc0000")) %>%
  add_column(color.opacity = opacity)

VisNet_graph <- visNetwork(nodes = node_list, edges = edge_list, height = 1920) %>% 
  visIgraphLayout(layout = "layout_with_fr", randomSeed = 42) %>%
  visNodes(shape = "circle") %>%
  visEdges(arrows = "to", smooth = list(roundness = 0.3), color = list(opacity = opacity)) 
visSave(VisNet_graph, file = "VisNetwork.html", selfcontained = TRUE, background = "darkgrey")  

