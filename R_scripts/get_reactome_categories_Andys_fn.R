# Input is the Reactome pathway ID (e.g. R-HSA-198933)
# Generates three variables, one with the highest level ID, one with its name
# (e.g. "Immune System"), one with all the hierarchy names
path_steps <- function(pathway_id) {

  result <- httr::content(httr::GET(paste0(
    "https://reactome.org/ContentService/data/entity/",
    pathway_id,
    "/componentOf"
  )))

  if (class(result[[1]][1]) != "integer") {
    order <- c()
    while (class(result[[1]][1]) != "integer") {
      hsa_id <- result[1][[1]]$stIds[[1]]
      path_name <- result[1][[1]]$names[[1]]
      order <- paste0(order, path_name, '; ')
      result <- httr::content(httr::GET(paste0(
        "https://reactome.org/ContentService/data/entity/",
        hsa_id,
        "/componentOf"
      )))
    }
    return(list(hsa_id, path_name, order))
  } else {
    return(NA)
  }
}
