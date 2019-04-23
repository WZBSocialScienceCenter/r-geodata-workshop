#
# Preparation file for interactive workshop session
#

set.seed(10042019)

#### Plotting with *ggplot2* ####

library(pscl)
library(dplyr)

sampled_states <- presidentialElections %>%
    distinct(state, south) %>%
    group_by(south) %>%    # group by south / not south
    sample_n(2) %>%        # take 2 from each group
    ungroup() %>%
    pull(state)

sampled_pres <- filter(presidentialElections, state %in% sampled_states)
sampled_pres


#### Plotting with *ggplot2*: Different datasets per layer ####

random_dots <- data.frame(x = sample(sampled_pres$year, 10),
                          y = rnorm(10, mean = 50, sd = 10))


#### Putting points on the map ####

library(sf)
library(maps)

worldmap_data <- st_as_sf(map('world', plot = FALSE, fill = TRUE))
worldmap_data


some_cities <- data.frame(name = c('Berlin', 'New York', 'Sydney'),
                          lng = c(13.38, -73.94, 151.21),
                          lat = c(52.52, 40.6, -33.87))
some_cities


#### Data linkage with *dplyr* ####

pm <- data.frame(city = c('Amman', 'Saltillo', 'Usak', 'The Bronx', 'Seoul'),
                 pm_mg = c(999, 869, 814, 284, 129),
                 stringsAsFactors = FALSE)
city_coords <- data.frame(city = c('Amman', 'Saltillo', 'Berlin', 'Usak', 'New York', 'Seoul'),
                          lng = c(31.910,   -100.994,   13.402,    29.403, -73.94,    126.983762),
                          lat = c(35.948,    25.434,    52.520,    38.673,  40.6,     37.536256),
                          stringsAsFactors = FALSE)


#### Making a choropleth map ####

library(sf)

bln_sozind <- read_sf('data/bln_plr_sozind.geojson')


#### Combining data: Poverty risk data ####

pov_risk <- read.csv('data/tgs00107_pov_risk_nuts2.csv',
                     stringsAsFactors = FALSE)
pov_risk$risk_pct_bins <- cut(pov_risk$risk_pct, seq(0, 100, by = 10))

pov_risk_2016 <- filter(pov_risk, year == 2016)   # 2016 has fewest NAs
pov_risk_2016


#### Combining data: NUTS level-2 regions ####

nutsrg2 <- read_sf('data/nutsrg_2.json')
st_crs(nutsrg2) <- 3857  # set the correct CRS

nutsrg2


#### Using *ggmap* for geocoding ####

library(ggmap)

source('apikeys.R')

# provide the Google Cloud API key here:
register_google(key = google_cloud_api_key)

places <- c('Berlin', 'Leipzig', '10317, Deutschland',
            'Reichpietschufer 50, 10785 Berlin')

place_coords <- geocode(places) %>% mutate(place = places)
place_coords


#### Using *ggmap* for reverse geocoding ####

revgeocode(c(13.36509, 52.50640))


#### Finding out the CRS ####

worldmap_data <- st_as_sf(map('world', plot = FALSE, fill = TRUE))
worldmap_data


#### Setting the CRS ####

bln_plan <- read_sf('data/Planungsraum_EPSG_25833.shp')
bln_plan


#### Setting the display window ####

worldmap <- ne_countries(type = 'map_units', returnclass = 'sf')



