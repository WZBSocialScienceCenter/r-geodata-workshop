# bln_plr_sozind.geojson already contains geo-data *and* socio-economic indicators.
# However, for practice reasons let's remove the geo-data and add the LOR identifier
# so that we can learn how to match the LOR codes assigned to each region in the
# shapefile "Planungsraum_EPSG_25833.shp" with the socio-economic data
# in "berlin_plr_sozind_daten.csv"
#

library(sf)
library(dplyr)

plr_shp <- read_sf('Planungsraum_EPSG_25833.shp')
plr_shp$PLR_NAME <- iconv(plr_shp$PLR_NAME, from = 'LATIN1', to = 'UTF-8')
plr_shp <- select(as.data.frame(plr_shp), -geometry)
plr_shp <- plr_shp[!is.na(plr_shp$SCHLUESSEL),]

plr_geojson <- read_sf('bln_plr_sozind.geojson')
plr_geojson <- select(as.data.frame(plr_geojson), -geometry)

plr_daten <- bind_cols(plr_shp, plr_geojson) %>% select(-PLR_NAME)

write.csv(plr_daten, 'berlin_plr_sozind_daten.csv', row.names = FALSE)
