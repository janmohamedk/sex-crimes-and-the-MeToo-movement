# Author: Kamila Janmohamed
# Date: 7 Mar 2021
# Purpose: Plot scaled tweets for top 30 countries and 30 OECD for October 2017

library(ggplot2)
library(dplyr)

rm(list=ls()) 
source("code/MeToo_R/util/util.R"); beginLogging()
source("code/MeToo_R/util/utilLyx.R")


# Load data ---------------------------------------------------------------
month <- readRDS("data/clean/twitter/scaledGeoOct2017.rds")

month$country[month$country == "KOREA SOUTH"] <- "KOREA"

# Number of tweets
assignedTweetsOct17 <- sum(month$Freq)
saveToLyx(assignedTweetsOct17, "assignedTweetsOct", latexFile = "output/tex/plotTweetsScaledOct2017.tex", digits = 0)



# graph of top 30 countries
ggplot(month[1:30,], aes(x = reorder(country, tweetsPer1k), y = tweetsPer1k)) + 
  geom_bar(stat = "identity") +
  ylab("Tweets per 10,000 users") +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        axis.title.x=element_blank())
ggsave("output/figures/twitter/scaledTop30Oct2017.pdf", width=9, height=6)


# graph of me too countries
ggplot(na.omit(month), aes(x = reorder(country, tweetsPer1k), y = tweetsPer1k, fill = meToo)) +
  geom_bar(stat = "identity") +
  ylab("Tweets per 10,000 users") +
  scale_fill_manual("", values = c("strong" = "red", "weak" = "blue", "no data" = "lightgrey"), labels = c("No police data", "Strong MeToo Movement", "Weak MeToo Movement")) + 
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, hjust=1),
        legend.position = "bottom",
        axis.title.x=element_blank())
ggsave("output/figures/twitter/scaledOECDOct2017.pdf", width=9, height=6)


# .share OECD ----
# .........................................................................

month$inOECD <- !is.na(month$meToo)
numOfOECDCountriesTwitter <- sum(month[1:30,]$inOECD)

saveToLyx(numOfOECDCountriesTwitter, "numOfOECDCountriesTwitter", latexFile = "output/tex/plotTweetsScaledOct2017.tex", digits = 0)
