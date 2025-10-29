/*

Assignment 6.1 - SQL - Gaming KPIs

link to Instructions & Solutions
https://youtube.com/playlist?list=PLkKJj26K4JZ2G9lLoD9P-LhR_4Ce4efbk&si=zou4JNe2hx5TboYa



Game Play
The goal of the game is to progress as much as you can in the levels of the game. During the progression the player can change his Avatars (each one has different skills). In order to progress you can win battles and earn Coins and XP. Between the battles you can travel on Trail and claim prizes like chests. In the game economy the player can purchase (InApp Purchase) Gems, which can assist you to upgrade your Avatar or purchase weapons in the Store. The player can watch rewarded videos (RV) in order to get coins.


Questions
Provide answers which will be supported by a chart. Which could be a part of a Daily Dashboard which will assist the Product and management team to monitor the game Main KPIs.
It is recommended to generate the Dashboard with Google sheets.

*/

-- What is the distribution of all the events?
-- Sort it by the amount descending
-- Review all the events, does it support the described game play?


SELECT
  event,
  COUNT(1) AS total
FROM
  `ppltx-ba-course.sql_tutorial.game_fact`
GROUP BY
  1
ORDER BY
  2 DESC;




-- What is the DAU


SELECT
  dt,
  COUNT(DISTINCT PlayerID) AS DAU
FROM
  `ppltx-ba-course.sql_tutorial.game_fact`
GROUP BY
  1
ORDER BY
  1;



-- What are the daily installs?

SELECT
  install_dt,
  COUNT(PlayerID) AS total_installation
FROM (
  SELECT
    PlayerID,
    MIN(dt) AS install_dt
  FROM
    `ppltx-ba-course.sql_tutorial.game_fact`
  GROUP BY
    1 )
GROUP BY
  1
ORDER BY
  1;



-- Calculate the retention

WITH
  install_table AS (
  SELECT
    PlayerID,
    MIN(dt) AS install_dt
  FROM
    `ppltx-ba-course.sql_tutorial.game_fact`
  GROUP BY
    1 ),

  daily_installs AS (
  SELECT
    install_dt,
    COUNT(PlayerID) AS total_installation
  FROM
    install_table
  GROUP BY
    1 ),
-- For each install date and active days from installation we calculate how many users were active
  active_table AS (
  SELECT
    b.install_dt,
    DATE_DIFF(a.dt, b.install_dt, DAY) + 1 AS active_days_from_installion,
    COUNT(DISTINCT a.PlayerID) AS active_users
  FROM
    `ppltx-ba-course.sql_tutorial.game_fact` AS a
  LEFT JOIN
    install_table AS b
  ON
    a.PlayerID = b.PlayerID
  GROUP BY
    1,
    2 )

SELECT
  a.*,
  ROUND((a.active_users / b.total_installation) * 100, 2) AS retention_rate
FROM
  active_table AS a
LEFT JOIN
  daily_installs AS b
ON
  a.install_dt = b.install_dt
ORDER BY
  1,
  2






-- Calculate the daily revenue and the depositors


SELECT
  dt,
  SUM(price) as daily_revenue,
  COUNT(DISTINCT CASE WHEN price > 0 THEN PlayerID ELSE NULL END) as daily_depositors
FROM
  `ppltx-ba-course.sql_tutorial.game_fact`
GROUP BY
  1
ORDER BY
  1;


-- Calculate the ARPU & ARPPU

SELECT
  dt,
  ROUND(SUM(price) / COUNT(DISTINCT PlayerID), 2) AS ARPU,
  ROUND(SUM(price) / COUNT(DISTINCT
    CASE
      WHEN price > 0 THEN PlayerID
      ELSE NULL
  END
    ), 2) AS ARPPU
FROM
  `ppltx-ba-course.sql_tutorial.game_fact`
GROUP BY 1
ORDER BY 1;



-- What is the proportion of the players who had battles out of the DAU
-- What is the proportion of the players who Watched RV out of the DAU


SELECT
  dt,
  COUNT(DISTINCT
    CASE
      WHEN event IN ("Battle_Start", "Battle_End") THEN PlayerID
      ELSE NULL
  END
    ) AS t_players_battle_engagement,
  COUNT(DISTINCT
    CASE
      WHEN event = "RV_Watch" THEN PlayerID
      ELSE NULL
  END
    ) AS t_players_RV_Watch,
  COUNT(DISTINCT PlayerID) AS DAU,
  ROUND(COUNT(DISTINCT
      CASE
        WHEN event IN ("Battle_Start", "Battle_End") THEN PlayerID
        ELSE NULL
    END
      ) / COUNT(DISTINCT PlayerID), 2) AS proportion_battle_engagement_of_DAU,
  ROUND(COUNT(DISTINCT
      CASE
        WHEN event = "RV_Watch" THEN PlayerID
        ELSE NULL
    END
      ) / COUNT(DISTINCT PlayerID), 2) AS proportion_RV_Watch_of_DAU
FROM
  `ppltx-ba-course.sql_tutorial.game_fact`
GROUP BY
  1
ORDER BY
  1;



-- Calculate the daily funnel of players who entered the store and purchases IAP

SELECT
  dt,
  COUNT(DISTINCT PlayerID) AS DAU,
  COUNT(DISTINCT
    CASE
      WHEN event = "Store_Enter" THEN PlayerID
      ELSE NULL
  END
    ) AS Players_Entered_Store,
  COUNT(DISTINCT
    CASE
      WHEN event = "Store_IAP" THEN PlayerID
      ELSE NULL 
  END
    ) AS Players_Purchased_IAP,
  ROUND(COUNT(DISTINCT
    CASE
      WHEN event = "Store_Enter" THEN PlayerID
      ELSE NULL
  END
    ) / COUNT(DISTINCT PlayerID), 2) AS Store_Entry_Rate,
  ROUND(COUNT(DISTINCT
      CASE
        WHEN event = "Store_IAP" THEN PlayerID
        ELSE NULL
    END
      ) / COUNT(DISTINCT
      CASE
        WHEN event = "Store_Enter" THEN PlayerID
        ELSE NULL
    END
      ), 2) AS Store_to_IAP_CR
FROM
  `ppltx-ba-course.sql_tutorial.game_fact`
GROUP BY
  1
ORDER BY
  1;