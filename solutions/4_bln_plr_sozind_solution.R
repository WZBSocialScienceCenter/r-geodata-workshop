# WZB geo-data workshop
# solution for exercise 4: Making a choropleth map of social indicators in Berlin
# April 2019, Markus Konrad <markus.konrad@wzb.eu>

library(ggplot2)
library(dplyr)
library(sf)

# load social indicators data
# make sure that your working directory is set to where this file resides
# this is what the columns mean:
# STATUS1: Unemployment rate 2016 in percent
# STATUS2: Long term unemployment rate 2016 in percent
# STATUS3: Pct. of households that obtain social support ("Hartz IV") 2016
# STATUS4: Portion of children under 15 living in household that obtains social support ("Hartz IV") 2016
# DYNAMO1 to 4: Change in the above indicators from the previous year
sozind <- read.csv('bln_plr_sozind_data.csv', stringsAsFactors = FALSE,
                   colClasses = c('SCHLUESSEL' = 'character'))

# load the spatial dataset containing the "Planungsraum" regions and their ID ("SCHLUESSEL")
# make sure that your working directory is set to where this file resides
bln_plr_geo <- read_sf('bln_plr.geojson')
st_crs(bln_plr_geo) <- 25833   # CRS must be set

# simply plot regions
ggplot() + geom_sf(data = bln_plr_geo)

# combine spatial dataset and social indicator dataset using "SCHLUESSEL" as common identifier
sozind_geo <- left_join(bln_plr_geo, sozind, by = c('SCHLUESSEL'))

# make a simple choropleth map, directly shading the regions according to "STATUS1" variable
ggplot() + geom_sf(aes(fill = STATUS1), data = sozind_geo)

# make 4 bins from 0 to 20% for STATUS1 (unemployment): 0 to 5%, 5 to 10%, ...
sozind_geo$pct_unempl_bins <- cut(sozind_geo$STATUS1, seq(0, 20, by = 5))

# make the plot
ggplot() + geom_sf(aes(fill = pct_unempl_bins), data = sozind_geo) +
    scale_fill_brewer(palette = 'OrRd', na.value = "grey90",
                      guide = guide_legend(title = 'Ranges in percent')) +
    labs(title = 'Unemployment in Berlin 2016', caption = 'source: Berlin Senate Dept. for Urban Dev. and Housing') +
    coord_sf(datum = NA) +  # disable lines ("graticules") in the background
    theme_bw() + theme(axis.text = element_blank(), axis.title = element_blank(),
                       axis.ticks = element_blank())
