# Prepare Eurostat dataset "People at risk of poverty or social exclusion by NUTS 2 regions (tgs00107)":
# 1. convert to long table format
# 2. extract NUTS code
# 3. make proper year integer
# 4. make proper risk percentage numeric
#
# Data from Eurostat, https://ec.europa.eu/eurostat/web/regions/data/main-tables

library(tidyr)
library(dplyr)

# People at risk of poverty or social exclusion by NUTS 2 regions (tgs00107)
pov_risk <- read.delim('tgs00107.tsv', stringsAsFactors = FALSE)
pov_risk <- gather(pov_risk, 'year', 'risk_pct', -unit.geo.time)

pov_risk <- mutate(pov_risk, nuts = substr(unit.geo.time, 8, 99),
                             year = as.integer(substr(year, 2, 99)),
                             risk_pct = as.numeric(gsub('[^0-9\\.]', '', risk_pct))) %>%
            select(nuts, year, risk_pct)

write.csv(pov_risk, 'tgs00107_pov_risk_nuts2.csv', row.names = FALSE)
