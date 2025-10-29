/*
Generate Aggregated panels:
- Daily
- Monthly
- Lifetime
*/

-- Daily Panel:

create or replace table `ppltx-ba-course-guy.agg_citibike.daily_bike_panel`
OPTIONS (
  description="The Daily KPIs for each bike which used at the given date"
) as
(
SELECT
--   Dimentions
  bikeid,
  date(starttime) as dt,
--   metrics
  COUNT(1) AS t_trips,  -- Total trip
  round( SUM(tripduration)/3600,2) as t_tripduration,  -- total trip duration in hours
  min(starttime) as first_ride_time,
  max(stoptime) as last_ride_time,
  count(distinct start_station_id ) as t_stations,
  substr(   min(concat(   substr(  cast(starttime as string) ,0,19)   , start_station_id)), 20)  as first_start_station_id,
  SUM(CASE WHEN usertype = 'Subscriber' THEN 1 END) AS T_Subscriber_rides,
  SUM(CASE WHEN usertype = 'Customer' THEN 1 END) AS T_Customer_rides,
  
  SUM(CASE WHEN gender = 'male' THEN 1 END) AS T_male_rides,
  SUM(CASE WHEN gender = 'female' THEN 1 END) AS T_female_rides,
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips`
    where bikeid is not null

GROUP BY
  1,2
);


-- Monthly Panel:

create or replace table `ppltx-ba-course-guy.agg_citibike.monthly_bike_panel`
OPTIONS (
  description="The Montly KPIs for each bike which used at the given date"
) as
(
SELECT
--   Dimentions
  bikeid,
  date_trunc(dt, month) dt,
--   metrics
  count(1) as t_active_days,

  SUM(t_trips) as t_trips, -- Total trip

  round(SUM(t_tripduration),2) as t_tripduration,  -- total trip duration in hours
  
  min(first_ride_time) as first_ride_time,
  max(last_ride_time) as last_ride_time,
  -- count(distinct start_station_id ) as t_stations, -- Extract only from the raw data
  substr(   min(concat(cast(dt as string), first_start_station_id)), 10)  as first_start_station_id,
  SUM(T_Subscriber_rides) AS T_Subscriber_rides,
  SUM(T_Customer_rides) AS T_Customer_rides,
  
  SUM(T_male_rides) AS T_male_rides,
  SUM(T_female_rides) AS T_female_rides,
FROM
  `ppltx-ba-course-guy.agg_citibike.daily_bike_panel`
  where bikeid is not null
GROUP BY
  1,2
);

-- Lifetime Panel:

create or replace table `ppltx-ba-course-guy.agg_citibike.bike_panel`
OPTIONS (
  description="The LifeTime KPIs for each bike which used at the given date"
) as
(
SELECT
--   Dimentions
  bikeid,

--   metrics
  min(dt) as install_dt,
  max(dt) as last_active_dt,
  count(1) as t_active_days,

  SUM(t_trips) as t_trips, -- Total trip

  round(SUM(t_tripduration),2) as t_tripduration,  -- total trip duration in hours
  
  min(fist_ride_time) as fist_ride_time,
  max(last_ride_time) as last_ride_time,
  -- count(distinct start_station_id ) as t_stations, -- Extract only from the raw data
  substr(   min(concat(cast(dt as string), first_start_station_id)), 10)  as first_start_station_id,
  SUM(T_Subscriber_rides) AS T_Subscriber_rides,
  SUM(T_Customer_rides) AS T_Customer_rides,
  
  SUM(T_male_rides) AS T_male_rides,
  SUM(T_female_rides) AS T_female_rides,
FROM
  `ppltx-ba-course-guy.agg_citibike.daily_bike_panel`
GROUP BY
  1
);