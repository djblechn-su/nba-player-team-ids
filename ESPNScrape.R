# Scrape Links - ESPN.com

library(rvest)
library(XML)
library(httr)
library(tidyverse)
library(RSelenium)

# Set Team Abbreviations
team_abbs <- c('atl', 'bkn', 'bos', 'cha', 'cle', 'chi', 'dal', 'den', 'det', 'gsw', 'hou',
               'ind', 'lac', 'lal', 'mem', 'mia', 'mil', 'min', 'no', 'ny', 'okc', 'orl', 'phi',
               'phx', 'por', 'sa', 'sac', 'tor', 'utah', 'wsh')

# Scrape Data for Seasons with ESPN RPM (2012 to 2020)
seasons <- c(2012:2020)
urls <- {}
n <- 0
for(i in 1:length(team_abbs)){
  for(j in 1:length(seasons)){
    n = n + 1
    urls[n] <- paste0('https://www.espn.com/nba/team/stats/_/name/', team_abbs[i], '/season/', seasons[j], '/seasontype/2')
  }
}

# Scrape Information from Player Links
espn_links <- {}
start <- 1
for(i in start:length(urls)){
  webpage <- read_html(as.character(urls[i]))
  links <- webpage %>%
    html_nodes(xpath = "//td/span/a") %>% 
    html_attr("href")
  links <- links[!duplicated(links)]
  names <- webpage %>%
    html_nodes(xpath = "//td/span/a") %>%
    html_text()
  names <- names[!duplicated(names)]
  links <- data.frame(link = links, name = names)
  espn_links[i] <- list(links)
  start <- start + 1
}

# Rbind All Links
library(plyr)
espn_links_all <- ldply(espn_links, data.frame)
detach('package:plyr')
names(espn_links_all) <- c('espn_link', 'espn_name')
espn_links_all <- as.data.frame(espn_links_all[!duplicated(espn_links_all$espn_link),])


espn_bio_links <- gsub('http://www.espn.com/nba/player/', '', as.character(espn_links_all$espn_link))
espn_bio_links <- paste0('http://www.espn.com/nba/player/bio/', espn_bio_links)
player_bds <- {}

# Use Selenium to Scrape Birthday
rD <- rsDriver(browser="chrome", chromever = '77.0.3865.10')
remDr <- rD$client

# Run For All Links (May Crash)
for(i in 1:nrow(espn_links_all)){
  remDr$navigate(as.character(espn_bio_links[i]))
  Sys.sleep(5)
  birthday <- remDr$findElements(using = 'xpath', '//*[@id="fittPageContainer"]/div[2]/div[5]/div/div/section[1]/div')
  player_bds[i] <- unlist(lapply(birthday, function(x){x$getElementText()}))
}

player_bds_2 <- strsplit(player_bds, '\nDOB\n')
player_bds_3 <- sapply(player_bds_2, function(x) x[2])
player_bds_4 <- strsplit(player_bds_3, '\n')
player_bds_5 <- sapply(player_bds_4, function(x) x[1])
player_bds_6 <- trimws(gsub("\\(.*", "", player_bds_5))

remDr$close()
rD$server$stop()

# Format Complete Table
espn_links_all$espn_birthday <- player_bds_6
espn_links_all$espn_birthday <- as.Date(espn_links_all$espn_birthday, format = '%m/%d/%Y')

write.csv(espn_links_all, 'ESPNIDs.csv', row.names = F)
