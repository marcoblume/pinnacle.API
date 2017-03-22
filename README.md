# Accessing the Pinnacle API

The [Pinnacle](http://pinnacle.com) manual can be found here :

[http://www.pinnacle.com/en/api/manual](http://www.pinnacle.com/en/api/manual)

***

To use the Pinnacle API you must have an account with [Pinnacle](http://pinnacle.com).

***

Please contact Pinnacle directly at [csd@pinnacle.com](mailto:csd@pinnacle.com) for all account questions. 

***

## Pinnacle Terms & Conditions:
This package is a **GUIDELINE** only. 

All responsibility of activity on [Pinnacle](http://pinnacle.com) lies with the user of the package and NOT with the authors of the package. 

Especially wagers placed with the help of this package are the sole responsibility of the user of this package.  The authors and maintainers of the package are not liable or responsible in any form. 
Please see [Manual:Fair-Use](http://www.pinnacle.com/en/api/manual#fair-use),
[API Rules](http://www.pinnacle.com/api-xml/terms-and-conditions.aspx) and [Terms and Conditions](http://www.pinnacle.com/en/termsandconditions)

[http://www.pinnacle.com/en/termsandconditions](http://www.pinnacle.com/en/api/manual)

***

<em>The API is not accessible from all IP-Ranges. For example, IP addresses from the UK and the USA are Geo IP blocked.</em>


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

* Placing wagers/parlays. 

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
```

Please make sure that you understand the terms and conditions.


```r
 AcceptTermsAndConditions()
```

Run the following to store your session credentials:


```r
 SetCredentials()
```

Your credentials are the username and password for logging into www.pinnacle.com.

## Example Usage:

Pull the Sport Data and filter out the leagues that have lines for Soccer available.


```r
# Get Sports
sport_data <- GetSports()
# Get Soccer id
soccer_id <- with(sport_data, id[name == 'Soccer'])
# Get Odds
soccer_data <- showOddsDF(soccer_id)

# Lets select a single record and see what we're looking at
# (transposed for easier reading)
```

A Record Example:
<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;"> Data </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> league.id </td>
   <td style="text-align:left;"> 2117 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.id </td>
   <td style="text-align:left;"> 706786965 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sportId </td>
   <td style="text-align:left;"> 29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> last </td>
   <td style="text-align:left;"> 379958992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.id </td>
   <td style="text-align:left;"> 2117 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.lineId </td>
   <td style="text-align:left;"> 379958992 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.number </td>
   <td style="text-align:left;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.cutoff </td>
   <td style="text-align:left;"> 2017-03-22T19:00:00Z </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.maxSpread </td>
   <td style="text-align:left;"> 2000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.maxMoneyline </td>
   <td style="text-align:left;"> 500 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.maxTotal </td>
   <td style="text-align:left;"> 2000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.maxTeamTotal </td>
   <td style="text-align:left;"> 750 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.spreads.hdp </td>
   <td style="text-align:left;"> -1.25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.spreads.home </td>
   <td style="text-align:left;"> -118 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.spreads.away </td>
   <td style="text-align:left;"> 108 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.spreads.altLineId </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.totals.points </td>
   <td style="text-align:left;"> 2.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.totals.over </td>
   <td style="text-align:left;"> -107 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.totals.under </td>
   <td style="text-align:left;"> -104 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.totals.altLineId </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.moneyline.home </td>
   <td style="text-align:left;"> -289 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.moneyline.away </td>
   <td style="text-align:left;"> 957 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.moneyline.draw </td>
   <td style="text-align:left;"> 358 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> teamTotal.home.points </td>
   <td style="text-align:left;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> teamTotal.home.over </td>
   <td style="text-align:left;"> 101 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> teamTotal.home.under </td>
   <td style="text-align:left;"> -123 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> teamTotal.away.points </td>
   <td style="text-align:left;"> 0.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> teamTotal.away.over </td>
   <td style="text-align:left;"> 108 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> teamTotal.away.under </td>
   <td style="text-align:left;"> -133 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.awayScore </td>
   <td style="text-align:left;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.homeScore </td>
   <td style="text-align:left;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.awayRedCards </td>
   <td style="text-align:left;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.homeRedCards </td>
   <td style="text-align:left;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sportId.Fixture </td>
   <td style="text-align:left;"> 29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> last.Fixture </td>
   <td style="text-align:left;"> 102176288 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.starts </td>
   <td style="text-align:left;"> 2017-03-22T17:00:00Z </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.home </td>
   <td style="text-align:left;"> Czech Republic </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.away </td>
   <td style="text-align:left;"> Lithuania </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.rotNum </td>
   <td style="text-align:left;"> 30904 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.liveStatus </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.status </td>
   <td style="text-align:left;"> I </td>
  </tr>
  <tr>
   <td style="text-align:left;"> league.events.parlayRestriction </td>
   <td style="text-align:left;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sports.id </td>
   <td style="text-align:left;"> 29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sports.leagues.id </td>
   <td style="text-align:left;"> 2117 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.state </td>
   <td style="text-align:left;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.elapsed </td>
   <td style="text-align:left;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.name </td>
   <td style="text-align:left;"> International - Friendlies </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.homeTeamType </td>
   <td style="text-align:left;"> Team1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.hasOfferings </td>
   <td style="text-align:left;"> TRUE </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.container </td>
   <td style="text-align:left;">  </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.allowRoundRobins </td>
   <td style="text-align:left;"> TRUE </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.leagueSpecialsCount </td>
   <td style="text-align:left;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.eventSpecialsCount </td>
   <td style="text-align:left;"> 13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.eventCount </td>
   <td style="text-align:left;"> 13 </td>
  </tr>
</tbody>
</table>
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

Combines the `GetOdds`, `GetFixtures`, and `GetInrunning` Calls, to get one picture of lines

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

for the following example, we will place a bet of $0.01 
(Below the minimum bet amount) on the favorite `MONEYLINE`



```r
BasketballOddsDF <- showOddsDF(4,tableFormat = 'mainlines')
```

Record example (filtered to only the interesting fields):

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> Data </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> sportId </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> leagues.events.id </td>
   <td style="text-align:right;"> 704584684 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.number </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.lineId </td>
   <td style="text-align:right;"> 379913314 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> events.periods.maxMoneyline </td>
   <td style="text-align:right;"> 250 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.moneyline.home </td>
   <td style="text-align:right;"> -477 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> periods.moneyline.away </td>
   <td style="text-align:right;"> 353 </td>
  </tr>
</tbody>
</table>

*** 

Now we can use those details to fill out the PlaceBet arguments



```r
PlaceBet(
    stake = 0.01, 
    sportId = 4,
    eventId = 704584684,
    periodNumber = 0,
    lineId = 379913314,
    betType = 'MONEYLINE',
    team = 'TEAM1'
)
```

Here, our stake is below the minimum amount, as we can see in the error message that is returned

List of 5:

 - status               : chr "PROCESSED_WITH_ERROR"
 - errorCode            : chr "BELOW_MIN_BET_AMOUNT"
 - betId                : NULL
 - uniqueRequestId      : chr "b9d95cf0-54bf-47ee-bad5-4a6dc557da7a"
 - betterLineWasAccepted: logi FALSE

 
 
 If we do it for a larger amount:
 

```r
PlaceBet(
    stake = 500, 
    sportId = 4,
    eventId = 704584684,
    periodNumber = 0,
    lineId = 379913314,
    betType = 'MONEYLINE',
    team = 'TEAM1'
)
```

List of 6:

 - status               : chr "ACCEPTED"
 - errorCode            : NULL
 - betId                : int 706865959
 - uniqueRequestId      : chr "5acf90ff-bbde-4449-af28-b0db7534e249"
 - betterLineWasAccepted: logi FALSE
 - price                : num -477
