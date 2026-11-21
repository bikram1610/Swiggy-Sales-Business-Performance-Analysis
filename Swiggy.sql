
SELECT *
FROM   orders;

SELECT COUNT(*)
FROM   orders;

-- Data Cleaning & Validation

-- Null Check
SELECT SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS Null_State,
       SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS Null_City,
       SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Null_Order_Date,
       SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS Null_Restaurant_Name,
       SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Null_Location,
       SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Null_Category,
       SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS Null_Dish_name,
       SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS Null_Price_INR,
       SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS Null_Rating,
       SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS Null_Rating_count
FROM   orders;

-- Duplicate Check
SELECT   State,
         City,
         Order_Date,
         Restaurant_Name,
         Location,
         Category,
         Dish_Name,
         Price_INR,
         Rating,
         Rating_Count,
         count(*) AS duplicates
FROM     orders
GROUP BY State,
         City,
         Order_Date,
         Restaurant_Name,
         Location,
         Category,
         Dish_Name,
         Price_INR,
         Rating,
         Rating_Count
HAVING   count(*) > 1;

-- Duplicate Deletion
WITH duplicates
AS   (SELECT *,
             ROW_NUMBER() OVER (PARTITION BY State,
                                             City,
                                             Order_Date,
                                             Restaurant_Name,
                                             Location,
                                             Category,
                                             Dish_Name,
                                             Price_INR,
                                             Rating,
                                             Rating_Count ORDER BY state) AS rn
      FROM   orders)
DELETE duplicates
WHERE  rn > 1;

-- Creating Schemas
-- Dimension Tables

--Date Table
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_id    INT          IDENTITY (1, 1) PRIMARY KEY,
    full_date  DATE        ,
    year       INT         ,
    month      INT         ,
    month_name VARCHAR (20),
    quarter    INT         ,
    day        INT         ,
    week       INT         
);

--Location Table
DROP TABLE IF EXISTS dim_location;

CREATE TABLE dim_location (
    loc_id   INT          IDENTITY (1, 1) PRIMARY KEY,
    state    VARCHAR (20),
    city     VARCHAR (30),
    location VARCHAR (50)
);

--Restaurant Table
DROP TABLE IF EXISTS dim_restaurant;

CREATE TABLE dim_restaurant (
    res_id   INT          IDENTITY (1, 1) PRIMARY KEY,
    res_name VARCHAR (50)
);

--Category Table
DROP TABLE IF EXISTS dim_category;

CREATE TABLE dim_category (
    cat_id   INT           IDENTITY (1, 1) PRIMARY KEY,
    category VARCHAR (150)
);

ALTER TABLE dim_category ALTER COLUMN category VARCHAR (100);

--Dish Table
DROP TABLE IF EXISTS dim_dish;

CREATE TABLE dim_dish (
    dish_id   INT          IDENTITY (1, 1) PRIMARY KEY,
    dish_name VARCHAR (50)
);

ALTER TABLE dim_dish ALTER COLUMN dish_name VARCHAR (150);

--Fact Table
DROP TABLE IF EXISTS fact_orders;

CREATE TABLE fact_orders (
    order_id      INT             IDENTITY (1, 1) PRIMARY KEY,
    price_INR     DECIMAL (10, 2),
    rating        DECIMAL (4, 2) ,
    rating_count  INT            ,
    date_id       INT            ,
    location_id   INT            ,
    restaurant_id INT            ,
    category_id   INT            ,
    dish_id       INT            ,
    FOREIGN KEY (date_id) REFERENCES dim_date (date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location (loc_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant (res_id),
    FOREIGN KEY (category_id) REFERENCES dim_category (cat_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish (dish_id)
);

SELECT *
FROM   fact_orders;

-- Insert data into tables

-- Insert into dim_date table

INSERT INTO dim_date (
    full_date,
    year,
    month,
    month_name,
    quarter,
    day,
    week
)
SELECT DISTINCT Order_Date,
                year(order_date),
                month(order_date),
                DATENAME(month, order_date),
                DATEPART(quarter, order_date),
                day(order_date),
                DATEPART(week, order_date)
FROM   orders
WHERE  Order_Date IS NOT NULL;

SELECT   *
FROM     dim_date
ORDER BY full_date;

-- Insert into dim_location table
INSERT INTO dim_location (
    state,
    city,
    location
)
SELECT DISTINCT state,
                city,
                location
FROM   orders;

SELECT *
FROM   dim_location;

-- Insert into dim_restaurant table
INSERT INTO dim_restaurant (
    res_name
)
SELECT DISTINCT restaurant_name
FROM   orders;

SELECT *
FROM   dim_restaurant;

-- Insert into dim_category table
INSERT INTO dim_category (
    category
)
SELECT DISTINCT category
FROM   orders;

SELECT *
FROM   dim_category;

-- Insert into dim_dish table
INSERT INTO dim_dish (
    dish_name
)
SELECT DISTINCT dish_name
FROM   orders;

-- Insert into fact_orders table
INSERT INTO fact_orders (
    price_INR,
    rating,
    rating_count,
    date_id,
    location_id,
    restaurant_id,
    category_id,
    dish_id
)
SELECT o.price_inr,
       o.rating,
       o.rating_count,
       d.date_id,
       l.loc_id,
       r.res_id,
       c.cat_id,
       dd.dish_id
FROM   orders AS o
       INNER JOIN
       dim_date AS d
       ON o.order_date = d.full_date
       INNER JOIN
       dim_location AS l
       ON o.state = l.state
          AND o.city = l.city
          AND o.location = l.location
       INNER JOIN
       dim_restaurant AS r
       ON o.restaurant_name = r.res_name
       INNER JOIN
       dim_category AS c
       ON o.category = c.category
       INNER JOIN
       dim_dish AS dd
       ON o.dish_name = dd.dish_name;

SELECT *
FROM   fact_orders;

-- All the tables together
SELECT *
FROM   fact_orders AS f
       INNER JOIN
       dim_date AS d
       ON f.date_id = d.date_id
       INNER JOIN
       dim_location AS l
       ON f.location_id = l.loc_id
       INNER JOIN
       dim_restaurant AS r
       ON f.restaurant_id = r.res_id
       INNER JOIN
       dim_category AS c
       ON f.category_id = c.cat_id
       INNER JOIN
       dim_dish AS dd
       ON f.dish_id = dd.dish_id;

-- KPI Tracking
-- Total orders
SELECT count(*) AS Total_Orders
FROM   fact_orders;

-- Total revenue
SELECT format (
           sum (price_inr) / 1000000,
           'N2'
       ) + ' Million' AS Total_Revenue
FROM   fact_orders;

-- Average dish price
SELECT format (
           avg (price_inr),
           'N2'
       ) AS avg_dish_price
FROM   fact_orders;

-- Average rating
SELECT format (
           avg (rating),
           'N2'
       ) AS Avg_Rating
FROM   fact_orders;

-- Deep dive analysis
-- Monthly trends
SELECT   d.month_name,
         d.year,
         count(*) AS Total_Orders,
         format (
             sum (f.price_inr) / 1000000,
             'N2'
         ) + ' Million' AS Total_Revenue,
         format (
             avg (f.price_inr),
             'N2'
         ) AS Average_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_date AS d
         ON f.date_id = d.date_id
GROUP BY d.month_name,
         d.year
ORDER BY Total_Revenue DESC;

-- Quarterly trends 
SELECT   d.year,
         d.quarter,
         count(*) AS Total_Orders,
         format (
             sum (f.price_inr) / 1000000,
             'N2'
         ) + ' Million' AS Total_Revenue,
         format (
             avg (f.price_inr),
             'N2'
         ) AS Average_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_date AS d
         ON f.date_id = d.date_id
GROUP BY d.year,
         d.quarter
ORDER BY d.quarter;

-- Daily trends
SELECT   DATENAME(WEEKDAY, d.full_date) AS Day,
         count(*) AS Total_Orders,
         format (
             sum (f.price_inr) / 1000000,
             'N2'
         ) + ' Million' AS Total_Revenue,
         format (
             avg (f.price_inr),
             'N2'
         ) AS Average_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_date AS d
         ON f.date_id = d.date_id
GROUP BY DATENAME(WEEKDAY, d.full_date)
ORDER BY Total_Revenue;

-- Top 10 cities by order volumn
SELECT   TOP 10 l.city,
                count(*) AS Total_Orders
FROM     fact_orders AS f
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY l.city
ORDER BY Total_Orders DESC;

-- Buttom 10 cities by order volumn
SELECT   TOP 10 l.city,
                count(*) AS Total_Orders
FROM     fact_orders AS f
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY l.city
ORDER BY Total_Orders ASC;

-- Top 10 cities by revenue
SELECT   TOP 10 l.city,
                format (
                    sum (price_inr) / 1000000,
                    'N2'
                ) + ' Million' AS Total_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY l.city
ORDER BY Total_Revenue DESC;

-- Buttom 10 cities by revenue
SELECT   TOP 10 l.city,
                format (
                    sum (price_inr) / 1000000,
                    'N2'
                ) + ' Million' AS Total_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY l.city
ORDER BY Total_Revenue ASC;

-- Top 5 states by revenue
SELECT   TOP 5 l.state,
               format (
                   sum (price_inr) / 1000000,
                   'N2'
               ) + ' Million' AS Total_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY l.state
ORDER BY Total_Revenue DESC;

-- Buttom 5 cities by revenue
SELECT   TOP 5 l.state,
               format (
                   sum (price_inr) / 1000000,
                   'N2'
               ) + ' Million' AS Total_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY l.state
ORDER BY Total_Revenue ASC;

-- Top 20 restaurants by revenue
SELECT   TOP 20 r.res_name,
                l.city,
                l.state,
                format (
                    sum (price_inr) / 1000000,
                    'N2'
                ) + ' Million' AS Total_Revenue
FROM     fact_orders AS f
         INNER JOIN
         dim_restaurant AS r
         ON f.restaurant_id = r.res_id
         INNER JOIN
         dim_location AS l
         ON f.location_id = l.loc_id
GROUP BY r.res_name,
         l.city,
         l.state
ORDER BY Total_Revenue DESC;

-- Top 50 category by order volumn
SELECT   TOP 50 c.category AS Category,
                count(*) AS Total_Orders
FROM     fact_orders AS f
         INNER JOIN
         dim_category AS c
         ON f.category_id = c.cat_id
GROUP BY c.category
ORDER BY Total_Orders DESC;

-- Top 50 dishes by order volumn
SELECT   TOP 50 d.dish_name AS Dish,
                count(*) AS Total_Orders
FROM     fact_orders AS f
         INNER JOIN
         dim_dish AS d
         ON f.dish_id = d.dish_id
GROUP BY d.dish_name
ORDER BY Total_Orders DESC;

-- Cuisin performance
SELECT   TOP 20 c.category AS Category,
                count(*) AS Total_Orders,
                format (
                    avg (rating),
                    'N2'
                ) AS Avg_Rating
FROM     fact_orders AS f
         INNER JOIN
         dim_category AS c
         ON f.category_id = c.cat_id
GROUP BY c.category
ORDER BY Total_Orders DESC;

-- Total orders by price range
SELECT   CASE WHEN price_inr < 100 THEN 'Under 100' WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199' WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299' WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499' ELSE '500+' END AS price_range,
         count(*) AS total_orders
FROM     fact_orders
GROUP BY CASE WHEN price_inr < 100 THEN 'Under 100' WHEN price_inr BETWEEN 100 AND 199 THEN '100 - 199' WHEN price_inr BETWEEN 200 AND 299 THEN '200 - 299' WHEN price_inr BETWEEN 300 AND 499 THEN '300 - 499' ELSE '500+' END
ORDER BY total_orders DESC;

-- Rating count distribution
SELECT   rating,
         count(*) AS count
FROM     fact_orders
GROUP BY rating
ORDER BY count DESC;