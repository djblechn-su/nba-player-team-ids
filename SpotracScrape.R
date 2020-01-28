# Scrape Links - Spotrac

library(dplyr)
library(rvest)
library(XML)

# Set Spotrac Team IDs
spotrac_link_ids <- c("atlanta-hawks", "brooklyn-nets", "boston-celtics", "charlotte-hornets", "cleveland-cavaliers", "chicago-bulls", "dallas-mavericks", "denver-nuggets", "detroit-pistons", "golden-state-warriors", "houston-rockets", "indiana-pacers", "los-angeles-clippers", "los-angeles-lakers", "memphis-grizzlies", "miami-heat", "milwaukee-bucks", "minnesota-timberwolves", "new-york-knicks", "new-orleans-pelicans", "oklahoma-city-thunder", "orlando-magic", "philadelphia-76ers", "phoenix-suns", "portland-trail-blazers", "san-antonio-spurs", "sacramento-kings", "toronto-raptors", "utah-jazz", "washington-wizards")
years <- c(2000:2019)
links <- paste0("https://www.spotrac.com/nba/", spotrac_link_ids,"/cap/")
spotrac_links <- {}
n <- 0

for(i in 1:length(years)){
  for(j in 1:length(links)){
    n <- n + 1
    spotrac_links[n] <- paste0(links[j], years[i], '/')
  }
}

# Create Function to Scrape Links
scrape_spotrac_links <- function(link){
  webpage <- read_html(link)
  player_links <- webpage %>%
    html_nodes(xpath = '//td[1]//a') %>% 
    html_attr("href")
  players <- webpage %>%
    html_nodes(xpath = '//td[1]//a') %>% 
    html_text()
  player_df <- data.frame(name = players, link = player_links)
  player_df <- player_df %>% filter(link != '#')
  return(player_df)
}

spotrac_data <- {}

for(i in 1:length(spotrac_links)){
  data <- scrape_spotrac_links(spotrac_links[i])
  spotrac_data[i] <- list(data)
}

spotrac_data_df <- do.call('rbind', spotrac_data)
spotrac_data_df <- spotrac_data_df[!duplicated(spotrac_data_df$link),]

# Scrape Ages as Replacement for Birthday (Not Available on Spotrac)
age <- {}
for(i in 1:nrow(spotrac_data_df)){
  webpage <- read_html(as.character(spotrac_data_df$link[i]))
  age[i] <- webpage %>%
    html_nodes(xpath = '//*[@id="main"]/header/div[2]/div/div[1]/span[2]/text()') %>%
    html_text() %>%
    trimws() %>%
    as.numeric()
}

# Format Complete Table
spotrac_data_df$age <- age
spotrac_data_df$id <- gsub('https://www.spotrac.com/redirect/player/', '', spotrac_data_df$link)
spotrac_data_df$id <- gsub('\\/', '', spotrac_data_df$id)

write.csv(spotrac_data_df, 'SpotracIDs.csv', row.names = F)
