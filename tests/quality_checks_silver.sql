/*
====================================================================================================
Quality Checks
====================================================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy 
    and standardization across the 'Silver' schema. It includes checks for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields
    - Data Standardization and Consistency
    - Invalid date ranges and orders
    - Data consistency between related fields
Usage notes:
    - Run these checks after data loading in the silver layer.
    - Investigate and resolve any discrepancies found during the checks.
====================================================================================================
*/

====================================================================================================
-- Checkng 'silver.crm_cust_info'
====================================================================================================
 -- Check for Nulls and Duplicates in Primary Key (Aggregate the primary key to find unique values)
 -- Expectation - No results

SELECT cst_id, COUNT(*)
FROM 
silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Query for Data Transformation and Data Cleansing

-- 1. FINDING DUPLICATES

-- version 1 - interested in rank 1 only
SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM 
bronze.crm_cust_info
WHERE cst_id = 29466;

-- version 2 - returns redundant data
SELECT * FROM
(SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM 
bronze.crm_cust_info) t 
WHERE flag_last != 1

-- version 3 - Transformation
SELECT * FROM
(SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM 
bronze.crm_cust_info 
WHERE cst_id IS NOT NULL) t 
WHERE flag_last = 1


-- 2.Check for unwanted spaces in String values
-- Expectation - No results

SELECT cst_firstname 
FROM silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM silver.crm_cust_info
where cst_gndr != TRIM(cst_gndr);

SELECT cst_key
FROM silver.crm_cust_info
where cst_key != TRIM(cst_key);

-- version 2 - transformation

SELECT cst_id, cst_key, TRIM(cst_firstname) cst_firstname, TRIM(cst_lastname) cst_lastname, cst_gndr, cst_create_date
FROM bronze.crm_cust_info
where cst_lastname != TRIM(cst_lastname);

-- 3. CHECK THE CONSISTENCY OF VALUES IN LOW CARDINALITY COLUMNS
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

/* 
	- In our data warehouse, we aim to store clear and meaningful values  rather
	  than using abbreviated terms
	- In our data warehouse, we use the default value 'n/a' for missing values!
*/

SELECT 
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 ELSE 'n/a'
	END cst_marital_status, 
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
		 ELSE 'n/a'
	END cst_gndr,
FROM 
	(SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM 
		bronze.crm_cust_info 
		WHERE cst_id IS NOT NULL
	)t WHERE flag_last = 1



====================================================================================================
-- Checkng 'silver.crm_prd_info'
====================================================================================================
-- 1. check for nulls and duplicates in Primary Keys 
-- Expectations - No  result

SELECT prd_id, count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING count(*) > 1 or prd_id IS NULL;

SELECT prd_key 
FROM bronze.crm_prd_info; 

/* First 5 chars are the category ID 
   Derive two columns from prd_key
*/

SELECT 
	prd_id, prd_key, 
	SUBSTRING(prd_key, 1, 5) cat_id,
	prd_nm, prd_cost, prd_line,
	prd_start_dt, prd_end_dt
FROM silver.crm_prd_info

-- erp_px_cat_g1v2 have column cat_id, but it like CO_RF and prd_key have CO-RF. Hence, replace '-' with '_' so that we can join these tables

-- ver 1
SELECT 
	prd_id, prd_key, 
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') cat_id
FROM silver.crm_prd_info
-- check 
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN 
(SELECT DISTINCT id FROM silver.erp_px_cat_g1v2);

-- ver 2
SELECT 
	prd_id, prd_key, 
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') cat_id, 
	SUBSTRING(prd_key, 7, len(prd_key)) as prd_key
FROM silver.crm_prd_info
-- check

-- 2. Remove Unwanted spaces
-- Expectation: No results

SELECT prd_nm
FROM silver.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm                  -- safe

-- 3. Check for Nulls or negative numbers
-- Expectation: No results

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;

-- 4. Data Standardization & Normalization
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

SELECT
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 Else 'n/a'
	END AS prd_line
FROM bronze.crm_prd_info

-- 5. Check for invalid date orders
--		(end_date must not be earlier than the start_date)

SELECT * 
	FROM bronze.crm_prd_info
	WHERE prd_end_dt < prd_start_dt;

/* 
	Inference - start_dt is always > end_dt here, that makes no sense 
Note - For compex SQL transformation, narrow it down to a specific example and brainstorm multiple solution approaches

For fixing this issue, we can use prd_end_dt = prd_start_dt -1 (so that the end date doesn't overlap the next start date)

LEAD() can serve the purpose - Access values from the next row within a window 
*/

SELECT * ,
	LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test 
FROM bronze.crm_prd_info;

====================================================================================================
-- Checkng 'silver.crm_sales_details'
====================================================================================================
-- 1. check for unwanted spaces
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);               --- safe

/*
	2. sales details table is related with cust_info and prd_info, so, worth to check if the 
	primary keys of these data have any issues
*/

SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);         --- safe


-- 3. change the data type of the sls_order_dt
-- Negative numbers or 0s can't be casted to date, so check for it

SELECT sls_order_dt
FROM silver.crm_sales_details
where sls_order_dt < 0          --- no negative dates

SELECT sls_order_dt
FROM silver.crm_sales_details
where sls_order_dt <= 0          --- lot of 0s

SELECT 
NULLIF(sls_order_dt, 0) sls_order_dt
FROM silver.crm_sales_details
where sls_order_dt > 20501230  OR sls_order_dt < 19000101          --- safe

-- Order date must always be earlier than the ship date and due date

SELECT * 
FROM
silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;   --- safe


/*
	Check Data Consistency : between Sales, Quanatity and Price
	-->> Sales = Quantity * Price 
	-->> Values must not be 0, negative or null
*/

SELECT DISTINCT
	sls_sales,
	sls_price,
	sls_quantity
FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL
OR sls_sales <= 0 OR sls_price <= 0 OR sls_quantity <= 0
ORDER BY sls_sales, sls_price, sls_quantity;

====================================================================================================
-- Checkng 'silver.erp_cust_az12'
====================================================================================================
/*
1. checking for primary key - cid 

	From the Integration Model on draw.io, we see that primary key of this table (cid) is 
	linked to cust_key of crm_cust_info table 

	Comparing both columns, we can infer that cid col have extra char 'NAS'
*/

SELECT 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid
	END AS cid,
	bdate,
	gen
FROM silver.erp_cust_az12
WHERE 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		 ELSE cid
	END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info )       --- safe

  
-- 2. Identify  Out_Of_Range dates
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- 3. Data Standardization and Consistency - Check Gender column
SELECT DISTINCT gen
FROM silver.erp_cust_az12;   -- have Null,F, abbreviations and empty string


====================================================================================================
-- Checkng 'silver.erp_los_a101'
====================================================================================================
-- 	1. check for the primary key (cid) to which  it is related to in other table
  SELECT 
	REPLACE(cid, '-', '') cid, 
	cntry
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (select cst_key from silver.crm_cust_info) ;       -- safe

-- 2. Data Standardization & Consistency 
SELECT 
	DISTINCT cntry
FROM silver.erp_loc_a101


====================================================================================================
-- Checkng 'silver.erp_px_cat_g1v2'
====================================================================================================
-- 1. Check for primary keys
-- 	col 'id' in this table is linked with the prd_key in crm_prd_info table, so compare 
-- We alraedy have created cat_id in crm_prd_info that matches the col 'id', so nothing to change

--- 2. check unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)    --- safe

-- 3. Data Standardization & Consistency 
SELECT 
	DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2

SELECT 
	DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT 
	DISTINCT subcat
FROM bronze.erp_px_cat_g1v2                -- safe


