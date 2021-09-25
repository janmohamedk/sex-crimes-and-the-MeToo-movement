# Author: Kamila Janmohamed
# Purpose: Track how interest level varies by MeToo interest indicator variable 
library(countrycode)
library(tidyverse)
library(haven)

df <- read_dta("data/clean/googleTrends/gtrends_data_2010_2018.dta")

# create a variable that tracks changes in status between indicators
df <- df %>%
  select(country_code, above_med_metoo_imme, above_med_imme_abs_beta, imme_metoo, imme_abs_beta_sh_sa) %>%
  unique() %>%
  mutate(Class = case_when(
    (above_med_metoo_imme == 0 & above_med_imme_abs_beta == 0) ~ "Always weak",
    (above_med_metoo_imme == 1 & above_med_imme_abs_beta == 1) ~ "Always strong",
    (above_med_metoo_imme == 0 & above_med_imme_abs_beta == 1) ~ "Weak to strong",
    (above_med_metoo_imme == 1 & above_med_imme_abs_beta == 0) ~ "Strong to weak"
  ),
  country = countrycode(country_code, "iso2c", "country.name"))


# filter out sweden because it's an outlier
df <- df %>%
  filter(country_code != "SE")

# visualise distribution of countries and underlying interest measures
ggplot(df, aes(imme_metoo, imme_abs_beta_sh_sa, label = country_code)) + 
  geom_point() + 
  geom_text_repel() + 
  theme_bw()

# visualise distribution of countries and underlying interest measures by change in status
ggplot(df, aes(imme_metoo, imme_abs_beta_sh_sa, label = country_code)) + 
  geom_point(aes(colour = Class, size = 2)) + 
  geom_text_repel() + 
  theme_bw() + 
  guides(size = 'none', 
         colour = guide_legend(override.aes = list(size=2))) + 
  theme(legend.position = "bottom")

