# WZB geo-data workshop
# solution for exercise 5: Choropleth map for EU-wide regional statistics
# April 2019, Markus Konrad <markus.konrad@wzb.eu>

library(ggplot2)
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

# combine spatial dataset and unemployment dataset using by matching "id" from "nutsrg"
# to "nuts" from "unempl2016"
unempl2016_geo <- left_join(nutsrg, unempl2016, by = c('id' = 'nuts'))

# make another subset to have only the total unemployment rate (not split by gender)
unempl2016_geo_total <- unempl2016_geo[unempl2016_geo$sex == 'T', ]

# make a choropleth map from this data
ggplot() + geom_sf(aes(fill = unempl_pct_bins),
                   data = unempl2016_geo_total, size = 0.1) +
    scale_fill_brewer(palette = 'OrRd', na.value = "grey90",
                      guide = guide_legend(title = 'Ranges in percent')) +
    labs(title = 'Total unemployment rate in EU NUTS level-2 regions in 2016',
         caption = 'source: Eurostat') +
    coord_sf(datum = NA) +  # disable lines ("graticules") in the background
    theme_bw() + theme(axis.text = element_blank(), axis.title = element_blank(),
                       axis.ticks = element_blank())

# prepare data to make small multiples (facetting) by gender

# where the matching didn't work (b/c no data for that NUTS code was in the unemployment dataset),
# we have to copy the subset with the NAs and set the "sex" so that we have regions with "NA" values
# for both sexes
fill_na_f <- unempl2016_geo[is.na(unempl2016_geo$sex),]
fill_na_f$sex <- 'F'
fill_na_m <- unempl2016_geo[is.na(unempl2016_geo$sex),]
fill_na_m$sex <- 'M'

# create the full dataset containing the data only for women and men
unempl2016_geo_f_m <- rbind(unempl2016_geo[!is.na(unempl2016_geo$sex) & unempl2016_geo$sex %in% c('F', 'M'),],
                            fill_na_f,
                            fill_na_m)

unempl2016_geo_f_m[is.na(unempl2016_geo_f_m$unempl_pct_bins),]

# make small multiples (facetting) by gender
ggplot() + geom_sf(aes(fill = unempl_pct_bins),
                   data = unempl2016_geo_f_m, size = 0.1) +
    scale_fill_brewer(palette = 'OrRd', na.value = "grey90",
                      guide = guide_legend(title = 'Ranges in pct.')) +
    labs(title = 'Unemployment rate in EU NUTS level-2 regions in 2016',
         caption = 'source: Eurostat') +
    coord_sf(datum = NA) +  # disable lines ("graticules") in the background
    facet_wrap(~ sex, nrow = 1,      # facet by "sex", set custom labels
               labeller = as_labeller(c('F' = 'Women', 'M' = 'Men'))) +
    theme_bw() + theme(axis.text = element_blank(), axis.title = element_blank(),
                       axis.ticks = element_blank())
