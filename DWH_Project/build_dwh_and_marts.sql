-- Master Script
-------------------- CLI Command ----------------------------
-- duckdb dwh_marts.duckdb -c ".read build_dwh_and_marts.sql"
-------------------------------------------------------------

-- Step 1: DWH - Create star schema tables on Data Warehouse.
.read 01_create_tables_in_DWH.sql

-- Step 2: DWH - Load Data into tables
.read 02_load_data_into_DWH.sql

-- Step 3: DWH - Data Validation
.read 03_data_validation_of_DWH.sql

-- Step 4: Marts - Create Flat Mart Schema and job_postings flat table
.read 04_create_flat_mart.sql

-- Step 5: Marts - Data Validation of Flat Mart
.read 05_data_validation_flat_mart.sql


