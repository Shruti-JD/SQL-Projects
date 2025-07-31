**DATA WAREHOUSE AND ANALYTICS PROJECT**

Welcome to **Data Warehouse and Analytics Project** repository!🚀

This projects demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse
to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in 
data engineering and analytics.

---------------------------------------------------------------------------------------------------------------------------------

📖**PROJECT OVERVIEW**
---------------------------------------------------------------------------------------------------------------------------------
This project involves :
1. **Data Architecture** : Designing a Modern Data Warehouse using Medallion Architecture **Bronze, Silver**, and **Gold**
    layers.
2. **ETL Pipelines** : Extracting, transforming and loading data from source systems into warehouse.
3. **Data Modeling** : Developing fact and dimensions tables optimized for analytical queries.
4. **Analytics and Reporting** : Creating SQL based reports and dashboards for actionable insights.

  🎯This repository is an excellent resource for professionals and students looking to showcase expertise in :
  - SQL Development
  - Data Architect
  - Data Engineering
  - ETL pipeline Developer
  - Data Modeling
  - Data Analytics

-------------------------------------------------------------------------------------------------------------------------------------
🚀**PROJECT REQUIREMENTS**
-------------------------------------------------------------------------------------------------------------------------------------
**Building the Data Watehouse (Data Engineering)**

**Objective**:
Develop a modern Data Warehouse using SQL server to consolidate sales data, enabling analytical reporting and 
informed decision making.

**Specifications**:
1. **Data Sources** : Import data from two source system (ERP & CRM) provided as CSV files.
2. **Data Quality** : Cleanse and resolve data quality issues prior to analysis.
3. **Integration** : Combine both sources into a single, user-friendly data model designed for analytical queries.
4. **Scope** : Focus on the latest dataset only,historization of data is not required.
5. **Documentation** : Provide clear documentation of the data model to support both business stakeholders and analytics teams.

-------------------------------------------------------------------------------------------------------------------------------------
**DATA ARCHITECTURE** 
-------------------------------------------------------------------------------------------------------------------------------------
The Data Architecture for this project follows Medallion Architecture **Bronze, Silver** and **Gold** Layers

<img width="911" height="611" alt="Data Warehouse Diagram drawio" src="https://github.com/user-attachments/assets/d0d3a17e-bb39-4792-86b8-b6eddbe87c30" />

**Bronze Layer** : Stores raw data as is from the source systems. Data is ingested from CSV files into SQL server database.

**Silver Layer** : This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.

**Gold Layer** : Houses buisiness ready data modeled into a star schema required for reporting and analytics.

--------------------------------------------------------------------------------------------------------------------------------------
