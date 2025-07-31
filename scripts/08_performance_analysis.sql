-- ===============================
-- Section 8: Performance Analysis
-- ===============================

----------------------------------------------------------------------------------
/* Task: Analyze the yearly performance of products by comparing each product's 
sales to both its average sales performance and the previous year's sales */
----------------------------------------------------------------------------------

WITH yearly_product_sales AS (

SELECT
product_name,
YEAR(s.order_date) AS order_year,
SUM(sales_amount) AS current_sales,
COUNT(YEAR(s.order_date)) OVER (PARTITION BY product_name) AS total_years_sold
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(s.order_date), product_name 
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS current_vs_avg_sales,
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'ABOVE Average'
	 WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'BELOW Average'
	 ELSE 'Average'
END c_vs_avg_performance,
-- Year-over-year analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_year_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS current_vs_prev_sales,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
	 ELSE 'No Change'
END c_vs_p_performance
FROM yearly_product_sales
-- WHERE total_years_sold > 1	**excludes the products with data stored from only 1 year**
ORDER BY product_name, order_year
