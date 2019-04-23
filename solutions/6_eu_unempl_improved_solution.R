# WZB geo-data workshop
# solution for exercise 6: Improving the choropleth map for EU-wide regional statistics
# April 2019, Markus Konrad <markus.konrad@wzb.eu>

library(ggplot2)
library(ggrepel)
library(dplyr)
library(sf)

# load unemployment data at NUTS level-2
# make sure that your working directory is set to where this file resides
unempl <- read.csv('tgs00010_unempl_nuts2.csv', stringsAsFactors = FALSE)

# check the maximum unemployment rate to decide on a proper way to make discrete bins
max(unempl$unempl_pct, na.rm = TRUE)

# make discrete bins
unempl$unempl_pct_bins <- cut(unempl$unempl_pct, seq(0, 50, by = 10))

unempl$sex <- as.factor(unempl$sex)

head(unempl)

# make a subset for the 2016 data
unempl2016 <- unempl[unempl$year == 2016,] %>% select(-year)

head(unempl2016)

# load the NUTS regions spatial dataset at level 2 from year 2016
# make sure that your working directory is set to where this file resides
nutsrg <- read_sf('nutsrg_2_2016_epsg3857_20M.json')
st_crs(nutsrg) <- 3857  # set the proper CRS

# now transform it to ETRS89
nutsrg <- st_transform(nutsrg, crs = 4258)

# combine spatial dataset and unemployment dataset using by matching "id" from "nutsrg"
# to "nuts" from "unempl2016"
unempl2016_geo <- left_join(nutsrg, unempl2016, by = c('id' = 'nuts'))

# make another subset to have only the total unemployment rate (not split by gender)
unempl2016_geo_total <- unempl2016_geo[unempl2016_geo$sex == 'T', ] %>% select(-sex)

# make two small datasets: one with three regions with the lowest unempl. rate
# and another one with three regions with the highest unempl. rate
lowest_unempl <- unempl2016_geo_total %>% arrange(unempl_pct) %>% head(3) %>%  # lowest 3
    mutate(type = 'lowest') %>%  # add a variable to later make the label color dependent on it
    select(-unempl_pct_bins)     # drop that variable

highest_unempl <- unempl2016_geo_total %>% arrange(desc(unempl_pct)) %>% head(3) %>%   # highest 3
    mutate(type = 'highest') %>% # add a variable to later make the label color dependent on it
    select(-unempl_pct_bins)     # drop that variable

# append these two datasets to form a single dataset and add a composite label
unempl_extremes <- rbind(lowest_unempl, highest_unempl) %>%
    mutate(label = paste0(id, ': ', na, ' (', unempl_pct, '%)'))

unempl_extremes

# calculate the regions' centroids
unempl_extremes_centroids <- st_coordinates(st_centroid(unempl_extremes$geometry))

# append those coordinates to the dataset
unempl_extremes <- cbind(unempl_extremes, unempl_extremes_centroids)

unempl_extremes

# "zoom in" to central / south Europe as all extreme regions are located there
# display window coordinates are specified as two points in WGS84: bottom left and top right
disp_window <- st_sfc(st_point(c(-12, 31)), st_point(c(50, 55)), crs = 4326)

# convert the WGS84 coord. of the display window to ETRS89 coordinates so
# that it matches the CRS of our datasets
disp_window_etrs89 <- st_transform(disp_window, crs = 4258)
disp_window_etrs89_coord <- st_coordinates(disp_window_etrs89)

# make a choropleth map from this data
ggplot() + geom_sf(aes(fill = unempl_pct_bins),
                   data = unempl2016_geo_total, size = 0.1) +
    geom_label_repel(aes(x = X, y = Y, label = label, color = type),         # auto-repel labels
                     data = unempl_extremes, min.segment.length = 0,
                     segment.size = 1) +
    scale_fill_brewer(palette = 'OrRd', na.value = "grey90",
                      guide = guide_legend(title = 'Ranges in percent')) +
    scale_color_brewer(palette = 'Dark2', direction = -1, guide = 'none') +  # color palette for labels
    labs(title = 'Total unemployment rate in EU NUTS level-2 regions in 2016',
         caption = 'source: Eurostat') +
    coord_sf(xlim = disp_window_etrs89_coord[,'X'],
             ylim = disp_window_etrs89_coord[,'Y'], datum = NA) +
    theme_bw() + theme(axis.text = element_blank(), axis.title = element_blank(),
                       axis.ticks = element_blank())

