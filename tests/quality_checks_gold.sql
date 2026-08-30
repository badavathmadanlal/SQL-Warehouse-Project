/*
Quality Checks - Gold Layer

Purpose:
    Validate the integrity and relationships of the Gold layer.

Checks include:
    - Uniqueness of surrogate keys
    - Referential integrity between fact and dimension views
    - Connectivity between fact and dimension tables

Run these checks after creating the Gold layer views.
*/

USE DataWarehouse;
GO

-- Check gold.dim_customers

-- Check for duplicate customer keys
-- Expectation: No results
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Check gold.dim_products

-- Check for duplicate product keys
-- Expectation: No results
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Check gold.fact_sales

-- Check connectivity between fact and dimension views
-- Expectation: No results
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
