# pinnacle.API
R Wrapper for the Pinnacle Sports API

The Pinnacle Sports ( www.pinnaclesports.com) manual can be found here :

http://www.pinnaclesports.com/en/api/manual

To use the Pinnacle Sports API you must have an account with Pinnacle Sports.

Please contact Pinnacle Sports directly at csd@pinnaclesports.com for all account questions.
Pinnacle Terms & Conditions:  http://www.pinnaclesports.com/en/termsandconditions

The API is not acceccsible from all IP-Ranges , especially IP addresses from the UK and the USA are Geo IP blocked.

Example Code
------------
``` r
library(pinnacle.API)
library(dplyr)
```
Please make sure that you understand the terms and conditions 
``` r
AcceptTermsAndConditions()
```
and then accept them. If AcceptTermsnAndConditions is not set to TRUE the functions will not run.
```r
AcceptTermsAndConditions(TRUE)
```
Your credentials are the username and password for logging into www.pinnaclesports.com
``` r
SetCredentials("MyUserName","MyPassWord")
```

Pull the Sport Data and filter out the leagues that have lines for Badminton availble

```r
Sport_data <- GetSports() 
Badminton_ID <- Sport_data$SportID[Sport_data$SportName=="Badminton"]
League_data <- GetLeagues("Badminton")
active_leagues <- League_data %>% 
  filter(LinesAvailable == 1)
Badminton_League_Ids <- active_leagues$LeagueID
```

Use the showOddsDF() function to aggregate all the data into a nicer data.frame
```r
badminton_data <- showOddsDF(sportname = "Badminton" , Badminton_League_Ids )
```
Converte  the dates into POSIX
```r
## Convert Times to Posix
badminton_data$StartTime <- as.POSIXct(badminton_data$StartTime,format="%Y-%m-%dT%H:%M:%S",tz="UTC")
badminton_data$cutoff <- as.POSIXct(badminton_data$cutoff,format="%Y-%m-%dT%H:%M:%S",tz="UTC")
```
This DF has all the necessary IDs and information that you can then pass to the PlaceBet() function to place your wagers.


Examples for Filter Settings on Soccer Data , use the same code as above and chang the Sport from Badminton to Soccer.
------------
```r
## Some Filter Suggestions to clean the Data 
soccer_filtered <- soccer_data %>% 
  ## Only bet on Period "0" 
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
  ## Filter cames past cutoff time
  filter(cutoff > as.POSIXlt(Sys.time(),tz="UTC")) %>%
  ## Filter games that are played in the next 24h
  filter(StartTime < as.POSIXlt(Sys.time(),tz="UTC")+hours(24) )
```
