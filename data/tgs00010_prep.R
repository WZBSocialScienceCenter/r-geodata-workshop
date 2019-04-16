library(tidyr)
library(dplyr)

# Unemployment rate by NUTS 2 regions (tgs00010)
unempl <- read.delim('tgs00010.tsv', stringsAsFactors = FALSE)

unempl <- gather(unempl, 'year', 'unempl_pct', -unit.age.sex.geo.time)

unempl <- separate(unempl, unit.age.sex.geo.time, into = c('unit', 'age', 'sex', 'nuts'), sep = ',')

unique(unempl$unit)
unique(unempl$age)

unempl <- select(unempl, -unit, -age)

unempl <- mutate(unempl, sex = as.factor(sex),
                 year = as.integer(substr(year, 2, 99)),
                 unempl_pct = as.numeric(gsub('[^0-9\\.]', '', unempl_pct)))

write.csv(unempl, 'tgs00010_unempl_nuts2.csv', row.names = FALSE)
