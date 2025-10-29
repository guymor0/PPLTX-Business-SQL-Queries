  /*
ppltx_sql_medium_02_monthly_agg_q

https://console.cloud.google.com/bigquery?ws=!1m7!1m6!12m5!1m3!1sppltx-academy!2sus-central1!3sf539047b-0516-4402-822d-50c86ec48a21!2e1

Level: Medium

What is the monthly aggregation by countries?

Transactions table:
+------+---------+-----------+-------+------------+
| id   | country | status    | price | date       |
+------+---------+---------- +-------+------------+
| 11   | US      | succeed   | 8     | 2023-04-12 |
| 12   | GB      | canceled  | 10    | 2023-04-10 |
| 13   | US      | succeed   | 15    | 2023-05-11 |
| 14   | DE      | canceled  | 17    | 2023-05-27 |
| 15   | GB      | succeed   | 10    | 2023-06-19 |
| 16   | DE      | canceled  | 2     | 2023-04-21 |
+------+---------+-----------+-------+------------+


*/
  -- all the users and their install time
WITH
  transactions AS (
  SELECT
    11 AS id,
    "US" AS country,
    "succeed" AS status,
    8 AS price,
    DATE("2023-04-12") AS date
  UNION ALL
  SELECT
    12 AS id,
    "GB" AS country,
    "canceled" AS status,
    10 AS price,
    DATE("2023-04-10") AS date
  UNION ALL
  SELECT
    13 AS id,
    "US" AS country,
    "succeed" AS status,
    15 AS price,
    DATE("2023-05-11") AS date
  UNION ALL
  SELECT
    14 AS id,
    "DE" AS country,
    "canceled" AS status,
    17 AS price,
    DATE("2023-05-27") AS date
  UNION ALL
  SELECT
    15 AS id,
    "GB" AS country,
    "succeed" AS status,
    10 AS price,
    DATE("2023-06-19") AS date
  UNION ALL
  SELECT
    16 AS id,
    "DE" AS country,
    "canceled" AS status,
    2 AS price,
    DATE("2023-04-21") AS date )
  
  -- What is the monthly aggregation?
  -- write your query below
SELECT
  date_trunc(transactions.date,month) as month,
  transactions.country,
  count(transactions.id) as total_trans,
  sum(case when transactions.status = "succeed" then 1 end) as total_succeed,
  sum(transactions.price) as total_price,
  sum(case when transactions.status = "succeed" then price end) as total_succeed_revenue
FROM
  transactions
GROUP BY 1,2
  /*
Solution

+-------------+---------+-------------+---------------+--------------+-----------------------+
| month       | country | total_trans | total_succeed | total_price  | total_revenue_succeed |
+-------------+---------+-------------+---------------+--------------+-----------------------+
| 2023-04-01  | US      | 2           | 1             | 18           | 8                     |
| 2023-04-01  | GB      | 1           |               | 10           |                       |
| 2023-05-01  | US      | 1           | 1             | 15           | 15                    |
| 2023-05-01  | DE      | 1           |               | 17           |                       |
| 2023-06-01  | GB      | 1           | 1             | 10           | 10                    |
| 2023-04-01  | DE      | 1           |               | 2            |                       |
+-------------+---------+-------------+---------------+--------------+-----------------------+
*/