/*
Quality Checks - Silver Layer

Purpose:
    Validate data quality, consistency, accuracy, and standardization
    across the Silver layer.

Checks include:
    - NULL and duplicate primary keys
    - Unwanted spaces
    - Data standardization
    - Invalid dates
    - Data consistency between related columns

Run these checks after loading the Silver layer.
*/

USE DataWarehouse;
GO

-- Check silver.crm_cust_info

-- Check for NULL or duplicate customer IDs
-- Expectation: No results
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for unwanted spaces
-- Expectation: No results
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Check marital status values
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;


-- Check silver.crm_prd_info

-- Check for NULL or duplicate product IDs
-- Expectation: No results
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces
-- Expectation: No results
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or negative product costs
-- Expectation: No results
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check product line values
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for invalid product date ranges
-- Expectation: No results
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- Check silver.crm_sales_details

-- Check for invalid dates
-- Expectation: No invalid dates
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check order date against shipping and due dates
-- Expectation: No results
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Check sales consistency
-- Sales should equal quantity multiplied by price
-- Expectation: No results
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- Check silver.erp_cust_az12

-- Check for out-of-range birth dates
-- Expectation: Birthdates between 1924-01-01 and today
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Check gender values
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- Check silver.erp_loc_a101

-- Check country values
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- Check silver.erp_px_cat_g1v2

-- Check for unwanted spaces
-- Expectation: No results
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Check maintenance values
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
