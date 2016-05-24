# pinnacle.API
R Wrapper for the Pinnacle Sports API

The Pinnacle Sports ( www.pinnaclesports.com) manual can be found here :

http://www.pinnaclesports.com/en/api/manual

To use the Pinnacle Sports API you must have an account with Pinnacle Sports.

Please contact Pinnacle Sports directly at csd@pinnaclesports.com for all account questions.
Pinnacle Terms & Conditions:  http://www.pinnaclesports.com/en/termsandconditions

The API is not accessible  from all IP-Ranges , especially IP addresses from the UK and the USA are Geo IP blocked.

To install the newest version :

```r
devtools::install_github("marcoblume/pinnacle.API")
```
Or install a stable version from CRAN :
```r
install.packages("pinnacle.API")
```
Example Code
------------
``` r
library(pinnacle.API)
library(dplyr)
library(lubridate)
```
Please make sure that you understand the terms and conditions.
``` r
AcceptTermsAndConditions()
```
and then accept them. If AcceptTermsnAndConditions is not set to TRUE the functions will not run.
```r
AcceptTermsAndConditions(TRUE)
```
Your credentials are the username and password for logging into www.pinnaclesports.com.
``` r
SetCredentials("MyUserName","MyPassWord")
```

Pull the Sport Data and filter out the leagues that have lines for Badminton available.

```r
Sport_data <- GetSports() 
Badminton_ID <- Sport_data$SportID[Sport_data$SportName=="Badminton"]
League_data <- GetLeagues("Badminton")
active_leagues <- League_data %>% 
  filter(LinesAvailable == 1)
Badminton_League_Ids <- active_leagues$LeagueID
```

Use the showOddsDF() function to aggregate all the data into a nicer data.frame.
```r
badminton_data <- showOddsDF(sportname = "Badminton" , Badminton_League_Ids )
```
Convert  the dates into POSIX
```r
## Convert Times to Posix
badminton_data$StartTime <- as.POSIXct(badminton_data$StartTime,format="%Y-%m-%dT%H:%M:%S",tz="UTC")
badminton_data$cutoff <- as.POSIXct(badminton_data$cutoff,format="%Y-%m-%dT%H:%M:%S",tz="UTC")
```
This DF has all the necessary IDs and information that you can then pass to the PlaceBet() function to place your wagers.


Examples for Filter Settings on Soccer Data
--------------------------
use the same code as above and change the Sport from Badminton to Soccer.
```r
## Some Filter Suggestions to clean the Data 
soccer_filtered <- soccer_data %>% 
  ## Only Period "0" , the main period 
  filter(PeriodNumber == 0 ) %>% 
  ## No Live Games
  filter( LiveStatus != 1) %>% 
  ## No Corners
  filter(. , !grepl("Corner",HomeTeamName)) %>% 
  ## No Home vs Aways
  filter(. , !grepl("Home Team",HomeTeamName)) %>% 
  ## No advance Lines
  filter(. , !grepl("advance",HomeTeamName)) %>%
  ## No raise the cup lines
  filter(. , !grepl("raise",HomeTeamName)) %>% 
  ## Filter games past cutoff time
  filter(cutoff > as.POSIXlt(Sys.time(),tz="UTC")) %>%
  ## Filter games that are played in the next 24h
  filter(StartTime < as.POSIXlt(Sys.time(),tz="UTC")+hours(24) )
```
This is a filter Ideas for Live Games in Soccer. 
Modify showOddsDF() with ISLive= TRUE for a faster response if only Live Events are needed.
The League IDs are retrieved using GetLeagues().

```r
data <- showOddsDF(sportname = "Soccer" , Sport_Type_League_IDs , isLive = TRUE)

data %>%
      ## Only bet on Period "0"
      filter(PeriodNumber == 0 ) %>%
      ## Only Live Games
      filter( LiveStatus == 1) %>%
      ## Specific
      filter(homeScore + awayScore == 3 ) %>%
      filter(state == 1) %>%
      ## only from 17th min into state
      filter(elapsed  > 17)
```
To check all Running Wagers use GetBetsList() with betlist = "RUNNING". Below call will fetch all wagers that are RUNNING from the last 28 days.

```r
 betlist <- GetBetsList(betlist = "RUNNING",
                         fromDate = as.POSIXlt(Sys.Date(), tz = "UTC") - 28 * 24 * 60 * 60,
                         toDate = as.POSIXlt(Sys.Date(), tz = "UTC") + 24 * 60 * 60)
```
