--1. Top 5 brands by receipts scanned among users 21 and over

SELECT p.BRAND, COUNT(t.RECEIPT_ID) AS receipt_count
FROM transactions t
JOIN users u ON t.USER_ID = u.ID
JOIN products p ON t.BARCODE = p.BARCODE
WHERE DATE_PART('year', AGE(NOW(), u.BIRTH_DATE)) >= 21
GROUP BY p.BRAND
ORDER BY receipt_count DESC
LIMIT 5;

--2. Top 5 brands by sales among users that have had their account for at least

SELECT p.BRAND, SUM(t.FINAL_SALE) AS total_sales
FROM transactions t
JOIN users u ON t.USER_ID = u.ID
JOIN products p ON t.BARCODE = p.BARCODE
WHERE u.CREATED_DATE <= NOW() - INTERVAL '6 months'
GROUP BY p.BRAND
ORDER BY total_sales DESC
LIMIT 5;

--3. Percentage of sales in the Health & Wellness category by generation

SELECT 
    CASE 
        WHEN DATE_PART('year', AGE(NOW(), u.BIRTH_DATE)) BETWEEN 18 AND 24 THEN 'Gen Z'
        WHEN DATE_PART('year', AGE(NOW(), u.BIRTH_DATE)) BETWEEN 25 AND 40 THEN 'Millennials'
        WHEN DATE_PART('year', AGE(NOW(), u.BIRTH_DATE)) BETWEEN 41 AND 56 THEN 'Gen X'
        ELSE 'Boomers+' 
    END AS generation,
    SUM(CASE WHEN p.CATEGORY_1 = 'Health & Wellness' THEN t.FINAL_SALE ELSE 0 END) * 100.0 / SUM(t.FINAL_SALE) AS percentage_of_sales
FROM transactions t
JOIN users u ON t.USER_ID = u.ID
JOIN products p ON t.BARCODE = p.BARCODE
GROUP BY generation
ORDER BY percentage_of_sales DESC;


--1. Who are Fetch’s power users?
--Assumptions:
/*Power users are defined as users who have scanned the most receipts and spent the most money.
We'll consider users in the top 5% of both receipts scanned and total sales.
The transactions table tracks receipts and sales, and the users table provides user details.*/

WITH TopUsers AS (
    SELECT USER_ID, 
           COUNT(RECEIPT_ID) AS total_receipts,
           SUM(FINAL_SALE) AS total_spent
    FROM transactions
    GROUP BY USER_ID
), 
Percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_receipts) AS receipts_threshold,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY total_spent) AS sales_threshold
    FROM TopUsers
)
SELECT u.ID, u.BIRTH_DATE, u.STATE, tu.total_receipts, tu.total_spent
FROM TopUsers tu
JOIN users u ON tu.USER_ID = u.ID
JOIN Percentiles p ON tu.total_receipts >= p.receipts_threshold 
                   AND tu.total_spent >= p.sales_threshold
ORDER BY tu.total_spent DESC;
--This retrieves the top 5% of users by both scanned receipts and total spending, defining them as power users.


--2. Which is the leading brand in the Dips & Salsa category?
/*Assumptions:
The CATEGORY_1 column in the products table contains category-level information.
We'll define the leading brand based on total sales in this category.*/

SELECT p.BRAND, SUM(t.FINAL_SALE) AS total_sales
FROM transactions t
JOIN products p ON t.BARCODE = p.BARCODE
WHERE p.CATEGORY_1 = 'Dips & Salsa'
GROUP BY p.BRAND
ORDER BY total_sales DESC
LIMIT 1;
--This retrieves the brand with the highest total sales in the "Dips & Salsa" category, making it the leading brand.



--3. At what percent has Fetch grown year over year?
/*Assumptions:
Growth is measured based on total sales (FINAL_SALE) year over year.
We'll compare total sales from the previous year (YEAR(NOW()) - 1) to two years ago (YEAR(NOW()) - 2).*/

WITH SalesByYear AS (
    SELECT 
        EXTRACT(YEAR FROM TRANSACTION_DATE) AS year,
        SUM(FINAL_SALE) AS total_sales
    FROM transactions
    GROUP BY EXTRACT(YEAR FROM TRANSACTION_DATE)
)
SELECT 
    s1.year AS current_year,
    s2.year AS previous_year,
    ((s1.total_sales - s2.total_sales) / s2.total_sales) * 100 AS growth_percentage
FROM SalesByYear s1
JOIN SalesByYear s2 ON s1.year = s2.year + 1
ORDER BY s1.year DESC
LIMIT 1;
--This calculates the year-over-year growth percentage in sales for Fetch.