# Author: Kamila Janmohamed
# Purpose: Clean user location for october 2017 tweets

# Load packages -----------------------------------------------------------
library(dplyr)
library(stringr)
library(countrycode)
library(fst)
library(data.table)
library(maps) # for data(world.cities)
#library(googleLanguageR)
#library(cld2)



# *************************************************************************
# LOA DATA ----
# *************************************************************************

tweets <- read.fst("data/intermediate/twitter/tweetsOct2017.fst", as.data.table = TRUE,
                    columns = c("user_location"))

# To save time only looking at unique locations, later will merge with full set of tweets
tweets <- unique(tweets)

# country and city list
data(world.cities)
cities <- world.cities

# country list 2
countriesData <- read.csv("data/raw/twitter/Countries.csv", header = T)

# US state abbreviations
usa <- read.csv("data/raw/twitter/StatesUSA.csv", header = T)
names(usa)[1] = "State"


# *************************************************************************
# PREPARE ----
# *************************************************************************

# Create matching & output columns ----------------------------------------
tweets[, location := toupper(user_location)]
tweets[, location := str_replace(location, ",", ",")]
tweets[, location := iconv(location,to="ASCII//TRANSLIT")]

# Removing everything besides spaces and commas
tweets[, location := gsub("/"," ", location)]
tweets[, location := gsub("[^[:alnum:][:space:]\\,\\s\\b]","", location)]
tweets[, location :=  str_squish(location)]




# *************************************************************************
# STEP 1: MATCH COUNTRY NAMES ----
# *************************************************************************

# .prepare countries 
# .........................................................................

tweets[, country := ""]

cities$country.etc <- toupper(gsub("[[:punct:]\n]","",cities$country.etc))
cities$name <- toupper(gsub("[[:punct:]\n]","",cities$name))
cities$country.etc[cities$country.etc == "USA"] <- "US"

countriesData$Name <- toupper(gsub("[[:punct:]\n]","",countriesData$Name))
countriesData$Name[countriesData$Name == "UNITED STATES"] <- "US"
countriesData$Name[countriesData$Name == "UNITED KINGDOM"] <- "UK"

usa$State <- toupper(usa$State)

# Match cities by country name, strict word boundaries -------------
  # find country names that are also city names. exclude these.
intersect(unique(cities$country.etc), unique(cities$name))

# None of these seem problematic, but Georgia USA could be read as Georgia the country. 
#New Jersey can be mistaken for Jersey, so exclude both for now
excludeCityCountry = c("GEORGIA","JERSEY")


# .assign ----
# .........................................................................


# Run through countries in city and country lists
countries = unique(sort(c(cities$country.etc[!cities$country.etc %in% excludeCityCountry],
                          countriesData$Name[!countriesData$Name %in% excludeCityCountry])))
countriesPastedBreaks  = paste0("\\b", paste(countries, collapse = "\\b|\\b"), "\\b")
countriesPasted  = paste(countries, collapse = "|")


# If more than one match -> no country (one minute)
tweets[, count := stringr::str_count(location, countriesPastedBreaks)]

# Quicker than using countriesPastedBreaks. Only keeping cases where match exactly one country
tweets[count==1, country := gsub(paste0(".*\\b((", countriesPasted,  "))\\b.*"), "\\1", location)]
tweets[, count := NULL]

# assign "new mexico" to the US instead of Mexico
tweets[grepl("NEW MEXICO", location, fixed=TRUE), country := "US"]



# *************************************************************************
# STEP 2: US STATES ----
# *************************************************************************

# Matching US terms -------------------------------------------------------
# This need not be only for cities with an assigned country as some cities, like Romania, pick up states and american cities
statesPasted  = paste(usa$State, collapse = "|")
tweets[grepl(paste0("\\b(", statesPasted,  ")\\b"), location, perl=TRUE), country := "US"]

# match by US state abbreviations
# First, match by raw "user_location" column for instances of "city, ABRV"
# This need not be only for cities with an assigned country as some cities, like Romania, pick up states and american cities
stateCodesPasted  = paste(c(paste0("\\s*,\\s*", usa$Code), paste0(",", usa$Code)), collapse = "|")
tweets[grepl(paste0("\\b(", stateCodesPasted,  ")\\b"), location, perl=TRUE), country := "US"]

# This need not be only for cities with an assigned country as some cities, like Romania, pick up states and american cities
usTermsPasted <- paste0(c("USA", "AMERICA", "BAY AREA", "PHILLY", "JERSEY", "NYC", "ATL", 
                          "BROOKLYN", "ST LOUIS", "VEGAS"), collapse = "|")
tweets[grepl(paste0("\\b(", usTermsPasted,  ")\\b"), location), country := "US"]

# Without breaks
tweets[country=="" & grepl("UNITED STATES", tweets$location), country := "US"]




# *************************************************************************
# STEP 3: MATCH CITY NAMES ----
# *************************************************************************

# .city ----
# .........................................................................

# Remove duplicate city names by dropping the one with the lower population (cities dataset)

# Get all cities with non-unique names
duplicates <- cities %>%
  group_by(name) %>%
  filter(n()>1)

# Drop the city with the smaller population
largerDup <- duplicates %>%
  arrange(desc(pop)) %>%
  arrange(name) %>%
  filter(!duplicated(name))

# Get all cities with unique names
uniqueCities <- cities %>%
  group_by(name) %>%
  filter(n() <= 1)

# Merge unique cities with larger population duplicates
allCities <- rbind(largerDup, uniqueCities) %>%
  arrange(name) %>% 
  mutate(nameLength = nchar(name)) %>% 
  as.data.table()


# Drop cities that sound like english words/are contained in larger, more common cities
commonWords = c("ALA", "ARE","LOO", "MOE", "AESPA", "LIPA", "DUA", "NOO", "LUKE", "RAJA", "TORI", "TURI", "HAT", 
                "RACE", "IG", "STORE", "HELLA", "FAG", "RANI", "BOO", "GOT", "II", "BAY", "WE", "BORN", "SPRINGS", 
                "SAN", "ANGELES", "SANTA", "IMPERIAL", "CAN", "OF", "TUT", "VAN", "ZARA", "ICO", "IPU", "ITU", "CALI", 
                "SINCE", "BRONTE", "ROSA", "FLORIDA", "BAND", "CAROLINA", "LOS", "SAO", "YET", "HELL", "STREET", "FOREST", 
                "NOVA", "GOD", "PARADISE", "METRO","LINE", "MAN", "BEST", "ESSEX", "BAR", "HOPE", "SIN", "TOWER", "MOST",
                "LALA", "INDEPENDENCE", "INDEPENDENCIA", "INDEPENDENTA", "MUCH", "MANY", "MOBILE", "MANGO",
                allCities[pop<1000], allCities[nameLength<=2, name] )

allCities <- allCities[! name %in% commonWords & country.etc != "NETHERLANDS ANTILLES"]
allCities[nameLength==3][order(-pop)]

# Cities with country names. Remove these, the only major issue are AERMNIA COLOMBIA and BENIN NIGERIA
allCities = allCities[!name %in% c(countries, "USA")]

tweets[grepl("ARMENIA.*COLOMBIA", location), location := "COLOMBIA"]
tweets[grepl("BENIN.*NIGERIA", location), location := "NIGERIA"]
       
# Match by cities in Georgia first - there was an issue with this earlier
citiesGeorgiaPasted  = paste(allCities$name[allCities$country.etc == "GEORGIA"], collapse = "|")
tweets[country=="" & grepl(paste0("\\b(", citiesGeorgiaPasted,  ")\\b"), tweets$location), country := "Georgia"]


# There are cities called York and Orleans
tweets[grepl("NEW YORK", location, fixed=TRUE), country := "US"]
tweets[grepl("NEW ORLEANS", location, fixed=TRUE), country := "US"]



# This takes 10 minutes
#citiesPastedBreaks <- paste0("\\b", paste(unique(allCities$name), collapse = "\\b|\\b"), "\\b")  
#system.time(tweets[country!="", count := stringr::str_count(location, citiesPastedBreaks)])
#tweets[, table(count)]
#tweets[count==3]



# Match cities by airport code -> countrycode -> countryname
groupSize = 200
iter = ceiling(length(allCities$name)/groupSize)
tweets[, countCities := 0]
# About 5 minutes
for (i in 1:iter) {
  minIndex = 200*(i-1)+1
  maxIndex = min(i*200, length(allCities$name))
  print(paste("min", minIndex, "max", maxIndex, timestamp(), sep=" "))
  citiesPasted <- paste(unique(allCities$name[minIndex:maxIndex]), collapse = "|")
  citiesPastedBreaks <- paste0("\\b", paste(unique(allCities$name[minIndex:maxIndex]), collapse = "\\b|\\b"), "\\b")  
  
  tweets[country=="", countCurrent := stringr::str_count(location, citiesPastedBreaks)]
  tweets[country=="", countCities := countCities + countCurrent]
  tweets[country=="" & countCurrent==1, city := gsub(paste0(".*\\b((", citiesPasted,  "))\\b.*"), "\\1", location)]
}



tweets = merge(tweets, allCities[, list(city=name, countryFromCity = country.etc, pop)], by="city", all.x=TRUE)
tweets[!is.na(city) & countCities==1, country := countryFromCity]

# Check cities
#countCity = tweets2[, .N, by=c("city", "pop")]
#countCity[order(-N)][1:100]





# *************************************************************************
# STEP 4: ADDITIONAL COMMON MATCHES ----
# *************************************************************************

# Manually matching United Kingdom terms ----------------------------------
ukTermsPasted <- paste(c("BRITAIN", "SCOTLAND", "ENGLAND", "WALES"), collapse = "|")
tweets[country=="" & grepl(paste0("\\b(", ukTermsPasted,  ")\\b"), tweets$location), country := "UK"]

tweets[country=="" & grepl("UNITED KINGDOM", tweets$location), country := "UK"]

# *shire areas should be asigned to the UK. "shire" (as in the hobbit) should not. 
tweets$country[which(grepl("SHIRE", tweets$location) == 1 & grepl("\\bSHIRE\\b", tweets$location) == 0 & tweets$country == "")] <- "UK"

# Address endonyms and misc names--------------------------------------------------------

matchTerms <- function(DT, countryName, terms) {
  termsPaste = paste0(terms, collapse = "|")
  DT[country == "" & grepl(termsPaste, location), country := countryName]  
  return(DT)
}

tweets <- matchTerms(tweets, "SPAIN", c("ESPANA", "CATALUNYA", "CATAL", "MALLORCA", "MADRID"))
tweets <- matchTerms(tweets, "GERMANY", c("DEUTSCHLAND", "MUNCHEN", "NIEDERSACHSEN", "NORD", "ANTWERP", "BAYERN", "KOLN", "HANNOVER"))
tweets <- matchTerms(tweets, "SWEDEN", c("SVERIG"))
tweets <- matchTerms(tweets, "NETHERLANDS", c("NEDERLAND", "ZUID", "MONTFER", "HILVERSUM", "HOLLAND"))
tweets <- matchTerms(tweets, "BELGIUM", c("BELGI", "BRUX", "BRUSS"))
tweets <- matchTerms(tweets, "CZECHOSLOVAKIA", c("SLOVA"))
tweets <- matchTerms(tweets, "INDIA", c("BHARAT", "GUJARAT", "KOLKATA", "MUMBAI", "LUNAWADA", "BANGALORE", "BENGALURU", "KHAND", "PUNJAB", "TAMIL", "TELANGANA", "MANGALORE", "MAYANAGRI", "DELHI", "AHMED", "PRADESH", "HINDU", "MADRAS", "RAJA", "DEHRA", "KARAWA", "HARYANA", "PURWANCHA", "MAHARASHTRA", "ODISHA", "COIMBATORE", "BANGAL", "KERALA", "KARNATAKA"))
tweets <- matchTerms(tweets, "NEW ZEALAND", c("AOTEAROA", "\\bNZ\\b", "AOTEAROA"))
tweets <- matchTerms(tweets, "ITALY", c("NAPOLI", "ITALI", "MILAN", "TOSCA", "FIRENZ", "TORIN"))
tweets <- matchTerms(tweets, "SWITZERLAND", c("SUIS", "SCHWEIZ", "ZURIC", "GENEVE"))
tweets <- matchTerms(tweets, "FINLAND", c("SUOMI"))
tweets <- matchTerms(tweets, "AUSTRIA", c("OSTERREICH", "WIEN"))
tweets <- matchTerms(tweets, "FRANCE", c("ISERE", "BRETAGNE", "PARIS", "LANDES", "PROVENCEALPESCOTE"))
tweets <- matchTerms(tweets, "AUSTRIA", c("OSTERREICH", "WIEN"))
tweets <- matchTerms(tweets, "DENMARK", c("DANMARK", "KOBENHAVN"))
tweets <- matchTerms(tweets, "PHILLIPPINES", c("MAKATI", "BANGSAMORO"))
tweets <- matchTerms(tweets, "AUSTRIA", c("OSTERREICH", "WIEN"))
tweets <- matchTerms(tweets, "POLAND", c("POLSKA", "WARSZAWA", "KRAKOW"))
tweets <- matchTerms(tweets, "JAPAN", c("JAP", "JPN", "KANAGAWA", "NAWA", "GIAPP", "OSAKA", "TOKYO", "IWATE"))
tweets <- matchTerms(tweets, "KOREA SOUTH", c("SEOUL", "SOUTH KOREA"))
tweets <- matchTerms(tweets, "SOUTH AFRICA", c("BORWA"))
tweets <- matchTerms(tweets, "CANADA", c("ONTARIO", "ALBERTA", "EDMONTON", "QUEBEC", "NEWFOUNDLAND", "LABRADOR", "ALGONQUIN", "NOVA SOCTIA", "ALGONQUIN", "SASKATCHEWAN", "BURNABY"))
tweets <- matchTerms(tweets, "MEXICO", c("COYOACAN", "MEX", "MX", "TENOCHTITLAN"))
tweets <- matchTerms(tweets, "TURKEY", c("TURKIYE"))
tweets <- matchTerms(tweets, "TUNISIA", c("TUNISIE"))
tweets <- matchTerms(tweets, "DOMINICAN REPUBLIC", c("DOMINICANA"))
tweets <- matchTerms(tweets, "SAUDI ARABIA", c("JEDDA"))
tweets <- matchTerms(tweets, "UNITED ARAB EMIRATES", c("\\bUAE\\b"))
tweets <- matchTerms(tweets, "ISRAEL", c("TEL AVIV"))
tweets <- matchTerms(tweets, "HUNGARY", c("MAGYARORSZAG"))
tweets <- matchTerms(tweets, "BRAZIL", c("BRASIL", "DISTRITO"))
tweets <- matchTerms(tweets, "CZECH REPUBLIC", c("CESKA"))
tweets <- matchTerms(tweets, "LEBANON", c("BEIRUT"))
tweets <- matchTerms(tweets, "MEXICO", c("MACXICO"))
tweets <- matchTerms(tweets, "KOREA SOUTH", c("REPUBLIC OF KOREA", "SKOREA", "^KOREA$"))
tweets <- matchTerms(tweets, "KOREA NORTH", c("NORTH KOREA"))
tweets <- matchTerms(tweets, "ETHIOPIA", c("ADDIS ABABA"))

# *************************************************************************
# STEP 5: FIX ISSUES ----
# *************************************************************************

# Fix Estonia -------------------------------------------------------------
# Estonian city Navi mislabelleing Navi Mumbai, "anna" mislabelling Chennai, city "Are" picking up spam, city "Nova" mislavelling nova scotia, canada. "ala" picking up alabama
tweets$country[which(grepl("NOVA SCOT|SCOTIA NOVA", tweets$location) == 1 & tweets$country == "ESTONIA")] <- "CANADA"
tweets$country[which(grepl("\\bALA\\b|LAKE VILLA", tweets$location) == 1 & tweets$country == "ESTONIA")] <- "US"
tweets$country[which(grepl("\\KUNDA\\b|MUMBAI|CHENNAI|MALDA", tweets$location) == 1 & tweets$country == "ESTONIA")] <- "INDIA"
tweets$country[which(grepl("NOVA IGUACU|BRASIL", tweets$location) == 1 & tweets$country == "ESTONIA")] <- "BRAZIL"
tweets$country[which(grepl("VILLA ", tweets$location) == 1 & tweets$country == "ESTONIA")] <- "ARGENTINA"

# Fix Brazil --------------------------------------------------------------
tweets$country[which(grepl("THE ", tweets$location) == 1 & tweets$country == "BRAZIL")] <- ""


# Misc --------------------------------------------------------------------
tweets$country[which(grepl("HEBRON ", tweets$location) == 1 & tweets$country == "PALESTINE")] <- "US"



# *************************************************************************
# MERGE FULL DATA ----
# *************************************************************************

tweetsAll <- read.fst("data/intermediate/twitter/tweetsOct2017.fst", as.data.table = TRUE,
                   columns = c("user_location"))
n = nrow(tweetsAll)
tweetsAll = merge(tweetsAll, tweets[, list(user_location, country)], by="user_location", all.x=TRUE)
stopifnot(n == nrow(tweetsAll))


saveRDS(tweetsAll, "data/intermediate/twitter/tweetsAssignedOct2017.rds")


# Random sample for test
if (0) {
  
  allCities[name=="MANGO"]
  
  # Get random samples ------------------------------------------------------
  unassigned <- tweets[(tweets$country == ""),] %>%
    select("location", "country", "user_location") %>%
    na.omit()
  sample1 <- unassigned[sample(nrow(unassigned), 50), ]
  View(sample1[,c("country", "location", "user_location")])
  
  assigned <- tweets[(tweets$location != "" & tweets$country != ""),] %>%
    select("location", "country") %>%
    na.omit()
  
  sample2 <- assigned[sample(nrow(assigned), 50), ] %>% 
    select("location", "country")
  
  # Mistakes 
  # VIA FONTANELLATO 69 ROMA
  # BETWEEN A ROCK A HARD PLACE
  
  # Save data -------------------------------------------------------------
  write.csv(sample1, "data/notes/twitter/sampleUnassignedOct2017.csv", row.names = F)
  write.csv(sample2, "data/raw/twitter/sampleAssignedOct2017", row.names = F)
}




