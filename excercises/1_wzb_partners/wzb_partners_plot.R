library(ggplot2)
library(maps)
library(sf)

# 1.
partners <- read.csv('wzb_partners.csv', stringsAsFactors = FALSE)

# 2.
worldmap_data <- st_as_sf(map('world', plot = FALSE, fill = TRUE))
worldmap_data <- worldmap_data[worldmap_data$ID != 'Antarctica',]   # 3.

# 4.
ggplot(partners) +                                     
    geom_sf(data = worldmap_data) +                    
    geom_point(aes(x = lng, y = lat, color = country)) +    # TODO: country -> color ?
    geom_label(aes(x = lng, y = lat, label = name),    
               hjust = 0, vjust = 1, nudge_x = 3, size = 3) + 
    theme_minimal() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')

