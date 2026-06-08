-- Business KPIs

SELECT
ROUND(SUM(sales),2)
AS total_revenue
FROM orders;

SELECT
ROUND(SUM(profit),2)
AS total_profit
FROM orders;

SELECT
COUNT(DISTINCT order_id)
AS total_orders
FROM orders;

SELECT
ROUND(SUM(sales) / COUNT(DISTINCT order_id),2) AS avg_order_value
FROM orders;

SELECT
COUNT(DISTINCT customer_id) AS total_customers
FROM orders;

SELECT
SUM(quantity) AS products_sold
FROM orders;

---- Sales Trend Analysis

SELECT
DATE_TRUNC('month', order_date) AS month,
SUM(sales) AS revenue
FROM orders
GROUP BY month 
ORDER BY month;

-- Monthly Profit Trend

SELECT
EXTRACT(YEAR FROM order_date) AS year,
EXTRACT(MONTH FROM order_date) AS month,
ROUND(SUM(profit),2) AS profit FROM orders
GROUP BY year, month
ORDER BY year, month;

-- Year-wise Sales

SELECT
EXTRACT(YEAR FROM order_date) AS year,
ROUND(SUM(sales),2) AS revenue FROM orders
GROUP BY year
ORDER BY year;

-- Quarter-wise Revenue

SELECT
EXTRACT(QUARTER FROM order_date) AS quarter,
ROUND(SUM(sales),2) AS revenue FROM orders
GROUP BY quarter
ORDER BY quarter;

---- Product Analytics

-- Top 10 Products by Revenue

SELECT
p.product_name, SUM(o.sales) AS revenue
FROM orders o JOIN products p
ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- Top 10 Products by Profit

SELECT
p.product_name, SUM(o.profit) AS profit
FROM orders o JOIN products p ON o.product_id =p.product_id
GROUP BY p.product_name
ORDER BY profit DESC
LIMIT 10;

-- Worst Products (Loss Making)

SELECT
p.product_name, ROUND(SUM(o.profit),2) AS loss
FROM orders o
JOIN products p ON o.product_id =p.product_id
GROUP BY p.product_name
ORDER BY loss
LIMIT 10;

-- Category Performance

SELECT
p.category, SUM(o.sales) AS revenue, SUM(o.profit) AS profit
FROM orders o
JOIN products p ON o.product_id =p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Sub-category Performance

SELECT
p.sub_category, SUM(o.sales) revenue, SUM(o.profit) profit
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY revenue DESC;

---- Customer Analytics

-- Top 10 Customers

SELECT
c.customer_name, SUM(o.sales) spending
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY spending DESC
LIMIT 10;

-- Customer Segments

SELECT
segment, COUNT(*) customers
FROM customers
GROUP BY segment;

-- Highest Profit Customers

SELECT
c.customer_name, SUM(o.profit) AS profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY profit DESC
LIMIT 10;

---- Region Analytics

-- Region-wise Sales

SELECT
region, SUM(sales) total_sales
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- State-wise Sales

SELECT
state, ROUND(SUM(sales),2) revenue
FROM orders
GROUP BY state
ORDER BY revenue DESC
LIMIT 10;

-- City-wise Profit

SELECT
city, ROUND(SUM(profit),2) profit
FROM orders
GROUP BY city
ORDER BY profit DESC
LIMIT 10;

---- Discount Analysis

-- Discount Impact

SELECT
CASE
WHEN discount = 0
THEN 'No Discount'
WHEN discount < 0.20
THEN 'Low Discount'
ELSE 'High Discount'
END AS discount_level, SUM(sales) revenue, round(AVG(profit),2) avg_profit
FROM orders
GROUP BY discount_level;

-- Highest Discount Products

SELECT
p.product_name, MAX(discount) AS max_discount
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY max_discount DESC
LIMIT 10;

-- Rank Regions by Revenue

SELECT
    region,SUM(sales) AS revenue,
    RANK() OVER(ORDER BY SUM(sales) DESC) AS revenue_rank
FROM orders
GROUP BY region;

-- Dense Ranking

SELECT
    region,
    SUM(sales) revenue,
	DENSE_RANK() OVER(ORDER BY SUM(sales) DESC) dense_rank
FROM orders
GROUP BY region;

-- Top Product in Each Category

WITH product_sales AS
(
    SELECT
        p.category, p.product_name, SUM(o.sales) revenue,
        ROW_NUMBER() OVER(PARTITION BY p.category ORDER BY SUM(o.sales) DESC) rn
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT * FROM product_sales WHERE rn = 1;

-- Running Revenue (Cumulative Sales)

SELECT
order_date, SUM(sales) OVER(ORDER BY order_date) AS cumulative_sales
FROM orders
ORDER BY order_date;

-- Monthly Running Revenue

WITH monthly_sales AS
(
SELECT
    DATE_TRUNC('month',order_date) as month, SUM(sales) revenue
FROM orders
GROUP BY month
)

SELECT
    month, revenue,
    SUM(revenue) OVER(ORDER BY month) cumulative_revenue
FROM monthly_sales;

-- Top 5 Customers Per Region

WITH customer_sales AS
(
SELECT
    region, customer_id, SUM(sales) revenue, 
	ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(sales) DESC) rn
FROM orders
GROUP BY region, customer_id
)

SELECT * FROM customer_sales WHERE rn <= 5;

-- Customer Purchase Frequency

SELECT
    customer_id, COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;

-- Most Profitable Products in Each Category

WITH profit_rank AS
(
SELECT
    p.category, p.product_name, SUM(o.profit) profit,
    RANK() OVER(PARTITION BY p.category ORDER BY SUM(o.profit) DESC) rk
FROM orders o
JOIN products p ON o.product_id=p.product_id
GROUP BY p.category, p.product_name
)
SELECT * FROM profit_rank WHERE rk=1;

-- Revenue Contribution %

SELECT
    region,
    ROUND(SUM(sales),2) revenue,
    ROUND(SUM(sales)*100.0 / SUM(SUM(sales))OVER(),2) AS revenue_percentage
FROM orders
GROUP BY region;
