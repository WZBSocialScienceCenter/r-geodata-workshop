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
plr_geojson_data_only <- select(as.data.frame(plr_geojson), -geometry)

plr_daten <- bind_cols(plr_shp, plr_geojson_data_only) %>% select(-PLR_NAME)

write.csv(plr_daten, 'bln_plr_sozind_data.csv', row.names = FALSE)

plr_geojson_geo_only <- select(bind_cols(plr_shp, plr_geojson), SCHLUESSEL, PLR_NAME, PLANNAME, geometry)
plr_geojson_geo_only <- select(plr_geojson_geo_only, -PLR_NAME, -PLANNAME)

write_sf(plr_geojson_geo_only, 'bln_plr.geojson')
