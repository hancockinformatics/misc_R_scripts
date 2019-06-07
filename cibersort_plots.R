
# Load required libraries and sample info ---------------------------------

pkgs <- c("matrixStats", "pheatmap", "RColorBrewer", "tidyverse", "cowplot")
lapply(pkgs, library, character.only = T)

samples <- read_csv("samples_20190529.csv") %>%
  mutate(Library_name = str_replace_all(Library_name, pattern = "-", replacement = "."))


# Read in results ---------------------------------------------------------

cibersort_raw <- read_tsv("Results/Cibersort/CIBERSORT.Output_Job11_20190529.txt") %>%
  rename("Patient" = `Input Sample`) %>%
  select(-c(`P-value`, `Pearson Correlation`, `RMSE`))


# Clean up data for plotting ----------------------------------------------

# Remove cell types which are 0 in all samples, make into long format
cibersort_tidy <- cibersort_raw[, colSums(cibersort_raw != 0) > 0] %>%
  gather(key = Cell_type, value = Proportion, 2:18) %>%
  left_join(samples, ., by = c("Library_name" = "Patient"))


# Make a heatmap of cibersort results -------------------------------------

cibersort_hmap <- cibersort_raw %>%
  column_to_rownames(var = "Patient") %>%
  as.matrix() %>%
  t()

pheatmap(
  cibersort_hmap,
  angle_col = 45,
  color = colorRampPalette(brewer.pal(9, "Blues"))(100), fontsize = 12
)


# Make stacked bar chart --------------------------------------------------

mypalette <- colorRampPalette(brewer.pal(8, "Set3"))

cibersort_barplot <- cibersort_tidy
cibersort_barplot$Library_name <- factor(cibersort_barplot$Library_name,
                                    levels = str_sort(unique(cibersort_barplot$Library_name), numeric = T))

ggplot(cibersort_barplot, aes(Library_name, Proportion, fill = Cell_type)) +
  geom_bar(position = "stack", stat = "identity", colour = "grey30") +
  labs(fill = "Cell Type", x = "", y = "Estimated Proportion") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(expand = c(0.01, 0)) +
  scale_fill_manual(values = mypalette(17))


# Boxplot with cell types on x-axis ---------------------------------------

ggplot(cibersort_tidy, aes(Cell_type, Proportion, fill = Cell_type)) +
  geom_boxplot(outlier.shape = 21, colour = "black") +
  labs(x = "", y = "Estimated Proportion") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") +
  scale_fill_manual(values = mypalette(17))
