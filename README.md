<div align="center">

# 🗄️ SQL Server Data Warehouse

*A complete SQL Server Data Warehouse built using a layered Medallion Architecture for data integration, transformation, data quality validation, and analytics.*

<p>
  <img src="https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white">
  <img src="https://img.shields.io/badge/T--SQL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white">
  <img src="https://img.shields.io/badge/SSMS-0078D4?style=for-the-badge&logo=microsoft&logoColor=white">
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white">
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white">
</p>

</div>

---

## 📌 Project Overview

This project implements a SQL Server Data Warehouse using a layered Bronze, Silver, and Gold architecture.

The warehouse integrates data from CRM and ERP CSV sources, loads the source data into the Bronze layer, cleans and standardizes it in the Silver layer, and creates business-ready views in the Gold layer.

The final Gold layer follows a Star Schema with customer and product dimensions connected to a sales fact.

---

## 🏗️ Data Architecture

The warehouse follows a Medallion Architecture where each layer has a specific responsibility.

```text
CRM CSV Files ───────┐
                     │
                     ▼
              ┌───────────────┐
              │ BRONZE LAYER  │
              │   Raw Data    │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │ SILVER LAYER  │
              │ Cleaned Data  │
              └───────┬───────┘
                      │
                      ▼
              ┌───────────────┐
              │  GOLD LAYER   │
              │ Star Schema   │
              └───────────────┘
                      ▲
                      │
ERP CSV Files ────────┘
```

| Layer | Purpose | Main Work |
|---|---|---|
|  Bronze | Store source data | CSV ingestion and raw storage |
|  Silver | Clean and standardize data | Transformation, validation and deduplication |
|  Gold | Prepare analytical data | Dimensions, fact view and business-ready integration |

---

## 📊 Source Data

The warehouse receives data from two source systems.

### CRM Source

CRM provides:

- Customer information
- Product information
- Sales transaction information

Files:

```text
cust_info.csv
prd_info.csv
sales_details.csv
```

### ERP Source

ERP provides:

- Customer information
- Location information
- Product category information

Files:

```text
CUST_AZ12.csv
LOC_A101.csv
PX_CAT_G1V2.csv
```

---

# Bronze Layer

The Bronze layer stores the source data in its original form.

### Bronze Tables

#### CRM

```text
bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details
```

#### ERP

```text
bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2
```

### Bronze Loading

The Bronze loading process is handled by:

```text
bronze.load_bronze
```

The procedure:

- Truncates existing Bronze tables.
- Loads CRM CSV files.
- Loads ERP CSV files.
- Uses `BULK INSERT`.
- Displays loading progress.
- Tracks individual table load duration.
- Tracks total batch duration.
- Uses `TRY...CATCH` for error handling.

### Bronze Scripts

```text
scripts/
└── bronze_layer/
    ├── DDL_bronze.sql
    └── product_load_bronze.sql
```

---

# Silver Layer

The Silver layer transforms raw Bronze data into cleaned and standardized data.

The Silver loading process is handled by:

```text
silver.load_silver
```

## Customer Transformation

CRM customer data is cleaned by:

- Removing duplicate customer records.
- Keeping the latest customer record.
- Using `ROW_NUMBER()` for deduplication.
- Removing unwanted spaces.
- Standardizing marital status.
- Standardizing gender values.

### Marital Status

```text
S → Single
M → Married
Other → n/a
```

### Gender

```text
F → Female
M → Male
Other → n/a
```

---

## Product Transformation

CRM product data is transformed by:

- Separating category and product keys.
- Standardizing product line values.
- Handling missing product costs.
- Converting date values.
- Creating product validity periods using `LEAD()`.

### Product Line

```text
M → Mountain
R → Road
S → Other Sales
T → Touring
Other → n/a
```

---

## Sales Transformation

Sales data is transformed and validated by:

- Converting date values.
- Handling invalid dates.
- Validating order, shipping and due dates.
- Validating sales, quantity and price relationships.
- Handling invalid sales values.
- Handling invalid prices.

The main consistency rule is:

```text
Sales = Quantity × Price
```

---

## ERP Customer Transformation

ERP customer data is cleaned by:

- Removing the `NAS` prefix from customer IDs.
- Handling future birth dates.
- Standardizing gender values.

Example:

```text
NAS000110001
      ↓
000110001
```

---

## ERP Location Transformation

Location data is standardized by:

- Removing hyphens from customer IDs.
- Standardizing country names.

Examples:

```text
DE  → Germany
US  → United States
USA → United States
UK  → United Kingdom
```

---

## ERP Product Category

ERP product category data is loaded into:

```text
silver.erp_px_cat_g1v2
```

This data is later integrated with CRM product information in the Gold layer.

---

## Silver Data Quality

Silver quality checks are maintained separately in:

```text
tests/quality_checks_silver.sql
```

The checks validate:

- NULL and duplicate keys.
- Unwanted spaces.
- Negative values.
- Data standardization.
- Product date ranges.
- Sales date relationships.
- Sales, quantity and price consistency.
- Customer birthdate ranges.
- Country values.
- Product category values.

---

# Gold Layer

The Gold layer contains the final analytical views.

The Gold layer combines cleaned Silver data and creates a Star Schema.

### Gold Objects

```text
gold.dim_customers
gold.dim_products
gold.fact_sales
```

---

## 👤 Customer Dimension

```text
gold.dim_customers
```

The customer dimension combines:

```text
silver.crm_cust_info
silver.erp_cust_az12
silver.erp_loc_a101
```

### Main Columns

```text
customer_key
customer_id
customer_number
first_name
last_name
country
marital_status
gender
birthdate
create_date
```

A surrogate key is generated using:

```sql
ROW_NUMBER()
```

CRM gender information is used as the primary source, with ERP gender information used as a fallback when required.

---

## 🚲 Product Dimension

```text
gold.dim_products
```

The product dimension combines:

```text
silver.crm_prd_info
silver.erp_px_cat_g1v2
```

### Main Columns

```text
product_key
product_id
product_number
product_name
category_id
category
subcategory
maintenance
cost
product_line
start_date
```

Only current product records are included:

```sql
WHERE pn.prd_end_dt IS NULL
```

---

## 💰 Sales Fact

```text
gold.fact_sales
```

The sales fact connects sales transactions with the customer and product dimensions.

### Main Columns

```text
order_number
product_key
customer_key
order_date
shipping_date
due_date
sales_amount
quantity
price
```

The fact view uses the surrogate keys from the Gold dimensions.

---

# ⭐ Star Schema

The final Gold layer follows a Star Schema.

```text
                    ┌─────────────────────┐
                    │   dim_customers     │
                    │                     │
                    │ customer_key        │
                    │ customer_id         │
                    │ customer_number     │
                    │ first_name          │
                    │ last_name           │
                    │ country             │
                    │ gender              │
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
                    │ product_name        │
                    │ category            │
                    │ subcategory         │
                    │ cost                │
                    └─────────────────────┘
```

---

# 🧪 Gold Data Quality

Gold quality checks are maintained separately in:

```text
tests/quality_checks_gold.sql
```

The checks validate:

### Customer Dimension

- Uniqueness of `customer_key`.

### Product Dimension

- Uniqueness of `product_key`.

### Fact Table

- Fact-to-customer relationship.
- Fact-to-product relationship.
- Referential integrity between fact and dimensions.

The objective is to ensure that the Gold model is properly connected for analytical use.

---

# 🔄 Data Flow

The implemented data flow is:

```text
             CRM CSV Files
                   │
                   ▼
          ┌─────────────────┐
          │  Bronze Layer   │
          │   Raw Source    │
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │  Silver Layer   │
          │ Cleaned &       │
          │ Standardized    │
          └────────┬────────┘
                   │
                   ▼
          ┌─────────────────┐
          │   Gold Layer    │
          │ Dimensions +    │
          │ Fact View       │
          └────────┬────────┘
                   │
                   ▼
            Analytical Data


             ERP CSV Files
                   │
                   └──────────────► Bronze Layer
```

---

# ▶️ Execution Flow

The project is executed in the following sequence:

```text
1. Initialize SQL Server database and schemas
                         │
                         ▼
2. Create Bronze tables
                         │
                         ▼
3. Execute bronze.load_bronze
                         │
                         ▼
4. Create Silver tables
                         │
                         ▼
5. Execute silver.load_silver
                         │
                         ▼
6. Run Silver quality checks
                         │
                         ▼
7. Create Gold dimension and fact views
                         │
                         ▼
8. Run Gold quality checks
```

---

# 🛠️ Technology Stack

| Area | Technology |
|---|---|
| Database | SQL Server |
| Query Language | T-SQL |
| Development Environment | SQL Server Management Studio |
| Data Loading | `BULK INSERT` |
| Data Processing | Stored Procedures |
| Architecture | Medallion Architecture |
| Data Modeling | Star Schema |
| Version Control | Git / GitHub |

---

# 💻 SQL Concepts Used

The project uses practical SQL Server and T-SQL concepts.

### DDL

```text
CREATE DATABASE
CREATE SCHEMA
CREATE TABLE
CREATE VIEW
CREATE PROCEDURE
ALTER PROCEDURE
DROP TABLE
DROP VIEW
```

### Data Loading

```text
BULK INSERT
INSERT INTO
TRUNCATE TABLE
```

### Data Transformation

```text
CASE
TRIM()
REPLACE()
SUBSTRING()
LEN()
CAST()
ISNULL()
COALESCE()
NULLIF()
GETDATE()
```

### Querying and Integration

```text
SELECT
WHERE
LEFT JOIN
GROUP BY
HAVING
ORDER BY
```

### Window Functions

```text
ROW_NUMBER()
LEAD()
```

### Error Handling

```text
TRY...CATCH
ERROR_MESSAGE()
ERROR_NUMBER()
ERROR_STATE()
```

### Data Quality

```text
Duplicate detection
NULL validation
Date validation
Value validation
Relationship validation
Standardization checks
```

---

# 📂 Project Structure

```text
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
│   │
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
```

---

# 📁 SQL Script Organization

The SQL scripts are separated according to the warehouse layer.

### Bronze

```text
scripts/bronze_layer/DDL_bronze.sql
scripts/bronze_layer/product_load_bronze.sql
```

Used for:

- Bronze table creation.
- Raw CRM and ERP data loading.

### Silver

```text
scripts/silver_layer/DDL_silver.sql
scripts/silver_layer/proc_load_silver.sql
```

Used for:

- Silver table creation.
- Data cleaning.
- Data transformation.
- Data standardization.
- Silver loading.

### Gold

```text
scripts/gold_layer/DDL_gold.sql
```

Used for:

- Customer dimension.
- Product dimension.
- Sales fact view.

### Tests

```text
tests/quality_checks_silver.sql
tests/quality_checks_gold.sql
```

Used for validating the Silver and Gold layers.

---

# 📖 Documentation

Supporting project documentation is maintained in the `docs` directory.

```text
data-architecture.png
data_catalog.md
data_flow.png
data_integration.png
data_layers.pdf
data_model.png
naming_conventions.md
```

These documents describe the implemented warehouse architecture, data flow, data integration, data model, data layers, data catalog and naming conventions.

---

# 📋 Implementation Summary

| Area | Implemented Work |
|---|---|
| Data Sources | CRM and ERP CSV data |
| Database | SQL Server |
| Language | T-SQL |
| Architecture | Bronze, Silver and Gold |
| Bronze Loading | Stored procedure + `BULK INSERT` |
| Silver Processing | Cleaning, transformation and standardization |
| Deduplication | `ROW_NUMBER()` |
| Date Processing | Validation and conversion |
| Data Validation | Silver and Gold quality checks |
| Gold Modeling | Customer and product dimensions + sales fact |
| Surrogate Keys | `ROW_NUMBER()` |
| Data Integration | CRM + ERP |
| Data Model | Star Schema |

---

# ✅ Project Status

The following components have been implemented:

- Database initialization
- Bronze table creation
- Bronze data loading
- Bronze stored procedure
- Silver table creation
- Silver data cleaning
- Silver data transformation
- Silver standardization
- Silver loading procedure
- Silver quality checks
- Gold customer dimension
- Gold product dimension
- Gold sales fact
- Gold quality checks
- CRM and ERP integration
- Star Schema modeling
- Supporting project documentation

---

# 🎯 Project Focus

The main focus of this project is building a clean, layered SQL Server Data Warehouse that transforms raw CRM and ERP data into reliable, standardized and business-ready data for analytical use.

```text
Raw Source Data
       ↓
Data Ingestion
       ↓
Data Cleaning
       ↓
Data Transformation
       ↓
Data Quality Validation
       ↓
Dimensional Modeling
       ↓
Business-Ready Data
```
---

<div align="start">

### Developed by Badavath Madanlal

</div>


---

<div align="center">

### 🗄️ SQL Server Data Warehouse

**Bronze → Silver → Gold → Analytics Ready**

</div>
