
setwd("C:/Users/pedro/Dropbox/pesquisa/2021/taina")

require(dplyr)
require(sf)

shpfiles <- list.files("Shapefile", "^T")
shpfiles <- paste0("Shapefile/", shpfiles[endsWith(shpfiles, "shp")])

shpdata <- sf::read_sf(shpfiles[1]) %>%
  dplyr::select(id, col, row, state) %>%
  sf::write_sf("cells.shp")
