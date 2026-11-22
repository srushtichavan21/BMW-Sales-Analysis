CREATE DATABASE bmw_sales_db;
USE bmw_sales_db;
CREATE TABLE bmw_sales (
    Model VARCHAR(100),
    Year INT,
    Region VARCHAR(100),
    Color VARCHAR(50),
    Fuel_Type VARCHAR(50),
    Transmission VARCHAR(50),
    Engine_Size_L DECIMAL(5,2),
    Mileage_KM INT,
    Price_USD DECIMAL(12,2),
    Sales_Volume INT,
    Sales_Classification VARCHAR(30)
);
LOAD DATA LOCAL INFILE
'D:/Data Analyst/Projects/BMW Sales Portfolio/1. Dataset/BMW sales data (2010-2024).csv'
INTO TABLE bmw_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Model, Year, Region, Color, Fuel_Type, Transmission,
 Engine_Size_L, Mileage_KM, Price_USD, Sales_Volume, Sales_Classification);
 SELECT COUNT(*) AS Total_Records
FROM bmw_sales;
SELECT * FROM bmw_sales
LIMIT 10;
SELECT
    SUM(Model IS NULL) AS Missing_Model,
    SUM(Year IS NULL) AS Missing_Year,
    SUM(Region IS NULL) AS Missing_Region,
    SUM(Price_USD IS NULL) AS Missing_Price,
    SUM(Sales_Volume IS NULL) AS Missing_Sales
FROM bmw_sales;
SELECT MIN(Year) AS First_Year,
       MAX(Year) AS Last_Year
FROM bmw_sales;
SELECT SUM(Sales_Volume) AS Total_Sales_Volume
FROM bmw_sales;

SELECT
    COUNT(*) AS Total_Records,
    SUM(Sales_Volume) AS Total_Sales_Volume,
    ROUND(AVG(Price_USD), 2) AS Average_Price
FROM bmw_sales;
SELECT
    Model,
    SUM(Sales_Volume) AS Total_Sales
FROM bmw_sales
GROUP BY Model
ORDER BY Total_Sales DESC;
SELECT
    Region,
    SUM(Sales_Volume) AS Total_Sales
FROM bmw_sales
GROUP BY Region
ORDER BY Total_Sales DESC;
SELECT
    Year,
    SUM(Sales_Volume) AS Total_Sales
FROM bmw_sales
GROUP BY Year
ORDER BY Year;

SELECT
    Year,
    SUM(Sales_Volume) AS Total_Sales,
    CASE
        WHEN SUM(Sales_Volume) >= 17500000 THEN 'High'
        WHEN SUM(Sales_Volume) >= 16500000 THEN 'Medium'
        ELSE 'Low'
    END AS Sales_Category
FROM bmw_sales
GROUP BY Year
ORDER BY Year;

WITH Yearly_Sales AS (
    SELECT
        Year,
        SUM(Sales_Volume) AS Total_Sales
    FROM bmw_sales
    GROUP BY Year
)
SELECT
    Year,
    Total_Sales,
    ROUND(
        Total_Sales * 100.0 /
        SUM(Total_Sales) OVER (), 2
    ) AS Sales_Percentage
FROM Yearly_Sales
ORDER BY Total_Sales DESC;

WITH Model_Sales AS (
    SELECT
        Model,
        SUM(Sales_Volume) AS Total_Sales
    FROM bmw_sales
    GROUP BY Model
)
SELECT
    Model,
    Total_Sales,
    RANK() OVER (ORDER BY Total_Sales DESC) AS Sales_Rank
FROM Model_Sales;

WITH Yearly_Sales AS (
    SELECT
        Year,
        SUM(Sales_Volume) AS Total_Sales
    FROM bmw_sales
    GROUP BY Year
)
SELECT
    Year,
    Total_Sales,
    LAG(Total_Sales) OVER (ORDER BY Year) AS Previous_Year_Sales,
    Total_Sales -
    LAG(Total_Sales) OVER (ORDER BY Year) AS Sales_Difference
FROM Yearly_Sales
ORDER BY Year;

WITH Yearly_Sales AS (
    SELECT
        Year,
        SUM(Sales_Volume) AS Total_Sales
    FROM bmw_sales
    GROUP BY Year
),
Sales_Comparison AS (
    SELECT
        Year,
        Total_Sales,
        LAG(Total_Sales) OVER (ORDER BY Year) AS Previous_Sales
    FROM Yearly_Sales
)
SELECT
    Year,
    Total_Sales,
    Previous_Sales,
    ROUND(
        (Total_Sales - Previous_Sales) * 100.0 /
        Previous_Sales, 2
    ) AS Growth_Percentage
FROM Sales_Comparison
ORDER BY Year;

SELECT
    Model,
    SUM(Sales_Volume) AS Total_Sales
FROM bmw_sales
GROUP BY Model
HAVING SUM(Sales_Volume) > (
    SELECT AVG(Model_Total)
    FROM (
        SELECT SUM(Sales_Volume) AS Model_Total
        FROM bmw_sales
        GROUP BY Model
    ) AS Model_Averages
)
ORDER BY Total_Sales DESC;

CREATE TABLE model_category (
    Model VARCHAR(100),
    Category VARCHAR(50)
);
INSERT INTO model_category VALUES
('7 Series', 'Luxury Sedan'),
('5 Series', 'Executive Sedan'),
('3 Series', 'Sports Sedan'),
('X1', 'Compact SUV'),
('X3', 'Mid-size SUV'),
('X5', 'Luxury SUV'),
('X6', 'Sports Activity Coupe'),
('M3', 'Performance Sedan'),
('M5', 'Performance Sedan'),
('i3', 'Electric'),
('i8', 'Hybrid Sports Car');

SELECT * FROM model_category;

SELECT
    b.Model,
    c.Category,
    SUM(b.Sales_Volume) AS Total_Sales
FROM bmw_sales b
INNER JOIN model_category c
    ON b.Model = c.Model
GROUP BY
    b.Model,
    c.Category
ORDER BY Total_Sales DESC;

SELECT
    Fuel_Type,
    SUM(Sales_Volume) AS Total_Sales,
    ROUND(AVG(Price_USD), 2) AS Average_Price
FROM bmw_sales
GROUP BY Fuel_Type
ORDER BY Total_Sales DESC;

SELECT
    Transmission,
    COUNT(*) AS Total_Records,
    SUM(Sales_Volume) AS Total_Sales
FROM bmw_sales
GROUP BY Transmission;

SELECT
    Model,
    SUM(Sales_Volume) AS Total_Sales
FROM bmw_sales
GROUP BY Model
ORDER BY Total_Sales DESC
LIMIT 5;

SELECT
    COUNT(*) AS Total_Records,
    COUNT(DISTINCT Model) AS Unique_Models,
    COUNT(DISTINCT Region) AS Unique_Regions,
    SUM(Model IS NULL) AS Missing_Models,
    SUM(Price_USD <= 0) AS Invalid_Prices,
    SUM(Sales_Volume < 0) AS Invalid_Sales
FROM bmw_sales;

SELECT
    Region,
    SUM(Sales_Volume) AS Total_Sales,
    ROUND(
        SUM(Sales_Volume) * 100.0 /
        (SELECT SUM(Sales_Volume)
         FROM bmw_sales),
        2
    ) AS Sales_Percentage
FROM bmw_sales
GROUP BY Region
ORDER BY Total_Sales DESC;