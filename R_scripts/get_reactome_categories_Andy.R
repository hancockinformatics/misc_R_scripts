
# This script was written by Andy, and tidied/tweaked by Travis on 20210617


# Load packages -----------------------------------------------------------

library(httr)
library(tidyverse)


# Define main function ----------------------------------------------------

# Input is the reactome pathway id (e.g. R-HSA-198933)
# Generates three variables, one with the highest level ID, one with its name
# (e.g. "Immune System"), one with all the hierarchies
path_steps <- function(pathway_id) {

  result <- content(GET(paste0(
    "https://reactome.org/ContentService/data/entity/",
    pathway_id,
    "/componentOf"
  )))

  if (class(result[[1]][1]) != "integer") {
    order <- c()

    while (class(result[[1]][1]) != "integer") {

      hsa_id <- result[1][[1]]$stIds[[1]]
      path_name <- result[1][[1]]$names[[1]]
      order <- paste0(order, path_name, ";")
      result <- content(GET(paste0(
        "https://reactome.org/ContentService/data/entity/",
        hsa_id,
        "/componentOf"
      )))
    }

    # Reverse the order of the output terms
    output <- str_split(order, ";") %>%
      unlist() %>%
      rev() %>%
      paste(., collapse = ";") %>%
      str_remove(., "^;") # Remove leading semicolon

  } else {
    # output <- NULL
    output <- pathway_id
  }
  return(output)
}


# Simple test cases -------------------------------------------------------

path_steps("R-HSA-6798695")
path_steps("R-HSA-382556")


# Load all Reactome pathways ----------------------------------------------

all_pathways <- read_tsv(
  "https://reactome.org/download/current/ReactomePathways.txt",
  col_names = c("pathway_id", "description", "organism")
) %>%
  filter(str_detect(pathway_id, "^R-HSA")) %>%
  select(-organism)

# Test with a subset of all pathways
test_out <- all_pathways[1:100, ] %>%
  mutate(hierarchy = map(pathway_id, ~path_steps(.x))) %>%
  separate(hierarchy, sep = ";", into = paste0("level_", 1:11)) %>%
  select(pathway_id, description, level_1, level_2) %>%
  mutate(
    level_2 = case_when(is.na(level_2) ~ description, TRUE ~ level_2)
  )

if (askYesNo("Run on all Reactome pathways (>2000)?")) {
  all_pathways_categorized <- all_pathways %>%
    mutate(hierarchy = map(pathway_id, ~path_steps(.x))) %>%
    separate(hierarchy, sep = ";", into = paste0("level_", 1:11)) %>%
    select(pathway_id, description, level_1, level_2) %>%
    mutate(
      level_2 = case_when(is.na(level_2) ~ description, TRUE ~ level_2)
    )
}


# Save the table ----------------------------------------------------------

write.table(
  all_pathways_categorized,
  "data/reactome_pathways_categorized.tsv",
  sep = "\t"
)
