
-- ===============================
-- Section 7: Cumulative Analysis
-- ===============================

---------------------------------------------------------------------------------
-- Task: Calculate the total sales per month and the running sales over time
---------------------------------------------------------------------------------

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (PARTITION BY YEAR(order_date) ORDER BY order_date) AS running_total_sales,
avg_sold_item_price,
AVG(avg_sold_item_price) OVER (ORDER BY order_date) AS moving_average_price
--window function
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_sold_item_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t

