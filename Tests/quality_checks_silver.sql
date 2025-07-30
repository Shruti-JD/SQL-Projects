/*
======================================================================================
Quality Checks
======================================================================================
Script Purpose :
This script performs various various quality checks for data consistency, accuracy,
and standardization acreoss 'Silver' schema. It includes checks for:
- Null & duplicate primary keys.
- Unwanted spaces in the strings field.
- Data standardization & consistency.
- Invalid data ranges and orders.
- Data consistency between related fields.

Usage Notes :
      - Run these checks after data loading in the Silver layer.
      - Investigate & resolve any discepancies found during the checks.
===========================================================================================
*/


-- ===================================================================
-- Checking for 'Silver.crm_cust_info'
-- ===================================================================
-- Check for Nulls or Duplicates in the primary key
-- Expectation: No Results
Select
cst_id,
COUNT(*)
From Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Removing Duplicates or Nulls 
Select
*
From 
(Select
*,
ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_Last
From Bronze.crm_cust_info
Where cst_id IS NOT NULL)t
Where Flag_Last = 1 

-- Check for unwanted spaces in string values
-- Expectation: No Results
Select
cst_firstname
From Bronze.crm_cust_info
Where cst_firstname != TRIM(cst_firstname)

Select
cst_lasttname
From Bronze.crm_cust_info
Where cst_lasttname != TRIM(cst_lasttname)

-- Removing unwanted spaces 
Select
cst_id,
cst_key,
TRIM(cst_firstname),
TRIM(cst_lasttname),
cst_marital_status,
cst_gndr,
cst_create_date
From (
Select 
*,
ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_Last
From Bronze.crm_cust_info
Where cst_id IS NOT NULL)t
Where Flag_Last = 1 

--Data Standardization & Consistency (we will change all abbreviations to full forms)
Select
cst_id,
cst_key,
TRIM(cst_firstname),
TRIM(cst_lasttname),
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
     WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	 ELSE 'N/A'
END 
cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'N/A'
END 
cst_gndr,
cst_create_date
From (
Select 
*,
ROW_NUMBER()OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_Last
From Bronze.crm_cust_info
Where cst_id IS NOT NULL)t
Where Flag_Last = 1 

-- ===================================================================
-- Checking for 'Silver.crm_prd_info'
-- ===================================================================
-- Check for Nulls or Duplicates in the primary key
-- Expectation: No Results
Select
prd_id,
COUNT(*)
From Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces in string values
-- Expectation: No Results
Select
prd_nm
From Bronze.crm_prd_info
Where prd_nm != TRIM(prd_nm)

--Check for NULLs or Negative numbers
-- Expectation: No Results
Select
prd_cost
From Bronze.crm_prd_info
Where prd_cost < 0 OR prd_cost IS NULL

--Data Standardization & Consistency (we will replace abbreviations with full forms)
Select
Distinct prd_line
From Bronze.crm_prd_info

--Check for invalid date orders
Select 
*
From Bronze.crm_prd_info
Where prd_end_dt < prd_start_dt

--To make changes in end_dt & start_dt in such a way that prd_end_dt > prd_start_dt, we use LEAD()
Select
prd_id,
prd_key,
prd_nm,
prd_line,
prd_start_dt,
prd_end_dt,
LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt_test
From Bronze.crm_prd_info

-- ===================================================================
-- Checking for 'Silver.crm_sales_details'
-- ===================================================================
---Check for invalid dates as -ve numbersor zero's can't be cast as date
Select
NULLIF(sls_order_dt,0) AS sls_order_dt
From bronze.crm_sales_details
where sls_order_dt <= 0 OR LEN(sls_order_dt) != 8  --In this scenario the length of the date must be 8

--Check for invalid order dates as order date should come before the due date & shipping date.
Select
*
From bronze.crm_sales_details
where sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check data consistency b/w sales, Qty & Price
-- Sales =  Qty * Price
-- Values must not be NULL, 0 or -ve.
Select DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
	   ELSE sls_sales 
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
     THEN sls_sales / NULLIF(sls_quantity,0)
	   ELSE sls_price
END AS sls_price
From bronze.crm_sales_details
Where sls_sales != sls_price * sls_quantity
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- Changing the data type of order_dt, Ship_dt & Due_dt from INT to DATE

IF OBJECT_ID ('Silver.crm_sales_details' , 'U') IS NOT NULL
     DROP TABLE Silver.crm_sales_details;
CREATE TABLE Silver.crm_sales_details
(
	sls_ord_num       NVARCHAR(50),
	sls_prd_key       NVARCHAR(50),
	sls_cust_id       INT,
	sls_order_dt      DATE,
	sls_ship_dt       DATE,
	sls_due_dt        DATE,
	sls_sales         INT,
	sls_quantity      INT,
	sls_price         INT,
	dwh_create_date   DATETIME2 DEFAULT GETDATE()
)

-- ===================================================================
-- Checking for 'Silver.erp_CUST_AZ12'
-- ===================================================================
-- Identify Out-of-Range dates
-- Expectations : Birthdates between 1924-01-01 and Today
  Select Distinct
       bdate
  From  Silver.erp_CUST_AZ12
  Where bdate < '1924-01-01'
    OR  bdate > GETDATE();

-- Data Standardization and Consistency
   Select Distinct
        gen
   From Silver.erp_CUST_AZ12

-- ===================================================================
-- Checking for 'Silver.erp_LOC_A101'
-- ===================================================================
--  Data Standardization and Consistency
Select Distinct
      cntry
From Silver.erp_LOC_A101
Order By cntry 

-- ===================================================================
-- Checking for 'Silver.erp_PX_CAT_G1V2'
-- ===================================================================
-- Check for unwanted spaces 
-- Expectations : No results
Select
cat
From Silver.erp_PX_CAT_G1V2
Where cat != TRIM(cat);
