USE portfol_project;

SELECT * FROM hotel_revenue_historical_2018;

SELECT * FROM hotel_revenue_historical_2019;

SELECT * FROM hotel_revenue_historical_2020; 

-- with the operator 'UNION', you get all 3 tables appended into one. (works because same number of columns, similar data)

SELECT * FROM hotel_revenue_historical_2018
UNION
SELECT * FROM hotel_revenue_historical_2019
UNION
SELECT * FROM hotel_revenue_historical_2020; 

-- output has around 100k rows
-- CTE(common table expression) but it is temporary. we use 'hotels' to name the 3 tables.

WITH hotels AS (
SELECT * 
FROM hotel_revenue_historical_2018
UNION
SELECT * 
FROM hotel_revenue_historical_2019
UNION
SELECT * FROM hotel_revenue_historical_2020
)

SELECT * from hotels;

-- we create a new table containing all the years

CREATE TABLE full_revenue AS
SELECT * FROM hotel_revenue_historical_2018 
UNION
SELECT * FROM hotel_revenue_historical_2019
UNION
SELECT * FROM hotel_revenue_historical_2020;

-- some exploratory analysis
-- no revenue column but ADR (avg. daily revenue = tot rev/ rooms sold ) and 
-- total stays in weekend nights and week nights. create another column where you add this info

SELECT (stays_in_week_nights + stays_in_weekend_nights)*adr AS revenue 
FROM full_revenue;

-- revenue by year

SELECT	arrival_date_year, 
(stays_in_week_nights + stays_in_weekend_nights)*adr as revenue
FROM full_revenue; 

-- we sum the revenues and GROUP BY year
SELECT	arrival_date_year, sum(stays_in_week_nights + stays_in_weekend_nights)*adr as revenue
FROM full_revenue
GROUP BY arrival_date_year; 


-- group by hotel type and year
SELECT	hotel, arrival_date_year, sum(stays_in_week_nights + stays_in_weekend_nights)*adr as revenue
FROM full_revenue
GROUP BY arrival_date_year, hotel
ORDER BY hotel; 

-- rounding off revenue values to 2 decimals

SELECT	 arrival_date_year, hotel, round(sum(stays_in_week_nights + stays_in_weekend_nights)*adr,2) as revenue
FROM full_revenue
GROUP BY  hotel, arrival_date_year
ORDER BY hotel;

-- append market_segment and meal_cost to full_revenue
-- used last part as query in Power BI while loading database 

SELECT * FROM full_revenue
LEFT JOIN market_segment
ON full_revenue.market_segment = market_segment.market_segment
LEFT JOIN meal_cost
ON meal_cost.meal = full_revenue.meal;

