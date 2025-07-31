/*
===================================================================================
DDL Script : Create Gold Views
===================================================================================
Script Purpose :
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents teh final dimension and fact tables (Star Schema)

Each view performs transformations and combines data from the Silver layer
to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytica and reporting.
===================================================================================
*/

--================================================================================
-- Create Dimension : Gold.dim_customers
--================================================================================
IF OBJECT ID ('Gold.dim_customers', 'V') IS NOT NULL 
     DROP VIEW Gold.dim_customers;
GO

CREATE VIEW Gold.dim_customers AS
Select
  ROW_NUMBER()OVER(ORDER BY cst_id)AS customer_key,
  ci. cst_id AS customer_id,
  ci.cst_key AS customer_number ,
  ci.cst_firstname AS first_name,
  ci.cst_lasttname AS last_name,
  la.cntry AS country,
  ci.cst_marital_status AS marital_status,
  CASE WHEN ci.cst_gndr != 'N/A'THEN ci.cst_gndr   ---CRM is the Master source for gndr info
       ELSE COALESCE(ca.gen, 'N/A')
  END AS gender,
  ca.bdate AS birthdate,
  ci.cst_create_date AS create_date
From silver.crm_cust_info ci
LEFT JOIN Silver.erp_CUST_AZ12 ca
  ON  ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 la
  ON  ci.cst_key = la.cid 
GO

--================================================================================
-- Create Dimension : Gold.dim_products
--================================================================================
IF OBJECT ID ('Gold.dim_products', 'V') IS NOT NULL 
     DROP VIEW Gold.dim_products;
GO

CREATE VIEW Gold.dim_products AS
Select
  ROW_NUMBER()OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
  pn.prd_id AS product_id,
  pn.prd_key AS product_number,
  pn.prd_nm AS product_name,
  pn.category_id,
  pc.cat AS category,
  pc.subcat AS subcategory,
  pc.maintenance,
  pn.prd_cost AS cost,
  pn.prd_line AS product_line,
  pn.prd_start_dt AS start_date
From Silver.crm_prd_info pn
LEFT JOIN Silver.erp_PX_CAT_G1V2 pc
    ON pn.category_id = pc.id
WHERE pn.prd_end_dt IS NULL  
GO

--================================================================================
-- Create Fact Table: Gold.fact_sales
--================================================================================
IF OBJECT ID ('Gold.fact_sales', 'V') IS NOT NULL 
     DROP VIEW Gold.fact_sales;
GO

CREATE VIEW Gold.fact_sales AS
Select
  sd.sls_ord_num AS order_number,
  pr.product_key,   
  cu.customer_key,
  sd.sls_order_dt AS order_date,
  sd.sls_ship_dt AS shipping_date,
  sd.sls_due_dt AS due_date,
  sd.sls_sales AS sales_amount,
  sd.sls_quantity AS quantity,
  sd.sls_price AS price
From Silver.crm_sales_details sd
LEFT JOIN Gold.dim_products pr
   ON sd.sls_prd_key = pr.product_number
LEFT JOIN Gold.dim_customers cu
   ON sd.sls_cust_id = cu.customer_id
GO
