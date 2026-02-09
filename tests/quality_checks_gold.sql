
/*
====================================================================================================
Quality Checks
====================================================================================================
Script Purpose:
     This script performs various quality checksto validate the integiry, consistency and accuracy 
     of the 'Gold' schema. 
     These checks ensures:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage notes:
    - Run these checks after data loading in the silver layer.
    - Investigate and resolve any discrepancies found during the checks.
======================================================================================================
*/

-- ====================================================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================================================
-- Check for uniqueness of customer key in gold.dim_customers
-- Expectation - No results

SELECT
  customer_key
  COUNT(*) as duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ======================================================================================================
-- Checking 'gold.dim_products'
-- ======================================================================================================
-- Check for uniqueness of product key in gold.dim_products
-- Expectation - No results
SELECT
  product_key
  COUNT(*) as duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ======================================================================================================
-- Checking 'gold.fact_sales'
-- ======================================================================================================
-- Check the data model connectivity between fact and dimensions
SELECT *  
FROM gold.fact_sales gfs
LEFT JOIN gold.dim_customers gdc
ON gdc.customer_key = gfs.customer_key
LEFT JOIN gold.dim_products gdp 
ON gdp.product_key = gfs.product_key
WHERE gdc.customer_key IS NULL OR gdp.product_key IS NULL;
