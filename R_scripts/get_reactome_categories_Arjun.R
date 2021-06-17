
# This script was written by Arjun, and tidied by Travis on 20210617


# Load packages -----------------------------------------------------------

library(tidyverse)


# Read in pathway hierarchy and pathway names -----------------------------

pathway_hierarchy <- read_tsv(
    "https://reactome.org/download/current/ReactomePathwaysRelation.txt",
    col_names = c("higher", "pathway_id")
  ) %>%
  filter(str_detect(higher, "^R-HSA"))

all_pathways <- read_tsv(
  "https://reactome.org/download/current/ReactomePathways.txt",
  col_names = c("pathway_id", "description", "organism")
) %>%
  filter(str_detect(pathway_id, "^R-HSA")) %>%
  select(-organism)


# Function to join and rename ---------------------------------------------

pathway_join <- function(input, name) {
  nam <- name
  p <- left_join(input, pathway_hierarchy, by = "pathway_id") %>%
    rename(!!name := "pathway_id", pathway_id = "higher")
  return(p)
}


# Initial join of all pathways to their parent ----------------------------

full_hierarchy <- all_pathways %>%
  select(pathway_id) %>%
  pathway_join(name = "enr_pathway")


# Run successive joins to fully expand the hierarchy ----------------------

for (i in 1:11) {
  names <- as.character(english::as.english(i))
  full_hierarchy <- full_hierarchy %>% pathway_join(name = names)
}

# All entries in "pathway_id" column are NA, so remove that column
length(na.omit(full_hierarchy$pathway_id))
full_hierarchy <- full_hierarchy %>% select(-pathway_id)


# Reduce hierarchy --------------------------------------------------------

# For each term, we want it's highest and second-highest level parent
enr_pathway_high_level <- data.frame()

for (row in 1:nrow(full_hierarchy)) {
  p <- na.omit(as.character(full_hierarchy[row, ]))

  how_deep <- length(p)

  if (how_deep >= 3) {
    p <- data.frame(
      enr_pathway     = p[1],
      one_lower_level = p[length(p) - 1],
      top_level       = p[length(p)]
    )
    enr_pathway_high_level <- bind_rows(enr_pathway_high_level, p)
  } else {
    p <- data.frame(
      enr_pathway     = p[1],
      one_lower_level = p[1],
      top_level       = p[length(p)]
    )
    enr_pathway_high_level <- bind_rows(enr_pathway_high_level, p)
  }
}


# Add descriptions --------------------------------------------------------

pathways_higher_levels_description <- enr_pathway_high_level %>%
  # Base level
  left_join(all_pathways, by = c("enr_pathway" = "pathway_id")) %>%
  rename("enr_description" = description) %>%
  # Second-highest level
  left_join(all_pathways, by = c("one_lower_level" = "pathway_id")) %>%
  rename("one_lower_level_description" = description) %>%
  # Highest level
  left_join(all_pathways, by = c("top_level" = "pathway_id")) %>%
  rename("top_level_description" = description)


# Save the results --------------------------------------------------------

write_csv(
  full_hierarchy,
  "data/reactome_pathway_hierarchy_full.csv"
)

write_csv(
  pathways_higher_levels_description,
  "data/reactome_pathway_hierarchy_top.csv"
)
