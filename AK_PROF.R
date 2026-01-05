# Libraries
library(readxl)
library(dplyr)
library(tidyr)
library(writexl)

getwd()
setwd("D:/PROF AK SAHOO")
# Read data (main data sheet)
raw_data <- read_excel(
  "DATA.xls",
  sheet = "Data"
)

# Countries to keep (Updated list)

countries_10 <- c(
  # West Africa (15)
  "Benin",
  "Burkina Faso",
  "Cote d'Ivoire",
  "Gambia, The",
  "Ghana",
  "Guinea",
  "Guinea-Bissau",
  "Liberia",
  "Mali",
  "Mauritania",
  "Niger",
  "Nigeria",
  "Senegal",
  "Sierra Leone",
  "Togo",
  
  # East Africa (13)
  "Burundi",
  "Djibouti",
  "Ethiopia",
  "Kenya",
  "Madagascar",
  "Malawi",
  "Mauritius",
  "Mozambique",
  "Rwanda",
  "Tanzania",
  "Uganda",
  "Zambia",
  "Zimbabwe",
  
  # Central Africa (3)
  "Cameroon",
  "Chad",
  "Congo, Rep.",
  
  # Southern Africa (5)
  "Botswana",
  "Eswatini",
  "Lesotho",
  "Namibia",
  "South Africa"
)


# Reshape: years (1960, 1961, ...) → long format
long_data <- raw_data %>%
  pivot_longer(
    cols = matches("^[0-9]{4}$"),
    names_to = "YEAR",
    values_to = "Net official development assistance and official aid received (current US$)"
  ) %>%
  mutate(YEAR = as.integer(YEAR)) %>%
  filter(`Country Name` %in% countries_10) %>%
  select(
    YEAR,
    `Country Name`,
    `Net official development assistance and official aid received (current US$)`
  ) %>%
  arrange(YEAR, `Country Name`)

# Export to Excel with two sheets
write_xlsx(
  list(
    "Filtered_10_Countries" = long_data,
    "Original_Data" = raw_data
  ),
  path = "ODA_FINAL_Countries.xlsx"
)

#_________________________________________HDR_______________________________________________________________#
# -------------------------------------------------
# Libraries
# -------------------------------------------------
library(readxl)
library(dplyr)
library(writexl)

# -------------------------------------------------
# Read data
# -------------------------------------------------
raw_data <- read_excel(
  "FOREGIN_AID_ECO._RELV_MAIN_AA_WRKING.xlsx",      # change filename if needed
  sheet = "DEA_DATASET"
)


# -------------------------------------------------
# Countries to keep
# -------------------------------------------------
countries_10 <- c(
  # West Africa
  "Benin", "Burkina Faso", "Cote d'Ivoire", "Gambia, The", "Ghana",
  "Guinea", "Guinea-Bissau", "Liberia", "Mali", "Mauritania",
  "Niger", "Nigeria", "Senegal", "Sierra Leone", "Togo",
  
  # East Africa
  "Burundi", "Djibouti", "Ethiopia", "Kenya", "Madagascar",
  "Malawi", "Mauritius", "Mozambique", "Rwanda", "Tanzania",
  "Uganda", "Zambia", "Zimbabwe",
  
  # Central Africa
  "Cameroon", "Chad", "Congo, Rep.",
  
  # Southern Africa
  "Botswana", "Eswatini", "Lesotho", "Namibia", "South Africa"
)

# -------------------------------------------------
# Standardize to PANEL FORMAT
# YEAR | COUNTRY | INDICATOR | VALUE
# -------------------------------------------------
panel_data <- raw_data %>%
  filter(country %in% countries_10) %>%
  transmute(
    YEAR      = as.integer(year),
    COUNTRY   = country,
    INDICATOR = indicator,
    VALUE     = value

  ) %>%
  arrange(YEAR, COUNTRY, INDICATOR)

# -------------------------------------------------
# Optional QA: remove missing values
# -------------------------------------------------
panel_data_clean <- panel_data %>%
  filter(!is.na(VALUE))

# -------------------------------------------------
# Export to Excel
# -------------------------------------------------
write_xlsx(
  list(
    "Panel_Data_Clean" = panel_data_clean,
    "Panel_Data_Raw"   = panel_data
  ),
  path = "FINAL_PANEL_DATA.xlsx"
)











#--------------------------------------DATA BALANCING QA-QC-------------------------------------------------#


panel = read_excel(
  "FOREGIN_AID_ECO._RELV_MAIN_AA_WRKING.xlsx",      # change filename if needed
  sheet = "DEA_DATASET_CLND")

str(panel)

summary(panel$YEAR)

length(unique(panel$`Country Name`))
table(str(panel)) 
summary(panel)

#FREQUENCY TABLE:

#1,\.Number of NA / Non-NA per indicator

freq_indicator <- panel %>%
  summarise(across(
    -c(`Country Name`, YEAR),
    list(
      non_missing = ~ sum(!is.na(.)),
      missing     = ~ sum(is.na(.))
    )
  )) %>%
  pivot_longer(
    everything(),
    names_to = c("indicator", "status"),
    names_sep = "_(?=[^_]+$)"
  ) %>%
  pivot_wider(
    names_from = status,
    values_from = value
  )

freq_indicator

#How many indicators are missing in each row**

freq_row <- panel %>%
  mutate(
    missing_count = rowSums(is.na(select(., -c(`Country Name`, YEAR))),
    total_indicators = ncol(panel) - 2,
    
  ) %>%
  select(`Country Name`, YEAR, missing_count, missing_pct) %>%
  arrange(desc(missing_count))

freq_row

# COUNTRY X INDICATORS
panel %>%
  pivot_longer(-c(`Country Name`, YEAR)) %>%
  mutate(missing = is.na(value)) %>%
  group_by(`Country Name`, name) %>%
  summarise(missing_rate = mean(missing), .groups = "drop") %>%
  ggplot(aes(x = name, y = `Country Name`, fill = missing_rate)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  theme_minimal() +
  labs(title = "Missingness Heatmap: Country × Indicator")


#Countries have least data:
panel %>%
  mutate(missing_count = rowSums(is.na(across(-c(`Country Name`, YEAR))))) %>%
  group_by(`Country Name`) %>%
  summarise(total_missing = sum(missing_count)) %>%
  arrange(desc(total_missing))

#years have least data
panel %>%
  mutate(missing_count = rowSums(is.na(across(-c(`Country Name`, YEAR))))) %>%
  group_by(YEAR) %>%
  summarise(total_missing = sum(missing_count)) %>%
  arrange(desc(total_missing))

#from which year we can start

n_countries <- n_distinct(panel$`Country Name`)

panel %>%
  group_by(YEAR) %>%
  summarise(
    coverage = mean(complete.cases(across(-c(`Country Name`,YEAR))))
  ) %>%
  filter(coverage >= 0.8) %>%
  summarise(first_good_year = min(YEAR))

#MISSING VALUE/ NA/ NULL year wise
panel_long <- panel %>%
  pivot_longer(
    cols = -c(`Country Name`, YEAR),
    names_to = "indicator",
    values_to = "value"
  )


na_by_year <- panel_long %>%
  group_by(YEAR) %>%
  summarise(
    na_count = sum(is.na(value)),
    total_obs = n(),
    na_pct = 100 * na_count / total_obs
  ) %>%
  arrange(desc(na_count))

na_by_year

##MISSING VALUE/ NA/ NULL country wise

na_by_country <- panel_long %>%
  group_by(`Country Name`) %>%
  summarise(
    na_count = sum(is.na(value)),
    total_obs = n(),
    na_pct = 100 * na_count / total_obs
  ) %>%
  arrange(desc(na_count))

na_by_country

##MISSING VALUE/ NA/ NULL INDICATOR WISE

na_by_indicator <- panel_long %>%
  group_by(indicator) %>%
  summarise(
    na_count = sum(is.na(value)),
    total_obs = n(),
    na_pct = 100 * na_count / total_obs
  ) %>%
  arrange(desc(na_pct))

na_by_indicator

na_indicator_year_wide <- panel_long %>%
  group_by(indicator, YEAR) %>%
  summarise(na_count = sum(is.na(value)), .groups = "drop") %>%
  pivot_wider(
    names_from = YEAR,
    values_from = na_count,
    values_fill = 0
  )

na_indicator_year_wide
##

na_indicator_country <- panel_long %>%
  filter(is.na(value)) %>%
  group_by(indicator,`Country Name`) %>%
  summarise(
    missing_count = n(),
    .groups = "drop"
  ) %>%
  arrange(indicator, desc(missing_count))

na_indicator_country
print(na_indicator_country, n = Inf)


##yearwise of above

na_country_year <- panel_long %>%
  filter(`Country Name` == "Ethiopia", is.na(value)) %>%
  arrange(indicator, YEAR)

na_country_year

##YEAR-WISE MISSING INDICATOR

na_country_indicator_years <- panel_long %>%
  filter(is.na(value)) %>%
  group_by(`Country Name`, indicator) %>%
  summarise(
    missing_years = paste(sort(unique(YEAR)), collapse = ", "),
    missing_count = n(),
    .groups = "drop"
  ) %>%
  arrange(`Country Name`, desc(missing_count))

na_country_indicator_years
print(na_country_indicator_years, n = Inf)

#INDICATOR WISE
panel_long %>%
  group_by(indicator) %>%
  summarise(
    non_missing = sum(!is.na(value)),
    total = n(),
    coverage_pct = 100 * non_missing / total
  ) %>%
  arrange(coverage_pct)

#INDICATOR-BINARY MATRIX
na_country_year_wide <- panel_long %>%
  mutate(missing = ifelse(is.na(value), 1, 0)) %>%
  group_by(`Country Name`, YEAR) %>%
  summarise(missing_count = sum(missing), .groups = "drop") %>%
  tidyr::pivot_wider(
    names_from = YEAR,
    values_from = missing_count,
    values_fill = 0
  )

na_country_year_wide
print(na_country_year_wide, n = Inf)

#Visually
install.packages("naniar")
library(naniar)
library(dplyr)
library(tidyr)
library(ggplot2)

gg_miss_var(panel, show_pct = TRUE)
gg_miss_fct(panel, fct = `Country Name`)

#MISSING DATA % BY YEAR
ggplot(na_by_year, aes(x = YEAR, y = na_pct)) +
  geom_col() +
  labs(
    title = "Missing Data Percentage by Year",
    y = "Missing (%)",
    x = "Year"
  ) +
  theme_minimal()


#MISSING DATA % BY COUNTRY
ggplot(na_by_country, aes(
  x = reorder(`Country Name`, na_pct),
  y = na_pct
)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Missing Data Percentage by Country",
    y = "Missing (%)",
    x = "Country"
  ) +
  theme_minimal()

#MISSING DATA % BY INDICATORWISE

ggplot(na_by_indicator, aes(
  x = reorder(indicator, na_pct),
  y = na_pct
)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Missing Data Percentage by Indicator",
    y = "Missing (%)",
    x = "Indicator"
  ) +
  theme_minimal()

#FIRST GOOD YEAR
#Example: keep years where ≥ 80% of indicators are present
coverage_by_year <- panel_long %>%
  group_by(YEAR) %>%
  summarise(
    coverage = mean(!is.na(value))
  )

coverage_by_year %>%
  filter(coverage >= 0.80) %>%
  summarise(first_good_year = min(YEAR))

library(dplyr)
library(tidyr)
library(ggplot2)

year_indicator <- panel %>%
  pivot_longer(-c(`Country Name`, YEAR),
               names_to = "indicator",
               values_to = "value") %>%
  group_by(YEAR, indicator) %>%
  summarise(non_missing = sum(!is.na(value)), .groups = "drop")

ggplot(year_indicator, aes(x = YEAR, y = indicator, fill = non_missing)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = "Data Availability: Year × Indicator",
       fill = "Non-missing\ncountries") +
  theme_minimal()

country_indicator <- panel %>%
  pivot_longer(-c(`Country Name`, YEAR),
               names_to = "indicator",
               values_to = "value") %>%
  group_by(`Country Name`, indicator) %>%
  summarise(non_missing = sum(!is.na(value)), .groups = "drop")

ggplot(country_indicator,
       aes(x = indicator, y = `Country Name`, fill = non_missing)) +
  geom_tile() +
  scale_fill_viridis_c() +
  labs(title = "Data Coverage: Country × Indicator",
       fill = "Years\navailable") +
  theme_minimal()