/*
========================================================================================
Quality Checks
========================================================================================
Script Purpose :
      This script performs quality checks to validate the integrity, consistency
      and accuracy of the Gold layer. These checks ensure:
        - Uniqueness of surrogate keys in dimension tables.
        - Referential integrity between fact and dimension tables.
        - validation of relationships in the data model for analytical purposes.

Usage Notes:
   - Run these checks after data loading from silver layer.
   - Investigate and resolve any discrepencies found during the checks.
========================================================================================
*/

--=====================================================================================
-- Checking 'Gold.dim_customers'
--=====================================================================================
-- Check for uniqueness of Customer Key in Gold.dim_customers
-- Expectation: No results
Select
    customer_key,
COUNT(*) AS duplicate_count
FROM Gold.dim_customers
GROUP BY  customer_key
HAVING COUNT(*) > 1;

--======================================================================================
-- Checking 'Gold.dim_products'
--======================================================================================
-- Check for uniqueness of Product Key in Gold.dim_products
-- Expectation: No results
Select
   product_key,
COUNT(*) AS duplicate_count
FROM Gold.dim_products
GROUP BY  product_key
HAVING COUNT(*) > 1;

--======================================================================================
-- Checking 'Gold.fact_sales'
--======================================================================================
-- Check the data model connectivity between fact and dimensions
Select *
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c
  ON c.customer_key = f.customer_key
LEFT JOIN Gold.dim_products p
  ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL

