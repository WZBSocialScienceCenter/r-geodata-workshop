# WZB geo-data workshop
# solution for exercise 2: (Birth-)places on a map
# April 2019, Markus Konrad <markus.konrad@wzb.eu>


library(ggplot2)
library(maps)
library(sf)

# constructing the data frame:

places <- data.frame(
    label = c('born', 'living', 'neven been there'),
    lng = c(  12.590, 13.402,   8.0456),
    lat = c(  51.279, 52.520,   52.276)
)

# worldmap data
worldmap_data <- st_as_sf(map('world', plot = FALSE, fill = TRUE))

# all points are located in Germany, so lets only use this shape
germany_map <- worldmap_data[worldmap_data$ID == 'Germany',]

# make the plot, using only the shape of Germany
ggplot(places) +                                  
    geom_sf(data = germany_map) +                        # background: shape of Germany
    geom_point(aes(x = lng, y = lat)) +                  # dots using coordinates from "places"
    geom_label(aes(x = lng, y = lat, label = label),     # labels using coordinates and label from "places"
               hjust = 0, vjust = 1, nudge_x = 0.15) +   # make the labels appear next to dots
    theme_bw() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')

# alternative: restricting the display window around Germany
ggplot(places) +                                  
    geom_sf(data = worldmap_data) +                      # background: world map
    geom_point(aes(x = lng, y = lat)) +                  # same as above
    geom_label(aes(x = lng, y = lat, label = label),     # ...
               hjust = 0, vjust = 1, nudge_x = 0.15) +   # ...
    coord_sf(xlim = c(6, 15), ylim = c(47.5, 55.25)) +   # restrincting the displayed longitude range (xlim) ...
    theme_bw() +                                         # ... and latitude range (ylim)
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')
