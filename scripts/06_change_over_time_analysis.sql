-- ======================================
-- Section 6: Change Over Time Analysis
-- ======================================

----------------------------------------------
-- Task: Analyze Sales Performance Over Time
----------------------------------------------

-- yearly analysis
SELECT
YEAR(order_date) AS order_year,
COUNT(DISTINCT MONTH(order_date)) AS month_count,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)


	/* The issue we see with this data is that theres bias towards Dec and Jan 
	from the extra recorded December in 2010 and an extra January in 2014 */

-- Methods for monthly and yearly analysis together (DATETRUNC and FORMAT)
SELECT
DATETRUNC(month, order_date) AS order_date,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date) -- DATETRUNC is the best option with the only downside being the display of the date: 2010-12-01
ORDER BY DATETRUNC(month, order_date)
