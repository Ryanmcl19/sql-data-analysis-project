/*
=============================================================================================
Product Report
=============================================================================================
Purpose:
	- This report consolidates key product metrics and behaviours

Highlights:
	1. Gathers essential fields such as product names, category, subcategory, and cost.
	2. Segments products to identify High-Performance, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total unique customers
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
=============================================================================================
*/
CREATE VIEW gold.report_products AS 
WITH base_query AS (
/*--------------------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------------------------*/
SELECT
	s.order_number,
	s.customer_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
WHERE order_date IS NOT NULL )

, product_aggregation AS (
/*--------------------------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
--------------------------------------------------------------------------------------------*/

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(Month, MIN(order_date), MAX(order_date)) AS lifespan_months,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)
/*--------------------------------------------------------------------------------------------
3) Calculate valuable KPIs
--------------------------------------------------------------------------------------------*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
	CASE 
		 WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales between 10000 and 50000 THEN 'Mid-Range'
		 ELSE 'Low-Performer'
	END AS product_segment,
	lifespan_months,
	total_sales,
	total_orders,
	total_quantity,
	total_customers,
	avg_selling_price,
	--Compute average order revenue (AOR)
	CASE 
		 WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS avg_order_revenue,
	--Compute average monthly revenue
	CASE 
		 WHEN lifespan_months = 0 THEN total_sales
		 ELSE total_sales / lifespan_months
	END AS average_monthly_revenue
FROM product_aggregation

 