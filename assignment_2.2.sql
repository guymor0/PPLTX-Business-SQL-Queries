  -- Questions
  -- ==========
  -- For each employee, how many orders has more than 150 tons is ShipWeight
  --------------------------------------------------------------------------
SELECT
  EmployeeID,
  COUNT(CASE
      WHEN ShipWeight > 150 THEN 1
  END
    ) AS OrderCount
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
GROUP BY
  EmployeeID
  -- For each employee, did he has at least one order which
  -- the diff between RequiredDate and OrderDate was more than 30 days
  ---------------------------------------------------------------------
SELECT
  EmployeeID,
  CASE
    WHEN SUM(CASE
      WHEN DATE_DIFF(RequiredDate, OrderDate, DAY) > 30 THEN 1
      ELSE 0
  END
    ) >= 1 THEN 'Yes'
    ELSE 'No'
END
  AS HasOrderWithLongDelay
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
GROUP BY
  EmployeeID
  -- For each employee, how many unique customers made an order
  ------------------------------------------------------------
SELECT
  EmployeeID,
  COUNT(DISTINCT CustomerID) AS UniqueCustomerCount
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
GROUP BY
  EmployeeID
  -- For each employee, what is the AVG ShipDuration
  --------------------------------------------------
SELECT
  EmployeeID,
  ROUND(AVG(ShipDuration), 2) AS AVG_ShipDuration_Days
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
GROUP BY
  EmployeeID
  -- For each employee, when was it last order and what was the ShipDuration
  --------------------------------------------------------------------------
SELECT
  EmployeeID,
  ShipDuration,
  OrderDate
FROM (
  SELECT
    EmployeeID,
    ShipDuration,
    OrderDate,
    ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate DESC) AS rn
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders` )
WHERE
  rn = 1
  -- For each employee, who were the first and the last customers
  --------------------------------------------------------------------------
SELECT
  EmployeeID,
  MAX(CASE
      WHEN rn_asc = 1 THEN CustomerID
  END
    ) AS FirstCustomer,
  MAX(CASE
      WHEN rn_desc = 1 THEN CustomerID
  END
    ) AS LastCustomer
FROM (
  SELECT
    EmployeeID,
    CustomerID,
    ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate ASC) AS rn_asc,
    ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate DESC) AS rn_desc
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders` )
WHERE
  rn_asc = 1
  OR rn_desc = 1
GROUP BY
  EmployeeID
  -- For each employee, how many customers he served in
  -- the first 7 days of activity and what was the accumulative ShipWeight
  --------------------------------------------------------------------------
SELECT
  EmployeeID,
  COUNT(DISTINCT CustomerID) AS CustomerCount,
  SUM(ShipWeight) AS AccumulativeShipWeight
FROM (
  SELECT
    EmployeeID,
    CustomerID,
    ShipWeight,
    OrderDate,
    MIN(OrderDate) OVER (PARTITION BY EmployeeID) AS FirstOrderDate
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders` )
WHERE
  OrderDate BETWEEN FirstOrderDate
  AND DATE_ADD(FirstOrderDate, INTERVAL 6 DAY)
GROUP BY
  EmployeeID
  -- What was the employees’ title which has
  -- the highest AVG ShipDuration per employee.
  ----------------------------------------------------------------------
SELECT
  Title,
  AVG_ShipDuration_Days
FROM (
  SELECT
    EmployeeID,
    AVG(ShipDuration) AS AVG_ShipDuration_Days
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders`
  GROUP BY
    EmployeeID ) AS a
LEFT JOIN
  `ppltx-ba-course-guy.sql_tutorial.employees` AS b
ON
  a.EmployeeID = b.EmployeeID
ORDER BY
  2 DESC
  -- For each employee, Who is the customer who made the most
  -- orders and what is his AVG ShipWeight per order
  ----------------------------------------------------------------------
SELECT
  EmployeeID,
  CustomerID,
  COUNT(OrderID) AS OrderCount,
  AVG(ShipWeight) AS AVG_ShipWeight
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
GROUP BY
  EmployeeID,
  CustomerID
QUALIFY
  (ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY COUNT(OrderID) DESC) = 1)
  -- For each employee, What is the median ShipWeight and ShipDuration of orders
  -------------------------------------------------------------------------------
SELECT
  DISTINCT EmployeeID,
  PERCENTILE_CONT(ShipWeight, 0.5) OVER (PARTITION BY EmployeeID) AS Median_ShipWeight,
  PERCENTILE_CONT(ShipDuration, 0.5) OVER (PARTITION BY EmployeeID) AS Median_ShipDuration
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
  -- How many ShipType each OrderDate had?
  -----------------------------------------
SELECT
  OrderDate,
  COUNT(DISTINCT ShipType) AS ShipTypeCount
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
GROUP BY
  OrderDate
  -- Can you merge all the queries above into a Single Query, which will contain all the KPIs?
  -- Add as much KPIs as you can
  ---------------------------------------------------------------------------------------------
WITH
  t_orders_ShipWeight_g150 AS (
  SELECT
    EmployeeID,
    COUNT(CASE
        WHEN ShipWeight > 150 THEN 1
    END
      ) AS OrderCount
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders`
  GROUP BY
    EmployeeID ),
  orders_g30_days AS (
  SELECT
    EmployeeID,
    CASE
      WHEN SUM(CASE
        WHEN DATE_DIFF(RequiredDate, OrderDate, DAY) > 30 THEN 1
        ELSE 0
    END
      ) >= 1 THEN 'Yes'
      ELSE 'No'
  END
    AS HasOrderWithLongDelay
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders`
  GROUP BY
    EmployeeID ),
  unique_customers AS (
  SELECT
    EmployeeID,
    COUNT(DISTINCT CustomerID) AS UniqueCustomerCount
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders`
  GROUP BY
    EmployeeID ),
  AVG_ShipDuration_CTE AS (
  SELECT
    EmployeeID,
    ROUND(AVG(ShipDuration), 2) AS AVG_ShipDuration_Days
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders`
  GROUP BY
    EmployeeID ),
  last_order_shipDuration AS (
  SELECT
    EmployeeID,
    ShipDuration,
    OrderDate
  FROM (
    SELECT
      EmployeeID,
      ShipDuration,
      OrderDate,
      ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate DESC) AS rn
    FROM
      `ppltx-ba-course-guy.sql_tutorial.orders` )
  WHERE
    rn = 1 ),
  first_last_customers AS (
  SELECT
    EmployeeID,
    MAX(CASE
        WHEN rn_asc = 1 THEN CustomerID
    END
      ) AS FirstCustomer,
    MAX(CASE
        WHEN rn_desc = 1 THEN CustomerID
    END
      ) AS LastCustomer
  FROM (
    SELECT
      EmployeeID,
      CustomerID,
      ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate ASC) AS rn_asc,
      ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate DESC) AS rn_desc
    FROM
      `ppltx-ba-course-guy.sql_tutorial.orders` )
  WHERE
    rn_asc = 1
    OR rn_desc = 1
  GROUP BY
    EmployeeID ),
  customer_first_7_days AS (
  SELECT
    EmployeeID,
    COUNT(DISTINCT CustomerID) AS CustomerCount,
    SUM(ShipWeight) AS AccumulativeShipWeight
  FROM (
    SELECT
      EmployeeID,
      CustomerID,
      ShipWeight,
      OrderDate,
      MIN(OrderDate) OVER (PARTITION BY EmployeeID) AS FirstOrderDate
    FROM
      `ppltx-ba-course-guy.sql_tutorial.orders` )
  WHERE
    OrderDate BETWEEN FirstOrderDate
    AND DATE_ADD(FirstOrderDate, INTERVAL 6 DAY)
  GROUP BY
    EmployeeID ),
  customer_most_orders AS (
  SELECT
    EmployeeID,
    CustomerID,
    COUNT(OrderID) AS OrderCount,
    AVG(ShipWeight) AS AVG_ShipWeight
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders`
  GROUP BY
    EmployeeID,
    CustomerID
  QUALIFY
    (ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY COUNT(OrderID) DESC) = 1) ),
  median_ShipDuration AS (
  SELECT
    DISTINCT EmployeeID,
    PERCENTILE_CONT(ShipWeight, 0.5) OVER (PARTITION BY EmployeeID) AS Median_ShipWeight,
    PERCENTILE_CONT(ShipDuration, 0.5) OVER (PARTITION BY EmployeeID) AS Median_ShipDuration
  FROM
    `ppltx-ba-course-guy.sql_tutorial.orders` )
SELECT
  a.EmployeeID,
  a.OrderCount,
  b.HasOrderWithLongDelay,
  c.UniqueCustomerCount,
  d.AVG_ShipDuration_Days,
  e.ShipDuration,
  e.OrderDate,
  f.FirstCustomer,
  f.LastCustomer,
  g.CustomerCount,
  g.AccumulativeShipWeight,
  h.CustomerID,
  h.OrderCount,
  h.AVG_ShipWeight,
  i.Median_ShipWeight,
  i.Median_ShipDuration
FROM
  t_orders_ShipWeight_g150 AS a
LEFT JOIN
  orders_g30_days AS b
ON
  a.EmployeeID = b.EmployeeID
LEFT JOIN
  unique_customers AS c
ON
  a.EmployeeID = c.EmployeeID
LEFT JOIN
  AVG_ShipDuration_CTE AS d
ON
  a.EmployeeID = d.EmployeeID
LEFT JOIN
  last_order_shipDuration AS e
ON
  a.EmployeeID = e.EmployeeID
LEFT JOIN
  first_last_customers AS f
ON
  a.EmployeeID = f.EmployeeID
LEFT JOIN
  customer_first_7_days AS g
ON
  a.EmployeeID = g.EmployeeID
LEFT JOIN
  customer_most_orders AS h
ON
  a.EmployeeID = h.EmployeeID
LEFT JOIN
  median_ShipDuration AS i
ON
  a.EmployeeID = i.EmployeeID
  -- =================
  -- CTE & Row Number
  -- =================
  -- Extract the order details (all columns) of 2 earliest orders for each EmployeeID
SELECT
  *
FROM
  `ppltx-ba-course-guy.sql_tutorial.orders`
QUALIFY
  (ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY OrderDate ASC) < 3)
ORDER BY
  EmployeeID,
  OrderDate
  -- Extract the two highest players from each team
  --------------------------------------------------
SELECT
  *
FROM
  `ppltx-ba-course-guy.sql_tutorial.basketball`
QUALIFY
  (row_number () OVER (PARTITION BY team ORDER BY height DESC ) < 3)
ORDER BY
  height DESC
  -- Matchup
  -- For each matchup of a player from one team vs a player from the other team announce
  -- the name of the team with the highest player.
  ----------------------------------------------------------------------------------------------------
  -- For example:
  -- playerA,playerB,team
  -- 90,12,Red
  -- 90,3,Blue
  -- Please write down the query which will provide the solution
SELECT
  A.playerID AS playerA,
  B.playerID AS playerB,
  CASE WHEN A.height > B.height THEN A.team
  WHEN A.height < B.height THEN B.team
  ELSE 'Draw' END AS team
FROM
  `ppltx-ba-course-guy.sql_tutorial.basketball` AS A
JOIN `ppltx-ba-course-guy.sql_tutorial.basketball` AS B
ON
  A.team < B.team
ORDER BY 
  A.playerID, B.playerID