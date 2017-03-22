# Accessing the Pinnacle API
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

To use the Pinnacle Sports API you must have an account with Pinnacle Sports.

Please contact Pinnacle Sports directly at csd@pinnaclesports.com for all account questions.

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
 AcceptTermsAndConditions()
 SetCredentials()
```

Please make sure that you understand the terms and conditions.

and then accept them. If AcceptTermsnAndConditions is not set to TRUE the functions will not run.

You will be prompted for your username and password. 
Your credentials are the username and password for logging into www.pinnaclesports.com.

This can also be done uninteractively with:


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

<!--html_preserve--><div id="htmlwidget-5599514c2fed1425d891" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-5599514c2fed1425d891">{"x":{"filter":"none","data":[[1,2,3,4,5,6],["Badminton","Bandy","Baseball","Basketball","Beach Volleyball","Boxing"],[false,false,true,true,false,true],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,4,269,0,13]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>id\u003c/th>\n      <th>name\u003c/th>\n      <th>hasOfferings\u003c/th>\n      <th>leagueSpecialsCount\u003c/th>\n      <th>eventSpecialsCount\u003c/th>\n      <th>eventCount\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,3,4,5]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

*** 

### Get Leagues:


```r
BasketBallLeagues <- GetLeaguesByID(4)

# Get first 5 entries Basketball Leagues
head(BasketBallLeagues)
```

<!--html_preserve--><div id="htmlwidget-a84de524d2be18c1257a" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-a84de524d2be18c1257a">{"x":{"filter":"none","data":[[267,268,5135,5131,5682,271],["Europe - ABA League Adriatic All Star","ABA - Adriatic League","All African Games","All African Games - Women","America - CentroBasket Championship Women","International - Arab Cup"],["Team1","Team1","Team1","Team1","Team1","Team1"],[false,true,false,false,false,false],["","","","","",""],[true,true,false,false,false,false],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,8,0,0,0,0]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>leagues.id\u003c/th>\n      <th>leagues.name\u003c/th>\n      <th>leagues.homeTeamType\u003c/th>\n      <th>leagues.hasOfferings\u003c/th>\n      <th>leagues.container\u003c/th>\n      <th>leagues.allowRoundRobins\u003c/th>\n      <th>leagues.leagueSpecialsCount\u003c/th>\n      <th>leagues.eventSpecialsCount\u003c/th>\n      <th>leagues.eventCount\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,6,7,8]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

*** 

### Get Fixtures:


```r
# Get Basketball Fixtures
BasketballFixtures <- GetFixtures(4)
head(BasketballFixtures)
```


<!--html_preserve--><div id="htmlwidget-e9e8d49d3c54d8bb0753" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-e9e8d49d3c54d8bb0753">{"x":{"filter":"none","data":[[4,4,4,4,4,4],[92301384,92301384,92301384,92301384,92301384,92301384],[268,268,268,268,268,268],[669895493,669997810,670067851,669997807,670302999,670456929],["2016-12-10T16:00:00Z","2016-12-10T18:00:00Z","2016-12-10T20:00:00Z","2016-12-10T18:00:00Z","2016-12-11T11:00:00Z","2016-12-11T16:00:00Z"],["Mornar Bar","Karpos","Partizan Belgrade","Helios Domzale","Cibona","FMP"],["MZT Skopje","Mega Vizura","Igokea","Mega Vizura","Krka","Cedevita Zagreb"],["1013","1027","1029","1031","1003","1005"],[2,2,2,0,0,0],["I","I","I","I","O","O"],[2,2,2,2,2,2]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>sportId\u003c/th>\n      <th>last\u003c/th>\n      <th>league.id\u003c/th>\n      <th>league.events.id\u003c/th>\n      <th>league.events.starts\u003c/th>\n      <th>league.events.home\u003c/th>\n      <th>league.events.away\u003c/th>\n      <th>league.events.rotNum\u003c/th>\n      <th>league.events.liveStatus\u003c/th>\n      <th>league.events.status\u003c/th>\n      <th>league.events.parlayRestriction\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,8,10]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

*** 


```r
# Get Live Basketball Fixtures
LiveBasketballFixtures <- GetFixtures(4, islive = 1)
head(LiveBasketballFixtures)
```

<!--html_preserve--><div id="htmlwidget-5602494130b0d21bf0d4" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-5602494130b0d21bf0d4">{"x":{"filter":"none","data":[[4,4,4,4,4,4],[92301104,92301104,92301104,92301104,92301104,92301104],[268,268,268,280,280,280],[671927945,671928017,671928147,671899672,671924218,671925222],["2016-12-10T16:00:00Z","2016-12-10T18:00:00Z","2016-12-10T20:00:00Z","2016-12-10T06:30:00Z","2016-12-10T08:30:00Z","2016-12-11T04:00:00Z"],["Mornar Bar","Karpos","Partizan Belgrade","Adelaide 36ers","Brisbane Bullets","Sydney Kings"],["MZT Skopje","Mega Vizura","Igokea","New Zealand Breakers","Illawarra Hawks","Melbourne United"],["9013","9027","9029","9135","9141","9143"],[1,1,1,1,1,1],["O","O","O","O","O","O"],[2,2,2,2,2,2]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>sportId\u003c/th>\n      <th>last\u003c/th>\n      <th>league.id\u003c/th>\n      <th>league.events.id\u003c/th>\n      <th>league.events.starts\u003c/th>\n      <th>league.events.home\u003c/th>\n      <th>league.events.away\u003c/th>\n      <th>league.events.rotNum\u003c/th>\n      <th>league.events.liveStatus\u003c/th>\n      <th>league.events.status\u003c/th>\n      <th>league.events.parlayRestriction\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,8,10]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

*** 

### Get Odds:


```r
# Get Basketball Odds
BasketballOdds <- GetOdds(4)
head(BasketballOdds)
```


<!--html_preserve--><div id="htmlwidget-c2d74766192364bcf343" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-c2d74766192364bcf343">{"x":{"filter":"none","data":[[4,4,4,4,4,4],[357133520,357133520,357133520,357133520,357133520,357133520],[268,268,268,268,268,268],[669895493,669997810,670067851,670302999,670456929,670529042],[357125002,357119323,357051232,356869457,356869467,356869485],[0,0,0,0,0,0],["2016-12-10T16:00:00Z","2016-12-10T18:00:00Z","2016-12-10T20:00:00Z","2016-12-11T11:00:00Z","2016-12-11T16:00:00Z","2016-12-11T18:00:00Z"],[250,200,250,null,null,null],[250,200,250,null,null,null],[250,200,250,null,null,null],[100,100,100,null,null,null],[-2.5,1.5,-8,null,null,null],[-105,-102,-101,null,null,null],[-105,-108,-109,null,null,null],[null,null,null,null,null,null],[161,165.5,150,null,null,null],[-107,-108,-103,null,null,null],[-103,-102,-107,null,null,null],[null,null,null,null,null,null],[-130,104,-372,null,null,null],[118,-115,323,null,null,null],[82,82,79,null,null,null],[-106,-109,-104,null,null,null],[-111,-107,-112,null,null,null],[79.5,83.5,71,null,null,null],[-106,-112,-108,null,null,null],[-111,-104,-108,null,null,null]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>sportId\u003c/th>\n      <th>last\u003c/th>\n      <th>leagues.id\u003c/th>\n      <th>leagues.events.id\u003c/th>\n      <th>leagues.events.periods.lineId\u003c/th>\n      <th>leagues.events.periods.number\u003c/th>\n      <th>leagues.events.periods.cutoff\u003c/th>\n      <th>leagues.events.periods.maxSpread\u003c/th>\n      <th>leagues.events.periods.maxMoneyline\u003c/th>\n      <th>leagues.events.periods.maxTotal\u003c/th>\n      <th>leagues.events.periods.maxTeamTotal\u003c/th>\n      <th>leagues.events.periods.spreads.hdp\u003c/th>\n      <th>leagues.events.periods.spreads.home\u003c/th>\n      <th>leagues.events.periods.spreads.away\u003c/th>\n      <th>leagues.events.periods.spreads.altLineId\u003c/th>\n      <th>leagues.events.periods.totals.points\u003c/th>\n      <th>leagues.events.periods.totals.over\u003c/th>\n      <th>leagues.events.periods.totals.under\u003c/th>\n      <th>leagues.events.periods.totals.altLineId\u003c/th>\n      <th>leagues.events.periods.moneyline.home\u003c/th>\n      <th>leagues.events.periods.moneyline.away\u003c/th>\n      <th>leagues.events.periods.teamTotal.home.points\u003c/th>\n      <th>leagues.events.periods.teamTotal.home.over\u003c/th>\n      <th>leagues.events.periods.teamTotal.home.under\u003c/th>\n      <th>leagues.events.periods.teamTotal.away.points\u003c/th>\n      <th>leagues.events.periods.teamTotal.away.over\u003c/th>\n      <th>leagues.events.periods.teamTotal.away.under\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

*** 


```r
# Get Live Basketball Odds
LiveBasketballOdds <- GetOdds(4, islive = 1)
head(LiveBasketballOdds)
```

<!--html_preserve--><div id="htmlwidget-3a7bf357342581b6e397" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-3a7bf357342581b6e397">{"x":{"filter":"none","data":[[4,4,4,4,4,4],[92301384,92301384,92301384,92301384,92301384,92301384],[268,268,268,268,268,268],[669895493,669997810,670067851,669997807,670302999,670456929],["2016-12-10T16:00:00Z","2016-12-10T18:00:00Z","2016-12-10T20:00:00Z","2016-12-10T18:00:00Z","2016-12-11T11:00:00Z","2016-12-11T16:00:00Z"],["Mornar Bar","Karpos","Partizan Belgrade","Helios Domzale","Cibona","FMP"],["MZT Skopje","Mega Vizura","Igokea","Mega Vizura","Krka","Cedevita Zagreb"],["1013","1027","1029","1031","1003","1005"],[2,2,2,0,0,0],["I","I","I","I","O","O"],[2,2,2,2,2,2]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>sportId\u003c/th>\n      <th>last\u003c/th>\n      <th>league.id\u003c/th>\n      <th>league.events.id\u003c/th>\n      <th>league.events.starts\u003c/th>\n      <th>league.events.home\u003c/th>\n      <th>league.events.away\u003c/th>\n      <th>league.events.rotNum\u003c/th>\n      <th>league.events.liveStatus\u003c/th>\n      <th>league.events.status\u003c/th>\n      <th>league.events.parlayRestriction\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,8,10]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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


<!--html_preserve--><div id="htmlwidget-6443b2e4f191f074c3f2" style="width:500px;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-6443b2e4f191f074c3f2">{"x":{"filter":"none","data":[[268,268,268,268,268,268],[669895493,669895493,669895493,669895493,669895493,669895493],[4,4,4,4,4,4],[357133543,357133543,357133543,357133543,357133543,357133543],[268,268,268,268,268,268],[357125002,357125002,357125002,357125002,357125002,357125002],[0,0,0,0,0,0],["2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z"],[250,250,250,250,250,250],[250,250,250,250,250,250],[250,250,250,250,250,250],[100,100,100,100,100,100],[-130,-130,-130,-130,-130,-130],[118,118,118,118,118,118],[82,82,82,82,82,82],[-106,-106,-106,-106,-106,-106],[-111,-111,-111,-111,-111,-111],[79.5,79.5,79.5,79.5,79.5,79.5],[-106,-106,-106,-106,-106,-106],[-111,-111,-111,-111,-111,-111],["leagues.events.periods.spreads","leagues.events.periods.spreads","leagues.events.periods.spreads","leagues.events.periods.spreads","leagues.events.periods.spreads","leagues.events.periods.spreads"],[-2.5,-4.5,-4,-3.5,-3,-2],[-105,132,123,111,103,-114],[-105,-146,-136,-123,-114,103],[null,1320047829,1320047831,1320047833,1320047835,1320047837],[null,null,null,null,null,null],[null,null,null,null,null,null],[null,null,null,null,null,null],[4,4,4,4,4,4],[92301384,92301384,92301384,92301384,92301384,92301384],["2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z","2016-12-10T16:00:00Z"],["Mornar Bar","Mornar Bar","Mornar Bar","Mornar Bar","Mornar Bar","Mornar Bar"],["MZT Skopje","MZT Skopje","MZT Skopje","MZT Skopje","MZT Skopje","MZT Skopje"],["1013","1013","1013","1013","1013","1013"],[2,2,2,2,2,2],["I","I","I","I","I","I"],[2,2,2,2,2,2],[null,null,null,null,null,null],[null,null,null,null,null,null],[null,null,null,null,null,null],[null,null,null,null,null,null],["ABA - Adriatic League","ABA - Adriatic League","ABA - Adriatic League","ABA - Adriatic League","ABA - Adriatic League","ABA - Adriatic League"],["Team1","Team1","Team1","Team1","Team1","Team1"],[true,true,true,true,true,true],["","","","","",""],[true,true,true,true,true,true],[0,0,0,0,0,0],[0,0,0,0,0,0],[8,8,8,8,8,8]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>league.id\u003c/th>\n      <th>leagues.events.id\u003c/th>\n      <th>sportId\u003c/th>\n      <th>last\u003c/th>\n      <th>leagues.id\u003c/th>\n      <th>events.periods.lineId\u003c/th>\n      <th>events.periods.number\u003c/th>\n      <th>events.periods.cutoff\u003c/th>\n      <th>events.periods.maxSpread\u003c/th>\n      <th>events.periods.maxMoneyline\u003c/th>\n      <th>events.periods.maxTotal\u003c/th>\n      <th>events.periods.maxTeamTotal\u003c/th>\n      <th>periods.moneyline.home\u003c/th>\n      <th>periods.moneyline.away\u003c/th>\n      <th>teamTotal.home.points\u003c/th>\n      <th>teamTotal.home.over\u003c/th>\n      <th>teamTotal.home.under\u003c/th>\n      <th>teamTotal.away.points\u003c/th>\n      <th>teamTotal.away.over\u003c/th>\n      <th>teamTotal.away.under\u003c/th>\n      <th>field\u003c/th>\n      <th>value.hdp\u003c/th>\n      <th>value.home\u003c/th>\n      <th>value.away\u003c/th>\n      <th>value.altLineId\u003c/th>\n      <th>value.points\u003c/th>\n      <th>value.over\u003c/th>\n      <th>value.under\u003c/th>\n      <th>sportId.Fixture\u003c/th>\n      <th>last.Fixture\u003c/th>\n      <th>league.events.starts\u003c/th>\n      <th>league.events.home\u003c/th>\n      <th>league.events.away\u003c/th>\n      <th>league.events.rotNum\u003c/th>\n      <th>league.events.liveStatus\u003c/th>\n      <th>league.events.status\u003c/th>\n      <th>league.events.parlayRestriction\u003c/th>\n      <th>sports.id\u003c/th>\n      <th>sports.leagues.id\u003c/th>\n      <th>leagues.events.state\u003c/th>\n      <th>leagues.events.elapsed\u003c/th>\n      <th>leagues.name\u003c/th>\n      <th>leagues.homeTeamType\u003c/th>\n      <th>leagues.hasOfferings\u003c/th>\n      <th>leagues.container\u003c/th>\n      <th>leagues.allowRoundRobins\u003c/th>\n      <th>leagues.leagueSpecialsCount\u003c/th>\n      <th>leagues.eventSpecialsCount\u003c/th>\n      <th>leagues.eventCount\u003c/th>\n    \u003c/tr>\n  \u003c/thead>\n\u003c/table>","options":{"searching":false,"scrollX":true,"autowidth":true,"scrollCollapse":true,"columnDefs":[{"className":"dt-right","targets":[0,1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27,28,29,34,36,37,38,39,40,46,47,48]}],"order":[],"autoWidth":false,"orderClasses":false}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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


$status
[1] "PROCESSED_WITH_ERROR"

$errorCode
[1] "BELOW_MIN_BET_AMOUNT"

$betId
NULL

$uniqueRequestId
[1] "22e0e273-bdb8-4f3a-873b-6c7c72ba5221"

$betterLineWasAccepted
[1] FALSE

(We receive an error because our stake is below the minimum value)
