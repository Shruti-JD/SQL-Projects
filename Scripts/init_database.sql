/* 
======================================================================
Create Database & Schemas
======================================================================
Script Purpose:
This script creates a new database name 'DataWarehouse' after checking if it already exists.
If the duplicate exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'Bronze', 'Silver', 'Gold'.

WARNING:
Running this script will drop the entire 'DataWarehouse' database  if it exists.
All data in the database will be permanently deleted. Proceed with caution & ensure you have proper backups before running this script.
*/


USE master;
GO

--Drop & recreate 'DataWarehouse' database 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP Database 'DataWarehouse';
END;
GO

--Create Database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA Bronze;
GO
CREATE SCHEMA Silver;
GO
CREATE SCHEMA Gold;
GO
