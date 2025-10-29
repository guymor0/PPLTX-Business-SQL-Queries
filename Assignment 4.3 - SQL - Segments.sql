/*

The retargeting team request from you to generate 
sements for the daily campaigns

It is highly recommended to explore the table's schema before you begin to solve the questions.


`ppltx-ba-course.sql_tutorial.v_app_events`

*/
-- Genarate a segment for the users who were active on the last 0-3 days
SELECT uid
FROM
(SELECT uid
FROM `ppltx-ba-course.sql_tutorial.v_app_events`
WHERE date(timestamp) = CURRENT_DATE())
UNION DISTINCT
(SELECT uid
FROM `ppltx-ba-course.sql_tutorial.v_app_events`
WHERE date(timestamp) = CURRENT_DATE() -1)
UNION DISTINCT
(SELECT uid
FROM `ppltx-ba-course.sql_tutorial.v_app_events`
WHERE date(timestamp) = CURRENT_DATE() -2)
UNION DISTINCT
(SELECT uid
FROM `ppltx-ba-course.sql_tutorial.v_app_events`
WHERE date(timestamp) = CURRENT_DATE() -3);

-- Another solution:
-- At first we will calculate the last active time for each user
-- Then, we will implement the constraint where date diff is between 0 to 3.

CREATE TEMP TABLE last_active AS
   (
  SELECT
    uid,
    MAX(DATE(timestamp)) AS last_active_date
  FROM
    `ppltx-ba-course.sql_tutorial.v_app_events`
  GROUP BY
    uid );

SELECT
  uid
FROM
  last_active
WHERE
  DATE_DIFF(CURRENT_DATE(), last_active_date, DAY) BETWEEN 0
  AND 3;


-- Genarate a segment for the users who were active on the last 4-7 days
SELECT
  uid
FROM
  last_active
WHERE
  DATE_DIFF(CURRENT_DATE(), last_active_date, DAY) BETWEEN 4
  AND 7;

-- Genarate a segment for the users who were active on the last 8-90 days
SELECT
  uid
FROM
  last_active
WHERE
  DATE_DIFF(CURRENT_DATE(), last_active_date, DAY) BETWEEN 8
  AND 90;