  /*
Assignment 3.2 - SQL - Zoom Analytics
======================================

link to Instructions & Solutions 
https://youtube.com/playlist?list=PLkKJj26K4JZ2IIyhdkzyu4cGEo6qPiWLe&si=AkNptN0zCNXfKXPM


It is highly recommended to explore the table's schema before you begin to solve the questions.


`ppltx-ba-course.sql_tutorial.zoom_analytics`

*/
  -- Questions
  -- ==========
  -- How many users used the app?
SELECT
  COUNT(DISTINCT uid) AS total_users
FROM
  `ppltx-ba-course.sql_tutorial.zoom_analytics`
  -- Extract the top 5 users who participated in different meetings,
  -- sort the result by the number of meetings
SELECT
  uid,
  COUNT(DISTINCT meeting_id) AS total_meetings
FROM
  `ppltx-ba-course.sql_tutorial.zoom_analytics`
GROUP BY
  uid
ORDER BY
  total_meetings DESC
LIMIT
  5
  -- What is the event distribution?
SELECT
  event,
  COUNT(*) AS event_distribution
FROM
  `ppltx-ba-course.sql_tutorial.zoom_analytics`
GROUP BY
  event
ORDER BY
  event_distribution DESC
  -- How many users use Zoom on each day?
SELECT
  DATE(event_time) AS dt,
  COUNT(DISTINCT uid) AS DAU
FROM
  `ppltx-ba-course.sql_tutorial.zoom_analytics`
GROUP BY
  dt
ORDER BY
  1
  -- How many users use Zoom only a single day?
SELECT
  COUNT(*) AS t_day_users,
  t_event_day
FROM (
  SELECT
    uid,
    COUNT(DISTINCT DATE_TRUNC(event_time, DAY)) AS t_event_day
  FROM
    `ppltx-ba-course.sql_tutorial.zoom_analytics`
  GROUP BY
    uid )
GROUP BY
  2
ORDER BY
  2
LIMIT
  1
  -- How many users participated in a meeting with Share screen ?
WITH
  share_screen_info AS (
  SELECT
    *,
    CASE
      WHEN SUM(CASE
        WHEN event = 'Share_Start' THEN 1
        ELSE 0
    END
      ) OVER (PARTITION BY meeting_id) > 0 THEN 'Yes'
      ELSE 'No'
  END
    AS share_screen
  FROM
    `ppltx-ba-course.sql_tutorial.zoom_analytics` )
SELECT
  COUNT(DISTINCT uid) AS total_users
FROM
  share_screen_info
WHERE
  share_screen = 'Yes'
  -- How many users participated in a meeting without Share screen
SELECT
  COUNT(DISTINCT uid) AS total_users
FROM
  share_screen_info
WHERE
  share_screen = 'No'