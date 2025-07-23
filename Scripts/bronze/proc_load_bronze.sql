/*
=======================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=======================================================================
Script Purpose:
   This stored procedure loads data into the 'bronze' schema from external CSV files
   It performs the following actions:
  - Truncates the bronze tables befpre loading the data.
  - Uses the BULK INSERT command to load data from scv files to bronze tables.

Parameters:
None
This stores procedure does not accept any parameters or return any value.

Using Examples:
EXEC Bronze.load_Bronze
==========================================================================
*/

CREATE OR ALTER PROCEDURE Bronze.load_Bronze AS
BEGIN
   DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
   BEGIN TRY
         SET @batch_start_time = GETDATE();
		 PRINT '=====================================================';
		 PRINT 'Loading Bronze Layer';
		 PRINT '=====================================================';

		 PRINT '------------------------------------------------------';
		 PRINT 'Loading CRM Tables';
		 PRINT '------------------------------------------------------';

		 SET @start_time = GETDATE();
		 PRINT '>> Truncating Table: Bronze.crm_cust_info';
		TRUNCATE TABLE Bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
		FROM 'C:\Users\My Pc\OneDrive\Desktop\SQL Course\cust_info.csv'
		WITH (
			 FIRSTROW = 2,
			 FIELDTERMINATOR = ',',
			 TABLOCK
		);
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';

		 SET @start_time = GETDATE();
		 PRINT '>> Truncating Table: Bronze.crm_prd_info';
		TRUNCATE TABLE Bronze.crm_prd_info;

		PRINT '>> Inserting Data Into: Bronze.crm_prd_info';
		BULK INSERT Bronze.crm_prd_info
		FROM 'C:\Users\My Pc\OneDrive\Desktop\SQL Course\prd_info.csv'
		WITH (
			 FIRSTROW = 2,
			 FIELDTERMINATOR = ',',
			 TABLOCK
		);
         SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		 SET @start_time = GETDATE();
		 PRINT '>> Truncating Table: Bronze.crm_sales_details';
		TRUNCATE TABLE Bronze.crm_sales_details;

		PRINT '>> Inserting Data Into: Bronze.crm_sales_details';
		BULK INSERT Bronze.crm_sales_details
		FROM 'C:\Users\My Pc\OneDrive\Desktop\SQL Course\sales_details.csv'
		WITH (
			 FIRSTROW = 2,
			 FIELDTERMINATOR = ',',
			 TABLOCK
		);
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';

		
		PRINT '-------------------------------------------------------';
		 PRINT 'Loading ERP Tables';
		 PRINT '------------------------------------------------------';

		 SET @start_time = GETDATE();
		  PRINT '>> Truncating Table: Bronze.erp_CUST_AZ12';
		TRUNCATE TABLE Bronze.erp_CUST_AZ12;

		PRINT '>> Inserting Data Into: Bronze.erp_CUST_AZ12';
		BULK INSERT Bronze.erp_CUST_AZ12
		FROM 'C:\Users\My Pc\OneDrive\Desktop\SQL Course\CUST_AZ12.csv'
		WITH (
			 FIRSTROW = 2,
			 FIELDTERMINATOR = ',',
			 TABLOCK
		);
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		SET @start_time = GETDATE();
		 PRINT '>> Truncating Table: Bronze.erp_LOC_A101';
		TRUNCATE TABLE Bronze.erp_LOC_A101;

		PRINT '>> Inserting Data Into: Bronze.erp_LOC_A101';
		BULK INSERT Bronze.erp_LOC_A101
		FROM 'C:\Users\My Pc\OneDrive\Desktop\SQL Course\LOC_A101.csv'
		WITH (
			 FIRSTROW = 2,
			 FIELDTERMINATOR = ',',
			 TABLOCK
		);
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';


		SET @start_time = GETDATE();
		 PRINT '>> Truncating Table: Bronze.erp_PX_CAT_G1V2';
		TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;

		PRINT '>> Inserting Data Into: Bronze.erp_PX_CAT_G1V2';
		BULK INSERT Bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\My Pc\OneDrive\Desktop\SQL Course\PX_CAT_G1V2.csv'
		WITH (
			 FIRSTROW = 2,
			 FIELDTERMINATOR = ',',
			 TABLOCK
		);
		 SET @end_time = GETDATE();
		 PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) +' seconds';
		 PRINT '---------------';

		 SET @batch_end_time = GETDATE();
		 PRINT '=========================================='
		 PRINT 'Loading Bronze layer is Completed';
		 PRINT '   -Total Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time)AS NVARCHAR) + 'seconds';
		  PRINT '==========================================='
	END TRY
	BEGIN CATCH
	PRINT '==================================================';
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
	PRINT 'Error Message' + ERROR_MESSAGE();
	PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
	PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR)
	PRINT '=====================================================';
	END CATCH
END
