  /*
Assignment 4.1 - SQL - practice
======================================

link to Instructions & Solutions
https://youtube.com/playlist?list=PLkKJj26K4JZ2vbHgknAdC8upGV7xLsYQB&si=TnKdNPINQ2-NgtXq


It is highly recommended to explore the table's schema before you begin to solve the questions.


`sql_tutorial.zoom_analytics`

*/
  -- Questions
  -- ==========
  /*
Extract all the cities which has 'os' in their name,
sort the results by city name descending
*/
SELECT
  *
FROM
  `sql_tutorial.cities`
WHERE
  CityName LIKE '%os%'
ORDER BY
  CityName DESC /*
How many cities have a Name which contains 2 words?
How many cities have a Name which contains 1 word?
*/
SELECT
  COUNT(DISTINCT
    CASE
      WHEN CityName LIKE '% %' THEN CityName
  END
    ) AS num_cities_with_2_words,
  COUNT(DISTINCT
    CASE
      WHEN CityName NOT LIKE '% %' THEN CityName
  END
    ) AS num_cities_with_1_word
FROM
  `sql_tutorial.cities` /*
How many unique countries exists in the customers table,
*/
SELECT
  COUNT(DISTINCT Country) AS total_countries
FROM
  `sql_tutorial.customers`
  -- extract all the values
SELECT
  DISTINCT Country
FROM
  `sql_tutorial.customers` /*
For all the country names make sure you extract the full name.
For example, if we had the code "IL"  extract the value "Israel"
*/
SELECT
  DISTINCT
  CASE
    WHEN Country = 'UK' THEN 'United Kingdom'
    WHEN Country = 'USA' THEN 'United States'
    ELSE Country
END
  AS Country
FROM
  `sql_tutorial.customers` /*
How many customers does each country have?
Sort the results by the number of customers descending
*/
SELECT
  Country,
  COUNT(DISTINCT CustomerID) AS num_customers
FROM
  `sql_tutorial.customers`
GROUP BY
  Country
ORDER BY
  2 DESC /*
How many names exist in the FirstName and LastName?
For example:
FirstName,LastName

Micky,Mouse
David,Micky
*/
SELECT
  a.FirstName,
  a.LastName,
  b.FirstName,
  b.LastName
FROM
  `sql_tutorial.customers` AS a
JOIN
  `sql_tutorial.customers` AS b
ON
  a.FirstName = b.LastName /*
How many customers have the same first name?
*/
SELECT
  FirstName,
  COUNT(FirstName) AS customers_with_same_fn
FROM
  `sql_tutorial.customers`
GROUP BY
  1 /*
Same as previous, but now try to find out couples who has the same
first 2 letters.
Hint: explore the substring() function

For example:
FirstName,LastName
Michael,Mouse
David,Micky
*/
SELECT
  a.FirstName,
  a.LastName,
  b.FirstName,
  b.LastName
FROM
  `sql_tutorial.customers` AS a
JOIN
  `sql_tutorial.customers` AS b
ON
  SUBSTR(a.FirstName, 1, 2) = SUBSTR(b.LastName, 1, 2) /*
Generate a NewName for each Customer
The format Michael_Mouse
Sort the results by the length of the new name
Hint: Explore the concat()
*/
SELECT
  CONCAT(FirstName, '_', LastName) AS NewName
FROM
  `sql_tutorial.customers`
ORDER BY
  LENGTH(NewName) /*
How many orders each Customer has (Extract FirstName)?
and what is the total ShipWeight for the orders?
Sort the results by number of orders
*/
SELECT
  b.FirstName,
  a.num_orders,
  a.total_ship_weight
FROM (
  SELECT
    CustomerID,
    COUNT(OrderID) AS num_orders,
    SUM(ShipWeight) AS total_ship_weight
  FROM
    `sql_tutorial.orders`
  GROUP BY
    1) AS a
LEFT JOIN
  `sql_tutorial.customers` AS b
ON
  a.CustomerID = b.CustomerID
ORDER BY
  2 DESC
  -- ChatGPT solution for the same problem:
SELECT
  c.FirstName,
  COUNT(o.OrderID) AS num_orders,
  SUM(o.ShipWeight) AS total_ship_weight
FROM
  `sql_tutorial.orders` AS o
LEFT JOIN
  `sql_tutorial.customers` AS c
ON
  o.CustomerID = c.CustomerID
GROUP BY
  c.CustomerID,
  c.FirstName
ORDER BY
  num_orders DESC /*
Who are the people whose city does not exist in the cities table?
*/
SELECT
  a.PersonName,
  b.CityName
FROM
  `sql_tutorial.people` AS a
LEFT JOIN
  `sql_tutorial.cities` AS b
ON
  a.CityID = b.CityID
WHERE
  b.CityName IS NULL /*
What are the cities which dont have any people who live there?
*/
SELECT
  a.PersonName,
  b.CityName
FROM
  `sql_tutorial.people` AS a
RIGHT JOIN
  `sql_tutorial.cities` AS b
ON
  a.CityID = b.CityID
WHERE
  a.PersonName IS NULL /*
Who are the people who their city exists in cities,
extract all the person details and city Name
*/
SELECT
  a.*,
  b.CityName
FROM
  `sql_tutorial.people` AS a
JOIN
  `sql_tutorial.cities` AS b
ON
  a.CityID = b.CityID /*
The population of a city it is the length(CityName) in Square
hint: select power(4,2)
Extract the population size for each combination of 2 cities.
hint: population_function sqrt( power(length(CityName),2) + power(length(CityName_2),2) )
hint: select sqrt(9), sqrt(16)
Please calculate the population (you need to modify a little bit the population_function)
Sort the result by the population size
*/
SELECT
  a.CityName,
  b.CityName AS CityName_2,
  POWER(LENGTH(a.CityName),2) + POWER(LENGTH(b.CityName),2) AS population_size
FROM
  `sql_tutorial.cities` AS a
JOIN
  `sql_tutorial.cities` AS b
ON
  a.CityName < b.CityName
ORDER BY
  3 DESC /*
How many orders each combination of Customer + Employee have?
Extract the Customer & Employee first name.
*/
WITH
  o AS (
  SELECT
    CustomerID,
    EmployeeID,
    COUNT(OrderID) AS t_orders
  FROM
    `sql_tutorial.orders`
  GROUP BY
    ALL)
SELECT
  c.FirstName AS Customer,
  e.FirstName AS Employee,
  o.t_orders
FROM
  o
JOIN
  `sql_tutorial.customers` c
ON
  o.CustomerID = c.CustomerID
JOIN
  `sql_tutorial.employees` e
ON
  o.EmployeeID = e.EmployeeID
ORDER BY
  o.t_orders DESC