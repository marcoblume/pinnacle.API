# Accessing the Pinnacle API
Nicholas Jhirad  
`r Sys.Date()`  

## The Pinnacle API package

This document covers version >= 2.0 of the package and is
intended to be an introduction to the package, it does **Not** cover all functions.

For a more detailed breakdown, we recommend you explore the functions in the package

The `pinnacle.API` package allows an R user to Access: 

* Pinnacle's API feed, 
* Pregame/Live Odds and Fixtures, 
* Personal Settled/Running Wagers, 
* Balance Information

While also allowing the usage of this data by 

* Placing wagers/parlays/teasers. 

Detailed information about what is available is in the Pinnacle API Manual:
https://www.pinnacle.com/en/api/manual


*** 

## Getting the Package

The most recent stable version is on CRAN, and can be installed with:



```r
install.packages('pinnacle.API')
```

Development versions are available via github, and can be installed with the devtools package



```r
install.packages('devtools')
devtools::install_github('marcoblume/pinnacle.API')
```

*** 

## Setup

the package depends on:

 * `data.table` version >= 1.10
 * `openssl`
 * `httr`
 * `jsonlite`
 * `uuid`
 * `purrr`
 * `magrittr`

load and configure it as follows:



```r
 library(pinnacle.API)
 AcceptTermsAndConditions(TRUE)
 SetCredentials()
```

You will be prompted for your username and password. This can also be done uninteractively with:



```r
 SetCredentials('USERNAME', 'PASSWORD')
```

## Basic Functions

*** 

### Get Client Balance:





```r
GetClientBalance()
```

```
## $availableBalance
## [1] 3896.54
## 
## $outstandingTransactions
## [1] 3522
## 
## $givenCredit
## [1] 1e+05
## 
## $currency
## [1] "USD"
```

*** 

### Get Sports:


```r
Sports <- GetSports()

head(Sports)
```


*** 

### Get Leagues:



```r
BasketBallLeagues <- GetLeaguesByID(4)

# Get first 5 entries Basketball Leagues
head(BasketBallLeagues)
```

*** 

### Get Fixtures:



```r
# Get Basketball Fixtures
BasketballFixtures <- GetFixtures(4)
head(BasketballFixtures)
```

*** 



```r
# Get Live Basketball Fixtures
LiveBasketballFixtures <- GetFixtures(4, islive = 1)
head(LiveBasketballFixtures)
```

*** 

### Get Odds:



```r
# Get Basketball Odds
BasketballOdds <- GetOdds(4)
head(BasketballOdds)
```

*** 



```r
# Get Live Basketball Odds
LiveBasketballOdds <- GetOdds(4, islive = 1)
head(LiveBasketballOdds)
```

*** 

### show Odds DF:

Combines the GetOdds, GetFixtures, and GetInrunning Calls, to get one picture of lines

Column names are slightly different than in the above calls, in that only the last 3 identifiers are kept

##### For example:

`sport.leagues.events.periods.periodNumber`

becomes

`events.periods.periodNumber`

This is done to make the tables easier to work with, but can be overridden (see `?showOddsDF`)

(Default is to show only mainlines, alternate lines are accessible via the `tableFormat` option)



```r
# Get Basketball oddsDF
BasketballOddsDF <- showOddsDF(4)
head(BasketballOddsDF)
```




*** 

### Place Bet

Once we have our odds information, we can use this to make a bet, or string of bets

for the following example, we will place a bet of 0.01$ 
(Below the minimum bet amount) on the favorite MONEYLINE



```r
BasketballOddsDF <- showOddsDF(4,tableFormat = 'mainlines')

# We transpose to make this easy to read
# And only select those columns we're interested in
t(BasketballOddsDF[1,c('sportId',
                       'leagues.events.id',
                       'events.periods.number',
                       'events.periods.lineId',
                       'events.periods.maxMoneyline',
                       'periods.moneyline.home',
                       'periods.moneyline.away')])
```




                                        
----------------------------  ----------
sportId                                4
leagues.events.id              669895493
events.periods.number                  0
events.periods.lineId          357125002
events.periods.maxMoneyline          250
periods.moneyline.home              -130
periods.moneyline.away               118
----------------------------  ----------

*** 

Now we can use those details to fill out the PlaceBet arguments



```r
PlaceBet(
    stake = 0.01, 
    sportId = 4,
    eventId = 669895493,
    periodNumber = 0,
    lineId = 357092455,
    betType = 'MONEYLINE',
    team = 'TEAM1'
)
```
