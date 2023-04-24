--How many olympics games have been held?
select count(distinct games) from athlete_events;

--List down all Olympics games held so far.
select distinct year, season , city from athlete_events order by Year;

--Mention the total no of nations who participated in each olympics game?
with countrires as(
		select games, nr.region countr from athlete_events ae join noc_regions nr on nr.NOC=ae.NOC group by Games, nr.region)

select games, count(countr) total_countries from countrires group by games order by Games;

--Which year saw the highest and lowest no of countries participating in olympics?
with countrires as(
		select games, nr.region countr from athlete_events ae join noc_regions nr on nr.NOC=ae.NOC group by Games, nr.region),
another as(
select games, count(countr) total_countries from countrires group by games )
 
select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from another
      order by 1;

--Which nation has participated in all of the olympic games
DELETE FROM athlete_events
WHERE NOC IS NULL;

with abc as(
 select distinct noc, count(distinct games) n from athlete_events group by noc),
def as(
select region,n from abc ath inner join noc_regions nrg on nrg.NOC=ath.NOC where n = (select count(distinct games) from athlete_events)-1)
 select distinct n  participated_in_all , region from def;

 --Identify the sport which was played in all summer olympics.
 with ghi as(
 select count(distinct games) as total_games
          	from athlete_events where season = 'Summer'),
jkl as (
 select distinct sport, count(distinct games) games_played from athlete_events where season = 'Summer' group by Sport)

 select * from jkl inner join ghi on ghi.total_games=jkl.games_played;

 --Which Sports were just played only once in the olympics
with mno as (
select distinct sport, count(distinct games) mo from athlete_events group by Sport ),
pqr as(
select *, row_number() over(order by mo) rnk from mno)

select sport, mo from pqr where rnk<>1 and mo=1;

--Fetch the total no of sports played in each olympic games.
select distinct games, count(distinct sport) total_no_of_sports from athlete_events group by games order by count(distinct sport) desc

--Fetch oldest athletes to win a gold medal
select top 2 name ,age from athlete_events where medal='Gold' and age<>'NA' order by age desc;

--Fetch the top 5 athletes who have won the most gold medals
with alpha as(
select name, team , count(medal) medals_won,dense_rank() over ( order by count(medal) desc) as rnk from athlete_events where medal='Gold' group by Name, Team)
 
select name, team, medals_won from alpha where rnk<=5;

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)
with beta as(
select name, team , count(medal) medals_won,dense_rank() over ( order by count(medal) desc) as rnk from athlete_events where medal<>'NA' group by Name, Team)
 
select name, team, medals_won from beta where rnk<=5;

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won
with gamma as(
select region , count(medal) medals_won,dense_rank() over ( order by count(medal) desc) as rnk from athlete_events ath inner join noc_regions nr on ath.NOC=nr.NOC where medal<>'NA' group by region)
 
select * from gamma where rnk<=5;

--List down total gold, silver and bronze medals won by each country

SELECT nr.region as country,
    COALESCE(pvt.Gold, 0) as gold,
    COALESCE(pvt.Silver, 0) as silver,
    COALESCE(pvt.Bronze, 0) as bronze
FROM athlete_events oh
JOIN noc_regions nr ON nr.noc = oh.noc
LEFT JOIN (
    SELECT region,
        [Gold],
        [Silver],
        [Bronze]
    FROM (
        SELECT region,
            medal
            
        FROM athlete_events oh
        JOIN noc_regions nr ON nr.noc = oh.noc
        WHERE medal IN ('Gold', 'Silver', 'Bronze')
    ) src
    PIVOT (
        count(medal)
        FOR medal IN ([Gold], [Silver], [Bronze])
    ) piv
) pvt ON pvt.region = nr.region
group by nr.region, gold,silver,Bronze
ORDER BY gold DESC, silver DESC, bronze DESC;

--List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

SELECT nr.region as country, games,
    COALESCE(pvt.Gold, 0) as gold,
    COALESCE(pvt.Silver, 0) as silver,
    COALESCE(pvt.Bronze, 0) as bronze
FROM athlete_events oh
JOIN noc_regions nr ON nr.noc = oh.noc
LEFT JOIN (
    SELECT region,
        [Gold],
        [Silver],
        [Bronze]
    FROM (
        SELECT region,
            medal
            
        FROM athlete_events oh
        JOIN noc_regions nr ON nr.noc = oh.noc
        WHERE medal IN ('Gold', 'Silver', 'Bronze')
    ) src
    PIVOT (
        count(medal)
        FOR medal IN ([Gold], [Silver], [Bronze])
    ) piv
) pvt ON pvt.region = nr.region
group by nr.region,games, gold,silver,Bronze
ORDER BY games, nr.region;


--Which countries have never won gold medal but have won silver/bronze medals?
SELECT nr.region as country,
    COALESCE(pvt.Gold, 0) as gold,
    COALESCE(pvt.Silver, 0) as silver,
    COALESCE(pvt.Bronze, 0) as bronze
FROM athlete_events oh
JOIN noc_regions nr ON nr.noc = oh.noc
LEFT JOIN (
    SELECT region,
        [Gold],
        [Silver],
        [Bronze]
    FROM (
        SELECT region,
            medal
            
        FROM athlete_events oh
        JOIN noc_regions nr ON nr.noc = oh.noc
        WHERE medal IN ('Gold', 'Silver', 'Bronze')
    ) src
    PIVOT (
        count(medal)
        FOR medal IN ([Gold], [Silver], [Bronze])
    ) piv
) pvt ON pvt.region = nr.region
where gold=0
group by nr.region, gold,silver,Bronze
ORDER BY gold DESC, silver DESC, bronze DESC;

--In which Sport/event, India has won highest medals.
with this as(
select Team, sport,count(medal) medals, DENSE_RANK() over(order by count(medal) desc) rnk from athlete_events  where team='India' and medal<>'NA' group by Team, sport)
select sport, medals from this where rnk=1

-- Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

select team,games,count(medal) medal_won from athlete_events where team='India' and sport='Hockey' and medal<>'NA' group by games,team order by count(medal) desc

