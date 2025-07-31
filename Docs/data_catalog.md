**Data Dictionary for Gold Layer**
----------------------------------------------------------------------------------------------------------------------------------------------------
**Overview**
----------------------------------------------------------------------------------------------------------------------------------------------------
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension**
**tables** and **fact tables** for specific business metrics.

----------------------------------------------------------------------------------------------------------------------------------------------------
**1. Gold.dim_customers**

**Purpose** : stores customer details enriched with demographic & geographic data.

**Columns** :

**Column Name**                     **Data Type**                                                    **Description**     

customer_key                            INT                      Surrogate key uniquely identifying each customer record in the dimension table.

customer_id                             INT                     Unique numerical identifier assigned to each customer.

customer_number                        NVARCHAR(50)               Alphanumeric identifier representing the customer used for tracking and referencing.

first_name                             NVARCHAR(50)                The customer's first name as recorded in the system 

last_name                              NVARCHAR(50)                The customer's last name or family name

country                                NVARCHAR(50)                The country of residence for the customer (e.g. Australia)

marital_status                         NVARCHAR(50)                The marital status of the customer (e.g.'Married','Single')   

gender                                 NVARCHAR(50)                The Gender of the customer (e.g.'Male','Female','N/A')                          

birthdate                                  DATE                     The date of birth of the customer, formatted as YYYY-MM-DD (e.g.1995-10-13)

create_date                                DATE                     The date and time when the customer record was created in the system

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
**2. Gold.dim_products**

**Purpose** : Provides information about the products and their attributes.

**Columns** :

**Column Name**                     **Data Type**                                                     **Description**    

product_key                             INT                      Surrogate key uniquely identifying each product record in the dimension table.

product_id                              INT                       Unique numerical identifier assigned to product for internal tracking and referencing.

product_number                       NVARCHAR(50)                 A structured Alphanumeric code representing the product often used for categorization or inventory

product_name                         NVARCHAR(50)                 Desciptive name of the product, including key details such as type, colour and size

category_id                          NVARCHAR(50)                 Unique numerical identifier for the products category, linking to its high level classification

category                             NVARCHAR(50)                 A broader classification of the product to group related items                  

subcategory                          NVARCHAR(50)                 A more detailed classification of the product within the category such as product type

maintenance                          NVARCHAR(50)                 Indicates whether the product requires maintenance (e.g.'Yes','No')            
 
cost                                    INT                       The cost or base price of the product, measured in monetary unit

product_line                         NVARCHAR(50)                 The specific product line or series to which the product belongs (e.g.'Road','Mountains')  

start_date                              DATE                      The date when the product became available for sale or use, stored in 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
**2. Gold.fact_sales**

**Purpose** : Stores transactional sales data for analytical purposes

**Columns** :

**Column Name**                     **Data Type**                                                     **Description**  

 order_number                         NVARCHAR(50)                            Unique Alphanumeric identifier for each sales order (e.g.'SO54496')

 product_key                             INT                                  Surrogate key linking the order to the product dimension table 

 customer_key                            INT                                  Surrogate key linking the order to the customer dimension table

 order_date                             DATE                                  The date when the order was placed

 shipping_date                          DATE                                   The date when the order was shipped to the customer

 due_date                               DATE                                   The date when the order payment was due

 sales_amount                           INT                                    The total monetary value of the sale for the line item, in whole currency units

 quantity                               INT                                     The number of units of product ordered for the line item

 price                                  INT                                     The price per units of product for the line item, in whole currency units





