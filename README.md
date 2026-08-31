# SQL Data Warehouse Project

A SQL Server data warehouse project built using the Medallion Architecture with Bronze, Silver, and Gold layers.

The project loads raw CRM and ERP data, cleans and transforms the data, performs data quality checks, and creates business-ready views for analytics and reporting.

---

## Data Architecture

The project follows a three-layer data warehouse architecture:

Source Data → Bronze Layer → Silver Layer → Gold Layer

### Bronze Layer

The Bronze layer stores raw CRM and ERP source data in SQL Server.

The data is loaded from CSV files with minimal transformation.

### Silver Layer

The Silver layer cleans, standardizes, validates, and transforms the Bronze data.

This layer prepares the data for integration and analytical use.

### Gold Layer

The Gold layer contains the final business-ready views.

The current Gold layer follows a Star Schema containing customer and product dimensions and a sales fact view.

---

## Project Overview

The project demonstrates the process of building a SQL Server data warehouse from raw source data.

### Main Workflow

1. Load CRM and ERP source data.
2. Store raw data in the Bronze layer.
3. Clean and transform data in the Silver layer.
4. Perform Silver layer quality checks.
5. Integrate CRM and ERP data.
6. Create Gold dimension and fact views.
7. Perform Gold layer quality checks.
8. Prepare business-ready data for analytics and reporting.

---

## Data Sources

The project uses two source systems.

### CRM

CRM data contains:

- Customer information
- Product information
- Sales details

Files:

    cust_info.csv
    prd_info.csv
    sales_details.csv

### ERP

ERP data contains:

- Customer information
- Location information
- Product category information

Files:

    CUST_AZ12.csv
    LOC_A101.csv
    PX_CAT_G1V2.csv

---

## Data Flow

    CRM CSV Files ─────┐
                       │
                       ▼
                ┌───────────────┐
                │ Bronze Layer  │
                │   Raw Data    │
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │ Silver Layer  │
                │ Cleaned Data  │
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │  Gold Layer   │
                │ Business Data │
                └───────┬───────┘
                        │
                        ▼
                Analytics & Reporting
                        ▲
                        │
                ┌───────┴───────┐
                │  ERP CSV Data │
                └───────────────┘

---

## Bronze Layer

The Bronze layer stores the raw source tables.

### CRM Tables

    bronze.crm_cust_info
    bronze.crm_prd_info
    bronze.crm_sales_details

### ERP Tables

    bronze.erp_cust_az12
    bronze.erp_loc_a101
    bronze.erp_px_cat_g1v2

### Bronze Loading

The Bronze loading process:

- Truncates existing Bronze tables.
- Loads CRM CSV files.
- Loads ERP CSV files.
- Uses BULK INSERT.
- Prints loading messages.
- Tracks loading duration.
- Handles errors during loading.

---

## Silver Layer

The Silver layer cleans and transforms the Bronze data.

### Customer Data

- Removes duplicate customer records.
- Keeps the latest customer record using ROW_NUMBER().
- Trims customer names.
- Standardizes marital status.
- Standardizes gender values.

### Product Data

- Separates category and product keys.
- Standardizes product line values.
- Handles missing product costs.
- Converts date values.
- Creates product validity periods.

### Sales Data

- Handles invalid dates.
- Validates order, shipping, and due dates.
- Validates sales, quantity, and price relationships.
- Handles invalid sales values.
- Handles invalid prices.

### ERP Customer Data

- Removes the NAS prefix from customer IDs.
- Handles future birth dates.
- Standardizes gender values.

### ERP Location Data

- Removes hyphens from customer IDs.
- Standardizes country names.

### ERP Product Category Data

- Loads ERP product category information into the Silver layer.
- Prepares category information for integration with product data.

---

## Data Quality Checks

Data quality checks are stored separately in the tests directory.

### Silver Quality Checks

File:

    tests/quality_checks_silver.sql

Checks include:

- NULL and duplicate keys.
- Unwanted spaces.
- Data standardization.
- Invalid product costs.
- Invalid date ranges.
- Invalid sales dates.
- Sales, quantity, and price consistency.
- Customer birthdate validation.
- Country standardization.
- Product category consistency.

### Gold Quality Checks

File:

    tests/quality_checks_gold.sql

Checks include:

- Customer surrogate key uniqueness.
- Product surrogate key uniqueness.
- Fact-to-dimension relationships.
- Referential integrity between fact and dimension views.

---

## Gold Layer

The Gold layer contains the final analytical views.

### Customer Dimension

    gold.dim_customers

Contains:

- Customer key
- Customer ID
- Customer number
- First name
- Last name
- Country
- Marital status
- Gender
- Birthdate
- Create date

A surrogate customer key is generated using ROW_NUMBER().

CRM and ERP customer information are integrated into the customer dimension.

### Product Dimension

    gold.dim_products

Contains:

- Product key
- Product ID
- Product number
- Product name
- Category ID
- Category
- Subcategory
- Maintenance
- Cost
- Product line
- Start date

CRM product information is integrated with ERP product category information.

### Sales Fact

    gold.fact_sales

Contains:

- Order number
- Product key
- Customer key
- Order date
- Shipping date
- Due date
- Sales amount
- Quantity
- Price

The sales fact connects sales transactions with the customer and product dimensions.

---

## Star Schema

The Gold layer follows a Star Schema.

    ┌─────────────────────┐
    │   dim_customers     │
    │                     │
    │ customer_key        │
    │ customer_id         │
    │ customer_number     │
    │ customer details    │
    └──────────┬──────────┘
               │
               │
               ▼
    ┌─────────────────────┐
    │     fact_sales      │
    │                     │
    │ order_number        │
    │ customer_key        │
    │ product_key         │
    │ order_date          │
    │ sales_amount        │
    │ quantity            │
    │ price               │
    └──────────┬──────────┘
               │
               │
               ▼
    ┌─────────────────────┐
    │    dim_products     │
    │                     │
    │ product_key         │
    │ product_id          │
    │ product_number      │
    │ product details     │
    └─────────────────────┘

---

## Repository Structure

    sql-data-warehouse-project/
    │
    ├── datasets/
    │   ├── source_crm/
    │   │   ├── cust_info.csv
    │   │   ├── prd_info.csv
    │   │   └── sales_details.csv
    │   │
    │   └── source_erp/
    │       ├── CUST_AZ12.csv
    │       ├── LOC_A101.csv
    │       └── PX_CAT_G1V2.csv
    │
    ├── docs/
    │   ├── data-architecture.png
    │   ├── data_catalog.md
    │   ├── data_flow.png
    │   ├── data_integration.png
    │   ├── data_layers.pdf
    │   ├── data_model.png
    │   └── naming_conventions.md
    │
    ├── scripts/
    │   ├── bronze_layer/
    │   │   ├── DDL_bronze.sql
    │   │   └── product_load_bronze.sql
    │   │
    │   ├── silver_layer/
    │   │   ├── DDL_silver.sql
    │   │   └── proc_load_silver.sql
    │   │
    │   ├── gold_layer/
    │   │   └── DDL_gold.sql
    │   │
    │   └── init_database.sql
    │
    ├── tests/
    │   ├── quality_checks_silver.sql
    │   └── quality_checks_gold.sql
    │
    ├── .gitignore
    ├── LICENSE
    ├── README.md
    └── requirements.txt

---

## Technologies Used

- SQL Server
- T-SQL
- SQL Server Management Studio (SSMS)
- Git
- GitHub

---

## SQL Concepts Used

The project uses practical SQL concepts including:

- SELECT
- INSERT
- CASE
- JOIN
- LEFT JOIN
- WHERE
- GROUP BY
- HAVING
- TRIM()
- REPLACE()
- SUBSTRING()
- LEN()
- ISNULL()
- COALESCE()
- NULLIF()
- ROW_NUMBER()
- LEAD()
- CAST()
- GETDATE()
- Stored Procedures
- Views
- BULK INSERT
- Data Validation
- Data Quality Testing

---

## How to Run

### 1. Initialize the Database

Run:

    scripts/init_database.sql

### 2. Create Bronze Tables

Run:

    scripts/bronze_layer/DDL_bronze.sql

### 3. Load Bronze Data

Run:

    scripts/bronze_layer/product_load_bronze.sql

This loads the CRM and ERP CSV files into the Bronze layer.

### 4. Create Silver Tables

Run:

    scripts/silver_layer/DDL_silver.sql

### 5. Load Silver Data

Run:

    scripts/silver_layer/proc_load_silver.sql

This cleans and transforms the Bronze data and loads it into the Silver layer.

### 6. Run Silver Quality Checks

Run:

    tests/quality_checks_silver.sql

### 7. Create Gold Views

Run:

    scripts/gold_layer/DDL_gold.sql

This creates:

    gold.dim_customers
    gold.dim_products
    gold.fact_sales

### 8. Run Gold Quality Checks

Run:

    tests/quality_checks_gold.sql

---

## Documentation

Additional project documentation is available in the docs directory.

The documentation includes:

- Data architecture
- Data flow
- Data integration
- Data model
- Data layers
- Data catalog
- Naming conventions

---

## Project Skills Demonstrated

This project demonstrates practical experience with:

- SQL Server Data Warehousing
- Medallion Architecture
- ETL Processes
- Data Ingestion
- Data Cleaning
- Data Transformation
- Data Validation
- Stored Procedures
- SQL Views
- Window Functions
- Star Schema
- Fact and Dimension Modeling
- Surrogate Keys
- Data Quality Testing
- CRM and ERP Data Integration
- Git and GitHub

---

## Project Status

### Completed

- [x] Database initialization
- [x] Bronze layer table creation
- [x] Bronze data loading
- [x] Bronze stored procedure
- [x] Silver layer table creation
- [x] Silver data transformation
- [x] Silver stored procedure
- [x] Silver quality checks
- [x] Gold customer dimension
- [x] Gold product dimension
- [x] Gold sales fact
- [x] Gold quality checks
- [x] Data architecture documentation
- [x] Data flow documentation
- [x] Data model documentation
- [x] Data catalog
- [x] Naming conventions

### Future Work

- [ ] Business analytics queries
- [ ] Analytical reporting
- [ ] Business insights

---

## Author

**Badavath Madanlal**

B.Tech – Computer Science Engineering  
NIT Silchar

---

## License

This project is available under the license included in this repository.
