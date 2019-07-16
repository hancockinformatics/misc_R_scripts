
# gtf_cleaner -------------------------------------------------------------

# Given an input GTF file (bacterial), separates and cleans columns, returning a
# clean and tidy data frame. Only returns locus tag, gene name, description,
# start, end, and strand columns. Only supports PAO1, PA14, and LESB58. Automatically
# detects strain based on input file name.


gtf_cleaner <- function(gtf_file) {

  require(tidyverse)

  gtf_cols = c("seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attribute")
  gtf <- read_tsv(gtf_file, col_names = gtf_cols)

  # PAO1
  if (grepl("PAO1", x = gtf_file)) {

    clean_gtf <- gtf %>%
      filter(feature == "CDS") %>%
      separate(., attribute, into = c("gene_id", "transcript_id", "locus_tag", "name", "ref"), sep = ";") %>%
      select(locus_tag, name, start, end, strand) %>%
      mutate(locus_tag = str_replace_all(locus_tag, pattern = ' locus_tag "(PA[0-9]{4})"', replacement = "\\1"),
             name = str_replace_all(name, pattern = ' name "(.*)"', replacement = "\\1")) %>%
      separate(., name, into = c("PAO1_name", "PAO1_description"), sep = " ,", fill = "left")

  # PA14
  } else if (grepl("PA14", x = gtf_file)) {

    clean_gtf <- gtf %>%
      filter(feature == "CDS") %>%
      separate(., attribute, into = c("gene_id", "transcript_id", "locus_tag", "name", "ref"), sep = ";") %>%
      select(locus_tag, name, start, end, strand) %>%
      mutate(locus_tag = str_replace_all(locus_tag, pattern = ' locus_tag "(PA14_[0-9]{5})"', replacement = "\\1"),
             name = str_replace_all(name, pattern = ' name "(.*)"', replacement = "\\1")) %>%
      separate(., name, into = c("PA14_name", "PA14_description"), sep = " ,", fill = "left")

  } else if (grepl("LESB58", x = gtf_file)) {

  clean_gtf <- gtf %>%
    filter(feature == "CDS") %>%
    separate(., attribute, into = c("gene_id", "transcript_id", "locus_tag", "name", "ref"), sep = ";") %>%
    select(locus_tag, name, start, end, strand) %>%
    mutate(locus_tag = str_replace_all(locus_tag, pattern = ' locus_tag "(PALES_[0-9]{5})"', replacement = "\\1"),
           name = str_replace_all(name, pattern = ' name "(.*)"', replacement = "\\1")) %>%
    separate(., name, into = c("LESB58_name", "LESB58_description"), sep = " ,", fill = "left")
  }

  return(clean_gtf)

}
