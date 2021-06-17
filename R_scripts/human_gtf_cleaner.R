

# human_gtf_cleaner -------------------------------------------------------

human_gtf_cleaner <- function(gtf_file) {

  # Require tidyverse packages
  require(tidyverse)

  # Set column names for reading file
  gtf_colnames <- c("seqname", "source", "feature", "start", "end",
                    "score", "strand", "frame", "attribute")

  # Read in initial file
  gtf_0 <- fread(gtf_file,
                 sep = "\t",
                 skip = "havana",
                 col.names = gtf_colnames)

  # Filter feature type, select columns of interest
  gtf_1 <- gtf_0 %>%
    filter(feature == "gene") %>%
    select(seqname, start, end, strand, frame, attribute)

  # Pull desired elements from attribute column, then drop
  gtf_2 <- gtf_1 %>%
    mutate(
      gene_id   = str_extract(attribute, pattern = "ENSG[0-9]{11}"),
      gene_name = str_extract(attribute, pattern = 'gene_name ".*"; gene_source') %>%
                  str_replace(., pattern = 'gene_name "(.*)"; gene_source', replacement = "\\1")
      ) %>%
    select(-c(attribute))

}
