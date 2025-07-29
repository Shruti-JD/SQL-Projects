/*
===========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===========================================================================
Script Purpose :
This stored procedure performs the ETL (Extract, Transform , Load) process to
populate the 'Silver' schema tables from the 'Bronze' schema.
Actions Performed :
- Truncate Silver Tables
- Inserts transformed & cleansed data from the Bronze into Silver tables.

Parameters :
None
This stored procedure does not accept any parameters or returns any values.

Usage Example : 
EXEC Silver.Load_Silver;
=============================================================================
*/


CREATE OR ALTER PROCEDURE Silver.Load_Silver AS
BEGIN  
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
   BEGIN TRY
         SET @batch_start_time = GETDATE();
		 PRINT '=====================================================';
		 PRINT 'Loading Silver Layer';
		 PRINT '=====================================================';

		 PRINT '------------------------------------------------------';
		 PRINT 'Loading CRM Tables';
		 PRINT '------------------------------------------------------';

         --Loading silver.crm_cust_info
		 SET @start_time = GETDATE();
	PRINT '>> Truncating Table : Silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>> Inserting Data into : Silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lasttname,
		cst_gndr,
		cst_marital_status,
		cst_create_date)
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
	Where Flag_Last = 1;
	SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		 --Loading silver.crm_prd_info
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table : Silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> Inserting Data into : Silver.crm_prd_info';
	INSERT INTO Silver.crm_prd_info(
		prd_id,  
		category_id,
		prd_key,          
		prd_nm,          
		prd_cost,        
		prd_line,         
		prd_start_dt,     
		prd_end_dt     
	)
	Select
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5), '-','_')AS Category_id,
	SUBSTRING(prd_key,7,LEN(prd_key))AS prd_key,
	prd_nm,
	ISNULL(prd_cost,0)AS prd_cost,
	CASE UPPER(TRIM(prd_line)) 
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN  'S' THEN 'Other Sales'
		WHEN  'T' THEN 'Touring'
		ELSE 'N/A'
	END
	prd_line,
	CAST(prd_start_dt AS DATE)prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
	From Bronze.crm_prd_info;
	SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';

		 --Loading silver.crm_sales_details
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table : Silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT '>> Inserting Data into : Silver.crm_sales_details';
	INSERT INTO Silver.crm_sales_details (
		sls_ord_num,       
		sls_prd_key,       
		sls_cust_id,     
		sls_order_dt,      
		sls_ship_dt,      
		sls_due_dt,      
		sls_sales,         
		sls_quantity,     
		sls_price       
	)
	Select
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END sls_order_dt,
	CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END sls_ship_dt,
	CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
		 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales 
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0 
		 THEN sls_sales / NULLIF(sls_quantity,0)
		 ELSE sls_price
	END AS sls_price
	From Bronze.crm_sales_details;
	SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		 PRINT '-------------------------------------------------------';
		 PRINT 'Loading ERP Tables';
		 PRINT '------------------------------------------------------';

		 --Loading Silver.erp_CUST_AZ12
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table : Silver.erp_CUST_AZ12';
	TRUNCATE TABLE silver.erp_CUST_AZ12;
	PRINT '>> Inserting Data into : Silver.erp_CUST_AZ12';
	INSERT INTO Silver.erp_CUST_AZ12 (cid,bdate,gen)
	Select 
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) --Remove 'NAS' prefix if present
		 ELSE cid
	END cid,
	CASE WHEN bdate > GETDATE() THEN NULL   --Set future bdate to NULL
		 ELSE bdate
	END bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F' , 'FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M' , 'MALE') THEN 'Male'
	ELSE 'N/A'
	END gen  -- Normalize gender values & handle unknown cases
	From bronze.erp_CUST_AZ12;
	SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		  --Loading Silver.erp_LOC_A101
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table : Silver.erp_LOC_A101';
	TRUNCATE TABLE silver.erp_LOC_A101;
	PRINT '>> Inserting Data into : Silver.erp_LOC_A101';
	INSERT INTO Silver.erp_LOC_A101 (cid,cntry)
	Select
	REPLACE (cid, '-', '')cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
		 ELSE TRIM(cntry)
	END cntry  -- Normalize and handle missing or blank country codes
	From Bronze.erp_LOC_A101;
	SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		  --Loading Silver.erp_PX_CAT_G1V2
	SET @start_time = GETDATE();
	PRINT '>> Truncating Table : Silver.erp_PX_CAT_G1V2';
	TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
	PRINT '>> Inserting Data into : Silver.erp_PX_CAT_G1V2';
	INSERT INTO Silver.erp_PX_CAT_G1V2 (
	id,
	cat,
	subcat,
	maintenance
	)
	Select
	id,
	cat,
	subcat,
	maintenance
	From Bronze.erp_PX_CAT_G1V2;
	SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';

		 SET @batch_end_time = GETDATE();
		 PRINT '=========================================='
		 PRINT 'Loading Silver layer is Completed';
		 PRINT '   -Total Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)AS NVARCHAR) + 'seconds';
		  PRINT '==========================================='

	END TRY
	BEGIN CATCH
	PRINT '==================================================';
	PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
	PRINT 'Error Message' + ERROR_MESSAGE();
	PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR)
	PRINT '=====================================================';
	END CATCH
END
