
-- ==========================================
-- Section 9: Part to Whole Analysis
-- ==========================================


-----------------------------------------------------------------
-- Task: Which categories contribute the most to overall sales
-----------------------------------------------------------------

WITH category_sales AS (
SELECT
p.category,
SUM(s.sales_amount) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY category )

SELECT
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ())*100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC
-- The over-concentration of sales in one category (Bikes) adds risk to the company and the solution should
-- be to find ways to drive sales up for the other categories

