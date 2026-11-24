/*==============================================================================
  PROJECT:  E-Commerce Product & Inventory Analytics Portfolio
  ENGINE:   Microsoft SQL Server (T-SQL / SSMS)
  FILE:     01_database_schema_and_setup.sql
  PURPOSE:  Database creation, table schema, staging load, and analytical views
==============================================================================*/

-- 1. Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'EcommerceAnalyticsDB')
BEGIN
    CREATE DATABASE EcommerceAnalyticsDB;
END
GO

USE EcommerceAnalyticsDB;
GO

-- 2. Create Production Table
IF OBJECT_ID('dbo.Products', 'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products (
    ProductIndex    INT            NOT NULL PRIMARY KEY,
    ProductName     NVARCHAR(255)  NOT NULL,
    Description     NVARCHAR(MAX)  NULL,
    Brand           NVARCHAR(150)  NOT NULL,
    Category        NVARCHAR(100)  NOT NULL,
    Price           DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    Currency        CHAR(3)        NOT NULL DEFAULT 'USD',
    Stock           INT            NOT NULL CHECK (Stock >= 0),
    EAN             VARCHAR(20)    NOT NULL,
    Color           NVARCHAR(50)   NULL,
    Size            NVARCHAR(50)   NULL,
    Availability    VARCHAR(30)    NOT NULL,
    InternalID      INT            NOT NULL,
    -- Persisted Computed Column for fast Inventory Valuation
    InventoryValue  AS (CAST(Price AS DECIMAL(18,2)) * Stock) PERSISTED
);
GO

-- 3. Create Non-Clustered Indexes for Analytical Performance
CREATE NONCLUSTERED INDEX IX_Products_Category     ON dbo.Products (Category) INCLUDE (Price, Stock, Availability);
CREATE NONCLUSTERED INDEX IX_Products_Availability ON dbo.Products (Availability) INCLUDE (Price, Stock);
CREATE NONCLUSTERED INDEX IX_Products_InternalID   ON dbo.Products (InternalID);
GO

-- 4. Bulk Insert from Raw CSV (Update file path to your local environment)
/*
BULK INSERT dbo.Products (
    ProductIndex, ProductName, Description, Brand, Category,
    Price, Currency, Stock, EAN, Color, Size, Availability, InternalID
)
FROM 'C:\Portfolio\Ecommerce-Products-Analytics-Portfolio\data\raw\ecommerce_products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO
*/

-- 5. Verify Load
SELECT COUNT(*) AS TotalRecordsLoaded,
       SUM(Stock) AS TotalUnits,
       SUM(InventoryValue) AS TotalInventoryCapital
FROM dbo.Products;
GO
