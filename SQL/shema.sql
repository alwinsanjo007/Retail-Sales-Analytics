CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(30) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT
);

CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(30),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),

    customer_id VARCHAR(20),

    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(50),

    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(5,2),
    profit NUMERIC(10,2),

    product_id VARCHAR(30),

    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id),

    FOREIGN KEY (product_id)
    REFERENCES products(product_id)
);

SELECT * FROM customers;

SELECT * FROM products;

SELECT * FROM orders;

CREATE TABLE superstore (
    row_id INT,
    order_id VARCHAR(30),
    order_date VARCHAR(30),
    ship_date VARCHAR(30),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(30),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(30),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(5,2),
    profit NUMERIC(10,2)
);

SELECT * FROM superstore LIMIT 10;

-- Check Missing Values

SELECT *
FROM superstore
WHERE customer_id IS NULL OR customer_name IS NULL;

SELECT *
FROM superstore
WHERE product_id IS NULL OR product_name IS NULL;

SELECT *
FROM superstore
WHERE sales IS NULL OR quantity IS NULL;

-- Check Duplicate Rows

SELECT row_id, COUNT(*)
FROM superstore
GROUP BY row_id HAVING COUNT(*) > 1;

-- Understand Date Format

SELECT order_date, ship_date FROM superstore LIMIT 10;

-- Load Customers Table

INSERT INTO customers (
    customer_id,
    customer_name,
    segment
)

SELECT DISTINCT
    customer_id,
    customer_name,
    segment
FROM superstore;

select * from customers limit 10;

SELECT COUNT(*) FROM customers;

-- Load Products Table

INSERT INTO products (
    product_id,
    category,
    sub_category,
    product_name
)

SELECT DISTINCT ON (product_id)
    product_id,
    category,
    sub_category,
    product_name
FROM superstore;

SELECT * FROM products LIMIT 10;

SELECT COUNT(*) FROM products;

-- Load Orders Table

INSERT INTO orders (
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    country,
    city,
    state,
    region,
    sales,
    quantity,
    discount,
    profit,
    product_id
)

SELECT
    row_id,
    order_id,

    TO_DATE(order_date, 'MM/DD/YYYY'),
    TO_DATE(ship_date, 'MM/DD/YYYY'),
	
    ship_mode,
    customer_id,
    country,
    city,
    state,
    region,
    sales,
    quantity,
    discount,
    profit,
    product_id

FROM superstore;

SELECT * FROM orders LIMIT 10;

SELECT COUNT(*) FROM superstore;

SELECT COUNT(*) FROM orders;

-- Verify Foreign Key Integrity

SELECT *
FROM orders o
LEFT JOIN customers c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check invalid products

SELECT *
FROM orders o
LEFT JOIN products p
ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Basic Data Exploration

SELECT
SUM(sales)
AS total_sales
FROM orders;

SELECT
SUM(profit)
AS total_profit
FROM orders;

SELECT COUNT(*)
FROM customers;

SELECT COUNT(*)
FROM products;

SELECT
MIN(order_date),s
MAX(order_date)
FROM orders;
