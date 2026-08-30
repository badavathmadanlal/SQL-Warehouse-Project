/*
===============================================================================
Quality Checks - Bronze Layer
===============================================================================
Script Purpose:
    This script performs quality checks on the Bronze layer to identify
    NULL values, duplicate records, unwanted spaces, invalid values,
    inconsistent data, and invalid dates.

Usage:
    Run these checks after loading the Bronze layer.
    Investigate any records returned by the checks.
===============================================================================
*/

USE DataWarehouse;
GO

-- Checking bronze.crm_cust_info

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
SELECT DISTINCT
    cst_marital_status
FROM bronze.crm_cust_info;

SELECT DISTINCT
    cst_gndr
FROM bronze.crm_cust_info;


-- Checking bronze.crm_prd_info

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULL or Negative Numbers
-- Expectation: No Results
SELECT
    prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT
    prd_line
FROM bronze.crm_prd_info;

-- Check for Invalid Date Orders
-- Expectation: No Results
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- Checking bronze.crm_sales_details

-- Check for Invalid Order Dates
-- Expectation: No Results
SELECT
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
    OR LEN(sls_order_dt) != 8
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19000101;

-- Check for Invalid Shipping Dates
-- Expectation: No Results
SELECT
    sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
    OR LEN(sls_ship_dt) != 8
    OR sls_ship_dt > 20500101
    OR sls_ship_dt < 19000101;

-- Check for Invalid Due Dates
-- Expectation: No Results
SELECT
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt > 20500101
    OR sls_due_dt < 19000101;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0;


-- Checking bronze.erp_cust_az12

-- Check for Future Birthdates
-- Expectation: No Results
SELECT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT
    gen
FROM bronze.erp_cust_az12;


-- Checking bronze.erp_loc_a101

-- Data Standardization & Consistency
SELECT DISTINCT
    cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    cid,
    cntry
FROM bronze.erp_loc_a101
WHERE cid != TRIM(cid)
    OR cntry != TRIM(cntry);


-- Checking bronze.erp_px_cat_g1v2

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    *
FROM bronze.erp_px_cat_g1v2
WHERE id != TRIM(id)
    OR cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2;
