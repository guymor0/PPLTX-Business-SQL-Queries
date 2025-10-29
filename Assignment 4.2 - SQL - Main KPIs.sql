  /*
Assignment 4.2 - SQL - Main KPIs
======================================

link to Instructions & Solutions
https://youtu.be/bwVY7jw-L6s


It is highly recommended to explore the table's schema before you begin to solve the questions.


`sql_tutorial.app_events`

*/
  -- Questions


  -- ==========


  -- How many users played in the app?


SELECT
  COUNT(DISTINCT uid) AS total_users
FROM
  `ppltx-ba-course.sql_tutorial.app_events`


  -- Extract the top 5 users who has multiple devices,
  -- sort the result by the number of the devices


SELECT
  uid,
  COUNT(DISTINCT device) AS total_devices
FROM
  `ppltx-ba-course.sql_tutorial.app_events`
GROUP BY
  ALL
HAVING
  total_devices > 1
ORDER BY
  total_devices DESC
LIMIT
  5


  -- The Price represent the amount of $ the user spend in the game
  -- Who are the top 5 users for each platform, who spend the highest amounts


SELECT
  uid,
  platform,
  SUM(price) AS total_amount
FROM
  `ppltx-ba-course.sql_tutorial.app_events`
GROUP BY
  ALL
QUALIFY
  (ROW_NUMBER() OVER (PARTITION BY platform ORDER BY total_amount DESC)) <= 5
ORDER BY
  platform,
  total_amount DESC


  -- There is a bug in the versions 1500 to 2000
  -- the price in the event which the user paid is half of the real money we charged in the real world
  -- Please calculate the total revenue (price) with the fix amount and without it


WITH
  current_revenue AS (
  SELECT
    platform,
    SUM(price) AS revenue_without_fix
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  GROUP BY
    platform ),
  fix_price AS (
  SELECT
    platform,
    SUM(price) AS fix_price
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  WHERE
    version BETWEEN 1500
    AND 2000
  GROUP BY
    platform )
SELECT
  SUM(c.revenue_without_fix) AS revenue_without_fix,
  SUM(c.revenue_without_fix + f.fix_price) AS revenue_with_fix
FROM
  current_revenue AS c
JOIN
  fix_price AS f
USING
  (platform)

  -- Solution for the same problem above: much more easier..

SELECT
   SUM(price) AS revenue_without_fix,
   SUM(CASE WHEN version BETWEEN 1500 AND 2000 THEN 2*price else price END) as revenue_with_fix
FROM	
  `ppltx-ba-course.sql_tutorial.app_events`

  -- DAU - Daily Active Users  - How many active users played the game each day?


SELECT
  DATE(timestamp) AS dt,
  COUNT(DISTINCT uid) AS dau
FROM
  `ppltx-ba-course.sql_tutorial.app_events`
GROUP BY
  ALL
ORDER BY
  dt


  -- Installs (new users) - How many users joined (the first day they played) the game each day?


SELECT
  first_day,
  COUNT(DISTINCT uid) AS installs
FROM (
  SELECT
    uid,
    MIN(DATE(timestamp)) AS first_day
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  GROUP BY
    uid )
GROUP BY
  1
ORDER BY
  1


  -- Who are the top 10 players who played the highest number of active days?


SELECT
  uid,
  COUNT(DISTINCT DATE(timestamp)) AS active_days
FROM
  `ppltx-ba-course.sql_tutorial.app_events`
GROUP BY
  uid
ORDER BY
  2 DESC
LIMIT
  10


  -- Who are the top 10 players who have the highest gap between last and first activity date?


SELECT
  uid,
  DATE_DIFF(MAX(DATE(timestamp)), MIN(DATE(timestamp)), DAY) AS gap
FROM
  `ppltx-ba-course.sql_tutorial.app_events`
GROUP BY
  uid
ORDER BY
  2 DESC
LIMIT
  10


  -- What is the conversion ratio between the users who did event A (on the first time)
  -- and later did event G (at list 1)?
  -- Fore example by date of the first time the user entered the store in the game (event A)
  -- and later (can be on other date) purchased (did event G)

-- I assumed that event G only occurs after event A has happened.

WITH
  group_a AS (
  SELECT
    DISTINCT uid
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  WHERE
    event = "A" ),
  group_g AS (
  SELECT
    DISTINCT uid
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  WHERE
    event = "G" )
SELECT
  COUNT(g.uid) / COUNT(*) AS conversion_ratio
FROM
  group_a AS a
LEFT JOIN
  group_g AS g
ON
  a.uid = g.uid

-- The solution without my assumption:

WITH
  group_a AS (
  SELECT
    uid,
    MIN(timestamp) as first_timeA
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  WHERE
    event = "A"
  GROUP BY uid ),
  group_g AS (
  SELECT
    uid,
    timestamp
  FROM
    `ppltx-ba-course.sql_tutorial.app_events`
  WHERE
    event = "G"
  )
SELECT
  COUNT(g.timestamp) / COUNT(*) AS conversion_ratio
FROM
  group_a AS a
LEFT JOIN
  group_g AS g
ON
  a.uid = g.uid AND
  a.first_timeA < g.timestamp

  -- For each user please calculate the number of active days,
  -- the number of purchase events (event G)
  -- The total amount of Gems he earned (earn column)
  -- what was the first time (date) he entered the store (event A)
  -- What is his install date (first active date)
  -- What is his last activity date (last active date)
  -- Please display only 10 users


SELECT
  uid,
  COUNT(DISTINCT DATE(timestamp)) AS active_days,
  SUM(CASE
      WHEN event = "G" THEN 1
  END
    ) AS num_of_purchase,
  SUM(earn) AS total_amount_of_gems,
  MIN((CASE
        WHEN event = "A" THEN DATE(timestamp)
    END
      )) AS first_time_A,
  -- MIN(IF(event = "A", DATE(timestamp), NULL)) AS first_time_A, <-GPT's suggestion
  MIN(DATE(timestamp)) AS install_dt,
  MAX(DATE(timestamp)) AS last_activity_dt
FROM
  `ppltx-ba-course.sql_tutorial.app_events`
GROUP BY
  uid
LIMIT
  10
 
 
  -- CTE & Row Number
  -- Extract the order details (all columns) of 2 earliest orders for each EmployeeID


SELECT
  *
FROM
  `ppltx-ba-course.sql_tutorial.orders`
QUALIFY
  ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate) <= 2


  -- Extract the two highest players from each team


SELECT
  *
FROM
  `ppltx-ba-course.sql_tutorial.basketball`
QUALIFY
  ROW_NUMBER() OVER (PARTITION BY team ORDER BY height DESC) <= 2


  -- Matchup
  -- For each matchup of a player from one team vs a player from the other team announce
  -- the name of the team with the highest player.
  -- For example:
  -- playerA,playerB,team
  -- 90,12,Red
  -- 90,3,Blue
  -- Please write down the query which will provide the solution


SELECT
  a.playerID AS playerA,
  b.playerID AS playerB,
  (CASE
      WHEN a.height > b.height THEN a.team
      WHEN a.height < b.height THEN b.team
      ELSE "Draw"
  END
    ) AS team
FROM
  `ppltx-ba-course.sql_tutorial.basketball` AS a
JOIN
  `ppltx-ba-course.sql_tutorial.basketball`AS b
ON
  a.team < b.team