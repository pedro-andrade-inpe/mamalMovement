
setwd("C:/Users/pedro/Dropbox/pesquisa/2021/taina")

require(dplyr)
require(sf)

shpfiles <- list.files("Shapefile", "^T")
shpfiles <- paste0("Shapefile/", shpfiles[endsWith(shpfiles, "shp")])

for(shpfile in shpfiles){
  cat(paste0("Processing '", shpfile, "'\n"))

  shpdata <- sf::read_sf(shpfile) %>%
    as.data.frame() %>%
    dplyr::select(col, row, state) %>%
    write.csv(file = paste0("Shapefile/Cells/", basename(shpfile), ".csv"), row.names = FALSE)
}
