
cat("Loading libraries...\n")

library(biomaRt)
library(tidyverse)


todays_date <- str_replace_all(Sys.Date(), pattern = "-", replacement = "")


cat("\nCreate biomart table...\n")

biomart_table <- getBM(
  attributes = c("ensembl_gene_id", "hgnc_symbol", "entrezgene_id"),
  mart = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
)
biomart_table[biomart_table == ""] <- NA

biomart_table <- biomart_table %>%
  distinct(ensembl_gene_id, .keep_all = T)

cat("\nSave output...\n")

saveRDS(biomart_table, file = paste0("~/biomart_table_", todays_date, ".rds"))


cat("\nDONE!\n")
