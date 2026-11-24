library(tidyverse)


clinic <- read.csv("./data/metabric_clinical.csv", stringsAsFactors = TRUE)


genes <- read.csv("./data/metabric_genes.csv")


clilog <- clinic %>% select(age, tumor_size, lymph_nodes_positive,
                            grade, er_status, pr_status, her2_status, mutation_count)
