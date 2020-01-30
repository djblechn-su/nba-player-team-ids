# NBA Player and Team ID Database

## Intro

This project allows users to easily access a wide-variety of in-depth stats in one location. Currently, advanced NBA stats are spread out across various websites such as: ESPN, NBA.com, Basketball Reference and Spotrac. The main issue with the data being spread out is that it makes it especially difficult to scrape and analyze. Our project collects player IDs and puts them in one location. Thus, this will allow us to have all the advanced NBA metrics in one database that is easily accessible. All the data in one place leads to a reduction in the time it takes to scrape it. The new central location of the advanced metrics will allow for basketball statistics to be scraped more easily. Data is up-to-date as of the beginning of the 2019-2020 NBA season.

To scrape player data from each key basketball statistics website (https://stats.nba.com/, https://www.basketball-reference.com/, http://www.espn.com/nba/statistics/rpm, https://www.spotrac.com/nba/), we used R packages such as "rvest", "XML", and "RSelenium" to gather important information from each site. For each player we scraped their name (according to the site), link, ID (last few characters of link), and birth date (if available) to be able to match tables from different sites. Data was merged by name and birth date, but due to small differences in naming, some merging was done by hand. The corresponding code to scrape each website is provided, so we encourage users to utilize this code to scrape following years of data.

To gather the data necessary for identifying each team, we first went to every major basketball statistics website and examined the unique URLs of each team page on their respective websites. Then, we found what parts of the URL make each page unique from each other for the specific websites and logged those changes in excel. For example, the URL for the Los Angeles Clippers on basketball-reference is https://www.basketball-reference.com/teams/LAC/, while the URL for the Los Angeles Lakers is https://www.basketball-reference.com/teams/LAL/. We noted the difference at the end of each URL for each team, so that each URL would be accessible when plugging in the different endings, and did this for each website listed.

## Variables:

### NBA_Player_IDs.csv

* BBRefName – player name according to Basketball Reference
* BBRefLink – player link according to Basketball Reference
* BBRefID – player ID according to Basketball Reference
* BBRefBirthDate – player birth date according to Basketball Reference
* NBAName – player name according to NBA
* NBALink – player link according to NBA
* NBAID – player ID according to NBA
* NBABirthDate – player birth date according to NBA
* ESPNName – player name according to ESPN (RPM)
* ESPNLink – player link according to ESPN (RPM)
* ESPNID – player ID according to ESPN (RPM)
* ESPNBirthDate – player birth date according to ESPN (RPM)
* SpotracName – player name according to Spotrac
* SpotracLink – player link according to Spotrac
* SpotracID – player ID according to Spotrac

### NBA_Team_IDs.csv

* _**Season**_ – first year of season (ex. 2019-2020 season would be 2019)
* *League*	 - NBA or ABA
* BBRef_Team_Name – team name according to Basketball Reference for given season
* BBRef_Team_Abbreviation – team abbreviation according to Basketball Reference for given season
* Current_BBRef_Team_Name – current (2019-2020) team name according to Basketball Reference for given season
* Current_BBRef_Team_Abbreviation – current (2019-2020) team abbreviation according to Basketball Reference
* ESPN_Current_Link_ID – current (2019-2020) team link ID according to ESPN
* NBA_Current_Link_ID – current (2019-2020) team link ID according to NBA
* Spotrac_Current_Link_ID – current (2019-2020) team link ID according to Spotrac

## Conclusion

By taking note of the differences in how each website identifies players and teams, we were able to effectively bring all of the information from each site into one place. Bringing this data into one location will streamline the data gathering process for future research projects.
