/*
===============================================================================
Procedure: Load Bronze Layer
===============================================================================
Purpose:
    Loads raw CRM and ERP source data into the Bronze layer of our data
    warehouse.
    The procedure clears the existing Bronze tables and then reloads the
    latest data from the corresponding CSV files.

    It also records the loading time for each table and the complete Bronze
    layer batch.

    If an error occurs during the loading process, details about the error
    are displayed in the Messages window.

Parameters:
    None

Execution:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY

        -- Start timing the complete Bronze layer load
        SET @batch_start_time = GETDATE();

        PRINT '==============================================================';
        PRINT 'Starting Bronze Layer Load';
        PRINT '==============================================================';


        -- ================================================================
        -- CRM SOURCE TABLES
        -- ================================================================

        PRINT '--------------------------------------------------------------';
        PRINT 'Loading CRM Source Data';
        PRINT '--------------------------------------------------------------';


        -- Customer information
        SET @start_time = GETDATE();

        PRINT '>> Clearing bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Loading data into bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Projects\SQL-Warehouse-Project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Table Load Time: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '--------------------------------------------------------------';


        -- Product information
        SET @start_time = GETDATE();

        PRINT '>> Clearing bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Loading data into bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Projects\SQL-Warehouse-Project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Table Load Time: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '--------------------------------------------------------------';


        -- Sales transaction information
        SET @start_time = GETDATE();

        PRINT '>> Clearing bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Loading data into bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Projects\SQL-Warehouse-Project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Table Load Time: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '--------------------------------------------------------------';


        -- ================================================================
        -- ERP SOURCE TABLES
        -- ================================================================

        PRINT '--------------------------------------------------------------';
        PRINT 'Loading ERP Source Data';
        PRINT '--------------------------------------------------------------';


        -- Location information
        SET @start_time = GETDATE();

        PRINT '>> Clearing bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Loading data into bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Projects\SQL-Warehouse-Project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Table Load Time: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '--------------------------------------------------------------';


        -- Customer information from ERP
        SET @start_time = GETDATE();

        PRINT '>> Clearing bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Loading data into bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Projects\SQL-Warehouse-Project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Table Load Time: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '--------------------------------------------------------------';


        -- Product category information
        SET @start_time = GETDATE();

        PRINT '>> Clearing bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Loading data into bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Projects\SQL-Warehouse-Project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Table Load Time: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '--------------------------------------------------------------';


        -- ================================================================
        -- BRONZE BATCH COMPLETION
        -- ================================================================

        SET @batch_end_time = GETDATE();

        PRINT '==============================================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT 'Total Batch Load Time: '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '==============================================================';

    END TRY


    BEGIN CATCH

        PRINT '==============================================================';
        PRINT 'Bronze Layer Load Failed';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==============================================================';

    END CATCH

END;
GO
-- Run the Bronze layer loading process
EXEC bronze.load_bronze;
