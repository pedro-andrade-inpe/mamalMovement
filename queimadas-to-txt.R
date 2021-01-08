
setwd("C:/Users/pedro/Dropbox/pesquisa/2021/taina")

require(dplyr)
require(sf)

shpfiles <- list.files("Shapefile", "^Q")
shpfiles <- paste0("Shapefile/", shpfiles[endsWith(shpfiles, "shp")])

cells <- sf::read_sf("Shapefile/Teste2000.shp") %>%
  dplyr::select(col, row)

for(shpfile in shpfiles){
  cat(paste0("Processing '", shpfile, "'\n"))

  shpdata <- sf::read_sf(shpfile)
  
  result <- cells %>% sf::st_intersects(shpdata, sparse = FALSE) %>%
    apply(1, any) %>%
    which()
  
  shpresult <- cells[result, ]
  
  # save to check the result
  # sf::write_sf(shpresult, "overlap.shp")
  
  shpresult %>% 
    as.data.frame() %>%
    dplyr::select(col, row) %>%
    write.csv(file = paste0("Shapefile/Queimada/", basename(shpfile), ".csv"), row.names = FALSE)
}
