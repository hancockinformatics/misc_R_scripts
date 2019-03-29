clean_rnaseq_form <- function(sample_df){

  require(tidyverse)

  sample_df %>%
    map_df(~trimws(.) %>%
             str_replace_all(string = ., pattern = " ", replacement = ""))

}
