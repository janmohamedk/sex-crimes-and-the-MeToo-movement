# Author: Kamila Janmohamed
# Purpose: get ratio of differences in accused interest by country 

# Load packages -----------------------------------------------------------
library(tidyverse)


# Load data ---------------------------------------------------------------
data <- read_csv("data/intermediate/googleTrends/countryAccusedInterest.csv") %>%
  group_by(geo) %>%
  mutate(hits=replace(hits, hits=="<1", 0)) %>%
  mutate(hits = as.numeric(hits))

data_noHW <- data %>%
  filter(keyword != "harvey weinstein") %>% 
  group_by(geo) %>%
  summarise(max = max(hits))

data_HW <- data %>%
  filter(keyword == "harvey weinstein") %>% 
  group_by(geo) %>%
  summarise(max = max(hits))

ratio <- cbind(data_noHW, data_HW$max) %>%
  rename(localMax = max,
         weinsteinMax = `data_HW$max`) %>%
  mutate(ratio = localMax/weinsteinMax)

write.csv(ratio, "data/clean/googleTrends/countryInterestRatio.csv", row.names = F)


  
  

