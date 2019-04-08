library(ggplot2)
library(ggrepel)
library(dplyr)
library(maps)
library(sf)

# 1.
partners <- read.csv('wzb_partners_data.csv', stringsAsFactors = FALSE)

# 2.
worldmap_data <- st_as_sf(map('world', plot = FALSE, fill = TRUE))
worldmap_data <- worldmap_data[worldmap_data$ID != 'Antarctica',]   # 3.

# 4.
ggplot(partners) +                                     
    geom_sf(data = worldmap_data) +                    
    geom_point(aes(x = institute_lon, y = institute_lat, color = type)) +
    scale_color_discrete(guide = guide_legend(nrow = 4, title = NULL)) +
    theme_minimal() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')

# 5.
partners_cities <- group_by(partners, city, city_lon, city_lat) %>% count()

ggplot(partners_cities) +                                     
    geom_sf(data = worldmap_data) +                    
    geom_point(aes(x = city_lon, y = city_lat, size = n, color = city), alpha = 0.5) +
    scale_color_discrete(guide = 'none') +
    coord_sf(xlim = c(-30, 40), ylim = c(35, 65)) +
    theme_minimal() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(),
          legend.position = 'bottom')




# # 5.
# ggplot(partners) +                                     
#     geom_sf(data = worldmap_data) +                    
#     geom_point(aes(x = institute_lon, y = institute_lat, color = type)) +
#     geom_label_repel(aes(label = institution_short, x = institute_lon, y = institute_lat), size = 2) +
#     scale_color_discrete(guide = guide_legend(nrow = 4, title = NULL)) +
#     theme_minimal() +
#     theme(axis.title = element_blank(),
#           axis.text = element_blank(),
#           legend.position = 'bottom')
# 
