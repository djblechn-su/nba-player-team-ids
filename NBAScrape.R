# Scrape Links - NBA.com

library(RSelenium)
library(rvest)
library(XML)

# Use Selenium to Scrape NBA IDs
rD <- rsDriver(browser="chrome", chromever = '77.0.3865.10')
remDr <- rD$client

remDr$navigate('https://stats.nba.com/players/list/?Historic=Y')
page <- remDr$getPageSource()[[1]]
doc <- htmlParse(page)
links <- as.character(xpathSApply(doc, "//a/@href"))
links <- links[grepl("/player/[0-9]", links)]

names_list <- {}
for(i in 1:25){ # No players have last name starting with X
  names <- remDr$findElements(using = 'xpath', paste0("/html/body/main/div[2]/div/div[2]/div/div/section[",i,"]"))
  names <- unlist(lapply(names, function(x){x$getElementText()}))
  names <- unlist(strsplit(names, '\n'))
  names <- names[nchar(names) > 1]
  names_list[i] <- list(names)
}

remDr$close()
rD$server$stop()

# Format Names
names <- unlist(names_list)
names <- strsplit(names, ', ')
first_names <- sapply(names, function(x) x[2])
last_names <- sapply(names, function(x) x[1])
names <- paste(first_names, last_names)
links <- paste0('https://stats.nba.com', links)
ids <- as.numeric(gsub("[^[:digit:]]", "", links))


nba_ids <- data.frame(NBAName = names, NBALink = links, NBAID = ids)
nba_ids$NBALink <- as.character(nba_ids$NBALink)

# Scrape Birthdays
birthdays <- {}
for(i in 1:nrow(nba_ids)){
  webpage <- read_html(nba_ids$NBALink[i])
  birthdays[i] <- webpage %>%
    html_node(xpath = '/html/body/main/div[2]/div/div/div[2]/div/div/div/div[2]/div[2]/div[4]/span') %>%
    html_text()
}

nba_ids$NBABirthDate <- birthdays
nba_ids$NBABirthDate <- as.Date(nba_ids$NBABirthDate, format = '%m/%d/%Y')

write.csv(nba_ids, 'NBAIDs.csv', row.names = F)
