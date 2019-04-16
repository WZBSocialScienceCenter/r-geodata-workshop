# WZB geo-data workshop
# solution for exercise 3: Visualizing WZB partner institutions on a world map
# April 2019, Markus Konrad <markus.konrad@wzb.eu>

library(ggplot2)
library(dplyr)
library(maps)
library(sf)

# load WZB partners data
partners <- read.csv('wzb_partners_data.csv', stringsAsFactors = FALSE)

# worldmap data
worldmap_data <- st_as_sf(map('world', plot = FALSE, fill = TRUE))
worldmap_data <- worldmap_data[worldmap_data$ID != 'Antarctica',]   # remove shape of Antarctica

# a first try -- this will produce overplotting in Europe
ggplot(partners) +                                     
    geom_sf(data = worldmap_data) +                    
    geom_point(aes(x = institute_lon, y = institute_lat, color = type)) +
    scale_color_discrete(guide = guide_legend(nrow = 4, title = NULL)) +
    theme_bw() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')

# grouping by city and counting institutions per city (variable "n" will contain number of institutions)
partners_cities <- group_by(partners, city, city_lon, city_lat) %>% count()

# plot institutions in partner cities
ggplot(partners_cities) +                                     
    geom_sf(data = worldmap_data) +  # background: world map                  
    geom_point(aes(x = city_lon, y = city_lat, size = n, color = city),   # make dot size dependent on number of institutions
               alpha = 0.5) +                                             # and color dependent on city
    scale_color_discrete(guide = 'none') +
    coord_sf(xlim = c(-20, 40), ylim = c(35, 65)) +                       # restrict the display window to Europe
    theme_bw() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')

