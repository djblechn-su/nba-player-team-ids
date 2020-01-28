# Scrape Links - BBRef

library(dplyr)
library(rvest)
library(XML)
library(zoo)

# Create Function to Scrape Player Links
scrape_nba_main <- function(yr){
  # Create URL
  url <- paste0('https://www.basketball-reference.com/leagues/NBA_', yr, '_per_game.html')
  webpage <- read_html(url)
  
  # Scrape All Player Links on Page
  webpage %>%
    html_nodes(xpath = "//td/a") %>% 
    html_attr("href") -> links
  links <- links[grepl("/players", links)]
  links <- links[!duplicated(links)]
  
  # Scrape Player Information - Age + Name
  webpage %>%
    html_nodes("table") %>%
    .[1] %>%
    html_table(fill = TRUE) %>%
    as.data.frame() -> year
  year <- year %>% filter(Player != "Player")
  year <- year[!duplicated(year[c('Player', 'Age')]),]
  year <- year[,c(2,4)]
  # Fix Matt Thomas
  year <- year %>% filter(!(Player == 'Matt Thomas' & Age == ''))
  year$Link <- links
  year$Age <- NULL
  BBRefID <- strsplit(year$Link, '\\/')
  BBRefID <- sapply(BBRefID, function(x) x[4])
  BBRefID <- gsub(".html", "", BBRefID)
  year$BBRefID <- BBRefID
  # Return Data
  return(year)
}

# Run Code For 1950 to 2019
all_data <- {}
years_nba <- 1950:2019

for(i in 1:length(years_nba)){
  data <- scrape_nba_main(years_nba[i])
  all_data[i] <- list(data)
}

all_bb_ref <- do.call('rbind', all_data)
all_bb_ref <- all_bb_ref[!duplicated(all_bb_ref$BBRefID),]
all_bb_ref <- all_bb_ref[order(all_bb_ref$BBRefID),]

# Scrape Player Birthdays
urls <- paste0('https://www.basketball-reference.com', all_bb_ref$Link)
birthdays <- {}

for(i in 1:nrow(all_bb_ref)){
  webpage <- read_html(urls[i])
  webpage %>%
    html_nodes(xpath = '//*[@id="necro-birth"]') %>%
    html_text() -> bd
  bd <- gsub('\n', '', bd)
  bd <- gsub("\\s+", " ", bd)
  bd <- trimws(bd)
  bd <- as.Date(bd, format = '%B %d, %Y')
  bd <- if(length(bd) == 0){
    NA
  } else {
    bd
  }
  
  birthdays[i] <- list(bd)
}

# Format Complete Table
birthdays <- as.Date(unlist(birthdays))
all_bb_ref$BirthDate <- birthdays
all_bb_ref$Player <- gsub('\\*', '', all_bb_ref$Player)
all_bb_ref$Link <- paste0('https://www.basketball-reference.com', all_bb_ref$Link)
names(all_bb_ref) <- c('BBRefName', 'BBRefLink', 'BBRefID', 'BBRefBirthDate')

write.csv(all_bb_ref, 'BBRefIDs.csv', row.names = F)
