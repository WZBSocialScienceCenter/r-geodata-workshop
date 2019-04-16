# Data preparation for WZB partners data
# Geo-code partner institutions

library(readxl)
library(dplyr)
library(ggmap)


source('apikeys.R')

partners <- read_excel('wzb_partners_cleaned.xlsx')

partners[!complete.cases(partners), ]

partners <- partners[complete.cases(partners), ]

# provide the Google Cloud API key here:
register_google(key = google_cloud_api_key)

geocode_queries <- paste(partners$institution, partners$city, sep = ', ')
coords <- geocode(geocode_queries)

sum(is.na(coords))

partners_geocoded <- bind_cols(partners, coords)
partners_geocoded <- rename(partners_geocoded, institute_lon = lon, institute_lat = lat)

cities <- unique(partners$city)
city_coords <- geocode(cities) %>% mutate(city = cities)

sum(!complete.cases(city_coords))

partners_geocoded <- left_join(partners_geocoded, city_coords, by = 'city') %>% rename(city_lon = lon, city_lat = lat)

partners_geocoded  # there are some geocoding errors, correct them manually in the CSV

write.csv(partners_geocoded, 'wzb_partners_data.csv', row.names = FALSE)
#saveRDS(partners_geocoded, 'wzb_partners_data.RDS')
