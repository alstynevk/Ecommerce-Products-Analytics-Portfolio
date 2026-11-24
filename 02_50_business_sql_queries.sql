/*==============================================================================
  PROJECT:  E-Commerce Product & Inventory Analytics Portfolio
  ENGINE:   Microsoft SQL Server (T-SQL)
  FILE:     02_50_business_sql_queries.sql
  CONTENTS: 50 Production-Grade T-SQL Queries Across 5 Analytical Tiers:
            - Section 1 (Q01-Q10): Data Profiling & Quality Auditing
            - Section 2 (Q11-Q20): Filtering, Pricing & Catalog Exploration
            - Section 3 (Q21-Q30): Aggregations, Category & Availability KPIs
            - Section 4 (Q31-Q40): Window Functions, Ranking & ABC Pareto Analysis
            - Section 5 (Q41-Q50): Advanced T-SQL (CTEs, PIVOT, ROLLUP, Views, SPs)
==============================================================================*/

USE EcommerceAnalyticsDB;
GO

/*==============================================================================
  SECTION 1: DATA PROFILING & QUALITY AUDITING (Q01 - Q10)
==============================================================================*/

-- Q01: Executive Catalog Snapshot (Total SKUs, Brands, Categories, Units, Total Capital)
SELECT
    COUNT(*)                                AS TotalSKUs,
    COUNT(DISTINCT Brand)                   AS UniqueBrands,
    COUNT(DISTINCT Category)                AS UniqueCategories,
    COUNT(DISTINCT Color)                   AS UniqueColors,
    COUNT(DISTINCT Size)                    AS UniqueSizes,
    SUM(Stock)                              AS TotalStockUnits,
    FORMAT(SUM(InventoryValue), 'C0')       AS TotalInventoryValue,
    FORMAT(AVG(Price), 'C2')                AS AvgUnitPrice,
    CAST(AVG(CAST(Stock AS FLOAT)) AS DECIMAL(10,2)) AS AvgStockPerSKU
FROM dbo.Products;

-- Q02: Null & Blank Value Audit Across All Critical Columns
SELECT
    SUM(CASE WHEN ProductName IS NULL OR LTRIM(RTRIM(ProductName)) = '' THEN 1 ELSE 0 END) AS MissingName,
    SUM(CASE WHEN Brand IS NULL OR LTRIM(RTRIM(Brand)) = '' THEN 1 ELSE 0 END)             AS MissingBrand,
    SUM(CASE WHEN Category IS NULL OR LTRIM(RTRIM(Category)) = '' THEN 1 ELSE 0 END)       AS MissingCategory,
    SUM(CASE WHEN Price IS NULL OR Price <= 0 THEN 1 ELSE 0 END)                           AS InvalidPrice,
    SUM(CASE WHEN Stock IS NULL OR Stock < 0 THEN 1 ELSE 0 END)                            AS InvalidStock,
    SUM(CASE WHEN EAN IS NULL OR LEN(EAN) < 10 THEN 1 ELSE 0 END)                          AS SuspiciousEAN,
    SUM(CASE WHEN Availability IS NULL THEN 1 ELSE 0 END)                                  AS MissingAvailability
FROM dbo.Products;

-- Q03: Detect Duplicate Product Names Across Different Brands/Categories
SELECT
    ProductName,
    COUNT(*) AS OccurrenceCount,
    STRING_AGG(CONCAT(Brand, ' (', Category, ')'), ' | ') AS BrandCategoryDetails
FROM dbo.Products
GROUP BY ProductName
HAVING COUNT(*) > 1;

-- Q04: Detect Non-Unique Internal IDs (Primary/Surrogate Key Governance Audit)
SELECT
    InternalID,
    COUNT(*) AS SharedSKUCount,
    STRING_AGG(CAST(ProductIndex AS VARCHAR(10)), ', ') AS ProductIndexes,
    STRING_AGG(Category, ', ') AS Categories
FROM dbo.Products
GROUP BY InternalID
HAVING COUNT(*) > 1
ORDER BY SharedSKUCount DESC, InternalID;

-- Q05: Validate EAN Barcode Uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT EAN) AS UniqueEANs,
    COUNT(*) - COUNT(DISTINCT EAN) AS DuplicateEANCount
FROM dbo.Products;

-- Q06: Critical ERP Sync Anomaly — Out-of-Stock Items Holding Physical Stock
SELECT
    ProductIndex,
    ProductName,
    Category,
    Price,
    Stock,
    InventoryValue AS TrappedCapital,
    Availability
FROM dbo.Products
WHERE Availability = 'out_of_stock' AND Stock > 0
ORDER BY InventoryValue DESC;

-- Q07: Dead/Liquidation Capital Audit — Discontinued Items Still in Warehouse
SELECT
    ProductIndex,
    ProductName,
    Brand,
    Category,
    Price,
    Stock,
    InventoryValue AS LiquidationCapital
FROM dbo.Products
WHERE Availability = 'discontinued' AND Stock > 0
ORDER BY InventoryValue DESC;

-- Q08: Ultra-Low Pricing Anomaly Detection (Potential Data Entry Errors < $50)
SELECT
    ProductIndex,
    ProductName,
    Brand,
    Category,
    Price,
    Stock,
    Availability
FROM dbo.Products
WHERE Price < 50
ORDER BY Price ASC;

-- Q09: Currency Standardization Check
SELECT
    Currency,
    COUNT(*) AS SKUCount
FROM dbo.Products
GROUP BY Currency;

-- Q10: Size Standardization Audit (Mixed Apparel vs. Dimensional Formats)
SELECT
    Size,
    COUNT(*) AS SKUCount,
    CASE
        WHEN Size IN ('XS','S','M','L','XL','XXL','Small','Medium','Large','Extra Large') THEN 'Apparel / Standard'
        WHEN Size LIKE '%x%' THEN 'Dimensional (in/cm/mm)'
        ELSE 'Other'
    END AS SizeFormatType
FROM dbo.Products
GROUP BY Size
ORDER BY SizeFormatType, SKUCount DESC;


/*==============================================================================
  SECTION 2: FILTERING, PRICING & CATALOG EXPLORATION (Q11 - Q20)
==============================================================================*/

-- Q11: Top 10 Most Expensive Products in Catalog
SELECT TOP 10
    ProductIndex,
    ProductName,
    Brand,
    Category,
    Price,
    Stock,
    Availability
FROM dbo.Products
ORDER BY Price DESC;

-- Q12: Bottom 10 Lowest Priced Products in Catalog
SELECT TOP 10
    ProductIndex,
    ProductName,
    Brand,
    Category,
    Price,
    Stock,
    Availability
FROM dbo.Products
ORDER BY Price ASC;

-- Q13: Top 10 Highest Inventory Value SKUs (Capital Concentration)
SELECT TOP 10
    ProductIndex,
    ProductName,
    Category,
    Price,
    Stock,
    FORMAT(InventoryValue, 'C0') AS InventoryValue,
    Availability
FROM dbo.Products
ORDER BY InventoryValue DESC;

-- Q14: Low-Stock Reorder Watchlist (Active Products with Stock <= 200 Units)
SELECT
    ProductIndex,
    ProductName,
    Category,
    Price,
    Stock,
    Availability
FROM dbo.Products
WHERE Stock <= 200
  AND Availability IN ('in_stock', 'limited_stock', 'pre_order')
ORDER BY Stock ASC;

-- Q15: High-Value Surplus Stock (Price >= $500 AND Stock >= 700)
SELECT
    ProductIndex,
    ProductName,
    Category,
    Price,
    Stock,
    InventoryValue,
    Availability
FROM dbo.Products
WHERE Price >= 500 AND Stock >= 700
ORDER BY InventoryValue DESC;

-- Q16: Keyword Search — Smart, Wireless, or Portable Tech Products
SELECT
    ProductIndex,
    ProductName,
    Category,
    Price,
    Stock,
    Availability
FROM dbo.Products
WHERE ProductName LIKE '%Smart%'
   OR ProductName LIKE '%Wireless%'
   OR ProductName LIKE '%Portable%'
ORDER BY Price DESC;

-- Q17: Products Priced Above the Global Catalog Average
SELECT
    ProductIndex,
    ProductName,
    Category,
    Price,
    CAST(Price - (SELECT AVG(Price) FROM dbo.Products) AS DECIMAL(10,2)) AS VarianceFromAvg
FROM dbo.Products
WHERE Price > (SELECT AVG(Price) FROM dbo.Products)
ORDER BY Price DESC;

-- Q18: Color Palette Popularity (Top 10 Colors by SKU Count & Inventory Value)
SELECT TOP 10
    Color,
    COUNT(*) AS SKUCount,
    SUM(Stock) AS TotalUnits,
    SUM(InventoryValue) AS TotalInventoryValue
FROM dbo.Products
GROUP BY Color
ORDER BY SKUCount DESC, TotalInventoryValue DESC;

-- Q19: Apparel Categories Deep-Dive (Women's, Men's, Kids' & General Clothing)
SELECT
    Category,
    ProductName,
    Price,
    Stock,
    Size,
    Availability
FROM dbo.Products
WHERE Category LIKE '%Clothing%'
ORDER BY Category, Price DESC;

-- Q20: Pre-Order Pipeline Valuation & Unit Commitment
SELECT
    Category,
    COUNT(*) AS PreOrderSKUs,
    SUM(Stock) AS CommittedUnits,
    AVG(Price) AS AvgPreOrderPrice,
    SUM(InventoryValue) AS PipelineValue
FROM dbo.Products
WHERE Availability = 'pre_order'
GROUP BY Category
ORDER BY PipelineValue DESC;


/*==============================================================================
  SECTION 3: AGGREGATIONS, CATEGORY & AVAILABILITY KPIs (Q21 - Q30)
==============================================================================*/

-- Q21: Availability Status Performance Summary (SKUs, Units, Capital & Share %)
SELECT
    Availability,
    COUNT(*) AS SKUCount,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS PctOfSKUs,
    SUM(Stock) AS TotalStock,
    CAST(AVG(Price) AS DECIMAL(10,2)) AS AvgPrice,
    SUM(InventoryValue) AS TotalInventoryValue,
    CAST(SUM(InventoryValue) * 100.0 / SUM(SUM(InventoryValue)) OVER() AS DECIMAL(5,2)) AS PctOfCapital
FROM dbo.Products
GROUP BY Availability
ORDER BY TotalInventoryValue DESC;

-- Q22: Full Category Performance Scorecard (All 32 Categories)
SELECT
    Category,
    COUNT(*) AS SKUCount,
    SUM(Stock) AS TotalUnits,
    CAST(AVG(Price) AS DECIMAL(10,2)) AS AvgPrice,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    SUM(InventoryValue) AS TotalInventoryValue
FROM dbo.Products
GROUP BY Category
ORDER BY TotalInventoryValue DESC;

-- Q23: Categories with Total Inventory Value Exceeding $1,000,000
SELECT
    Category,
    COUNT(*) AS SKUCount,
    SUM(Stock) AS TotalUnits,
    FORMAT(SUM(InventoryValue), 'C0') AS TotalInventoryValue
FROM dbo.Products
GROUP BY Category
HAVING SUM(InventoryValue) > 1000000
ORDER BY SUM(InventoryValue) DESC;

-- Q24: Price Tier Segmentation Analysis (Budget, Mid-Range, Premium, Luxury)
SELECT
    CASE
        WHEN Price <= 200 THEN '1. Budget ($1-$200)'
        WHEN Price <= 500 THEN '2. Mid-Range ($201-$500)'
        WHEN Price <= 750 THEN '3. Premium ($501-$750)'
        ELSE '4. Luxury ($751+)'
    END AS PriceTier,
    COUNT(*) AS SKUCount,
    SUM(Stock) AS TotalUnits,
    CAST(AVG(Price) AS DECIMAL(10,2)) AS AvgTierPrice,
    SUM(InventoryValue) AS TotalInventoryValue,
    CAST(SUM(InventoryValue) * 100.0 / (SELECT SUM(InventoryValue) FROM dbo.Products) AS DECIMAL(5,2)) AS PctTotalValue
FROM dbo.Products
GROUP BY
    CASE
        WHEN Price <= 200 THEN '1. Budget ($1-$200)'
        WHEN Price <= 500 THEN '2. Mid-Range ($201-$500)'
        WHEN Price <= 750 THEN '3. Premium ($501-$750)'
        ELSE '4. Luxury ($751+)'
    END
ORDER BY PriceTier;

-- Q25: Stock Level Buckets Distribution
SELECT
    CASE
        WHEN Stock <= 200 THEN '1. Low (<=200)'
        WHEN Stock <= 500 THEN '2. Moderate (201-500)'
        WHEN Stock <= 800 THEN '3. High (501-800)'
        ELSE '4. Surplus (801+)'
    END AS StockBucket,
    COUNT(*) AS SKUCount,
    SUM(Stock) AS TotalUnits,
    SUM(InventoryValue) AS TotalInventoryValue
FROM dbo.Products
GROUP BY
    CASE
        WHEN Stock <= 200 THEN '1. Low (<=200)'
        WHEN Stock <= 500 THEN '2. Moderate (201-500)'
        WHEN Stock <= 800 THEN '3. High (501-800)'
        ELSE '4. Surplus (801+)'
    END
ORDER BY StockBucket;

-- Q26: Weighted Average Unit Price vs. Simple Average Price by Category
SELECT
    Category,
    CAST(AVG(Price) AS DECIMAL(10,2)) AS SimpleAvgPrice,
    CAST(SUM(InventoryValue) * 1.0 / NULLIF(SUM(Stock), 0) AS DECIMAL(10,2)) AS WeightedAvgPrice,
    CAST((SUM(InventoryValue) * 1.0 / NULLIF(SUM(Stock), 0)) - AVG(Price) AS DECIMAL(10,2)) AS PriceSkew
FROM dbo.Products
GROUP BY Category
ORDER BY WeightedAvgPrice DESC;

-- Q27: Price Volatility (Standard Deviation & Range) Across Multi-SKU Categories
SELECT
    Category,
    COUNT(*) AS SKUCount,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    MAX(Price) - MIN(Price) AS PriceSpread,
    CAST(STDEV(Price) AS DECIMAL(10,2)) AS PriceStdDev
FROM dbo.Products
GROUP BY Category
HAVING COUNT(*) >= 3
ORDER BY PriceStdDev DESC;

-- Q28: Capital-at-Risk Aggregation (Active vs. At-Risk Inventory)
SELECT
    CASE
        WHEN Availability IN ('out_of_stock', 'discontinued') THEN 'At-Risk Capital (OOS / Discontinued)'
        WHEN Availability IN ('backorder', 'limited_stock')   THEN 'Constrained Supply (Backorder / Limited)'
        ELSE 'Healthy / Pipeline (In Stock / Pre-Order)'
    END AS CapitalHealthTier,
    COUNT(*) AS SKUCount,
    SUM(Stock) AS TotalUnits,
    SUM(InventoryValue) AS TotalCapital,
    CAST(SUM(InventoryValue) * 100.0 / (SELECT SUM(InventoryValue) FROM dbo.Products) AS DECIMAL(5,2)) AS PctOfTotalCapital
FROM dbo.Products
GROUP BY
    CASE
        WHEN Availability IN ('out_of_stock', 'discontinued') THEN 'At-Risk Capital (OOS / Discontinued)'
        WHEN Availability IN ('backorder', 'limited_stock')   THEN 'Constrained Supply (Backorder / Limited)'
        ELSE 'Healthy / Pipeline (In Stock / Pre-Order)'
    END
ORDER BY TotalCapital DESC;

-- Q29: Category-Level Sellable Stock Rate (% of Units Currently In Stock)
SELECT
    Category,
    SUM(Stock) AS TotalCategoryUnits,
    SUM(CASE WHEN Availability = 'in_stock' THEN Stock ELSE 0 END) AS InStockUnits,
    CAST(SUM(CASE WHEN Availability = 'in_stock' THEN Stock ELSE 0 END) * 100.0 / NULLIF(SUM(Stock), 0) AS DECIMAL(5,2)) AS InStockUnitPct
FROM dbo.Products
GROUP BY Category
ORDER BY InStockUnitPct DESC, TotalCategoryUnits DESC;

-- Q30: Description Word Count & Text Length Profiling
SELECT
    AVG(LEN(Description)) AS AvgDescCharLength,
    MIN(LEN(Description)) AS MinDescCharLength,
    MAX(LEN(Description)) AS MaxDescCharLength,
    AVG(LEN(ProductName) - LEN(REPLACE(ProductName, ' ', '')) + 1) AS AvgProductNameWords
FROM dbo.Products;


/*==============================================================================
  SECTION 4: WINDOW FUNCTIONS, RANKING & ABC PARETO ANALYSIS (Q31 - Q40)
==============================================================================*/

-- Q31: Rank Products Within Each Category by Inventory Value (DENSE_RANK)
SELECT
    Category,
    ProductName,
    Price,
    Stock,
    InventoryValue,
    DENSE_RANK() OVER (PARTITION BY Category ORDER BY InventoryValue DESC) AS CategoryValueRank
FROM dbo.Products
ORDER BY Category, CategoryValueRank;

-- Q32: Top #1 Highest-Value Flagship SKU per Category (CTE + ROW_NUMBER)
WITH RankedSKUs AS (
    SELECT
        Category,
        ProductName,
        Brand,
        Price,
        Stock,
        InventoryValue,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY InventoryValue DESC) AS rn
    FROM dbo.Products
)
SELECT Category, ProductName, Brand, Price, Stock, InventoryValue
FROM RankedSKUs
WHERE rn = 1
ORDER BY InventoryValue DESC;

-- Q33: ABC Inventory Classification (Pareto 70/20/10 Cumulative Value Rule)
WITH CumulativeVal AS (
    SELECT
        ProductIndex,
        ProductName,
        Category,
        InventoryValue,
        SUM(InventoryValue) OVER (ORDER BY InventoryValue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal,
        SUM(InventoryValue) OVER () AS GrandTotal
    FROM dbo.Products
)
SELECT
    ProductIndex,
    ProductName,
    Category,
    InventoryValue,
    CAST(RunningTotal * 100.0 / GrandTotal AS DECIMAL(5,2)) AS CumulativePct,
    CASE
        WHEN RunningTotal * 100.0 / GrandTotal <= 70.0 THEN 'Class A (Top 70% Value)'
        WHEN RunningTotal * 100.0 / GrandTotal <= 90.0 THEN 'Class B (Next 20% Value)'
        ELSE 'Class C (Bottom 10% Value)'
    END AS ABC_Class
FROM CumulativeVal
ORDER BY InventoryValue DESC;

-- Q34: Price Quartile Distribution Using NTILE(4)
SELECT
    PriceQuartile,
    COUNT(*) AS SKUCount,
    MIN(Price) AS MinPrice,
    MAX(Price) AS MaxPrice,
    CAST(AVG(Price) AS DECIMAL(10,2)) AS AvgPrice
FROM (
    SELECT Price, NTILE(4) OVER (ORDER BY Price ASC) AS PriceQuartile
    FROM dbo.Products
) t
GROUP BY PriceQuartile
ORDER BY PriceQuartile;

-- Q35: SKU Price Comparison Against Its Own Category Average (Window AVG)
SELECT
    ProductName,
    Category,
    Price,
    CAST(AVG(Price) OVER (PARTITION BY Category) AS DECIMAL(10,2)) AS CategoryAvgPrice,
    CAST(Price - AVG(Price) OVER (PARTITION BY Category) AS DECIMAL(10,2)) AS DiffFromCatAvg
FROM dbo.Products
ORDER BY DiffFromCatAvg DESC;

-- Q36: Share of Category Inventory Value Contributed by Each SKU
SELECT
    Category,
    ProductName,
    InventoryValue,
    SUM(InventoryValue) OVER (PARTITION BY Category) AS CategoryTotalValue,
    CAST(InventoryValue * 100.0 / SUM(InventoryValue) OVER (PARTITION BY Category) AS DECIMAL(5,2)) AS PctOfCategoryValue
FROM dbo.Products
ORDER BY Category, PctOfCategoryValue DESC;

-- Q37: Price Gap Analysis Between Consecutive Products in Same Category (LAG)
SELECT
    Category,
    ProductName,
    Price,
    LAG(Price) OVER (PARTITION BY Category ORDER BY Price DESC) AS HigherPricedNeighbor,
    LAG(Price) OVER (PARTITION BY Category ORDER BY Price DESC) - Price AS PriceStepDown
FROM dbo.Products
ORDER BY Category, Price DESC;

-- Q38: Percentile Rank of Every Product by Inventory Value (PERCENT_RANK)
SELECT
    ProductIndex,
    ProductName,
    Category,
    InventoryValue,
    CAST(PERCENT_RANK() OVER (ORDER BY InventoryValue ASC) * 100 AS DECIMAL(5,2)) AS ValuePercentile
FROM dbo.Products
ORDER BY ValuePercentile DESC;

-- Q39: Median Price Calculation Across Catalog & Within Categories (PERCENTILE_CONT)
SELECT DISTINCT
    Category,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Price) OVER (PARTITION BY Category) AS DECIMAL(10,2)) AS CategoryMedianPrice,
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Price) OVER () AS DECIMAL(10,2)) AS GlobalMedianPrice
FROM dbo.Products
ORDER BY CategoryMedianPrice DESC;

-- Q40: Running Cumulative Stock Count Ordered by Price (Low to High)
SELECT
    ProductIndex,
    ProductName,
    Price,
    Stock,
    SUM(Stock) OVER (ORDER BY Price ASC, ProductIndex ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeStockUnits
FROM dbo.Products
ORDER BY Price ASC, ProductIndex ASC;


/*==============================================================================
  SECTION 5: ADVANCED T-SQL (CTEs, PIVOT, ROLLUP, VIEWS, SPs) (Q41 - Q50)
==============================================================================*/

-- Q41: Dynamic PIVOT — SKU Count Matrix (Category x Availability Status)
SELECT Category, [in_stock], [pre_order], [limited_stock], [backorder], [out_of_stock], [discontinued]
FROM (
    SELECT Category, Availability, ProductIndex
    FROM dbo.Products
) AS SourceTable
PIVOT (
    COUNT(ProductIndex)
    FOR Availability IN ([in_stock], [pre_order], [limited_stock], [backorder], [out_of_stock], [discontinued])
) AS PivotTable
ORDER BY Category;

-- Q42: Dynamic PIVOT — Inventory Capital Matrix (Price Tier x Availability)
WITH Tiered AS (
    SELECT
        CASE
            WHEN Price <= 200 THEN 'Budget'
            WHEN Price <= 500 THEN 'Mid-Range'
            WHEN Price <= 750 THEN 'Premium'
            ELSE 'Luxury'
        END AS PriceTier,
        Availability,
        InventoryValue
    FROM dbo.Products
)
SELECT PriceTier,
       ISNULL([in_stock], 0)      AS InStock_Val,
       ISNULL([pre_order], 0)     AS PreOrder_Val,
       ISNULL([limited_stock], 0) AS Limited_Val,
       ISNULL([backorder], 0)     AS Backorder_Val,
       ISNULL([out_of_stock], 0)  AS OOS_Val,
       ISNULL([discontinued], 0)  AS Discontinued_Val
FROM Tiered
PIVOT (
    SUM(InventoryValue)
    FOR Availability IN ([in_stock], [pre_order], [limited_stock], [backorder], [out_of_stock], [discontinued])
) AS p;

-- Q43: Hierarchical Subtotals & Grand Total Using GROUP BY ROLLUP
SELECT
    ISNULL(Category, 'ALL CATEGORIES (GRAND TOTAL)') AS Category,
    ISNULL(Availability, 'All Statuses (Subtotal)')  AS Availability,
    COUNT(*)                                         AS SKUCount,
    SUM(Stock)                                       AS TotalUnits,
    SUM(InventoryValue)                              AS TotalInventoryValue
FROM dbo.Products
GROUP BY ROLLUP (Category, Availability)
ORDER BY GROUPING(Category), Category, GROUPING(Availability), TotalInventoryValue DESC;

-- Q44: Statistical Price Outlier Detection (Z-Score Method: |Z| > 1.5)
WITH Stats AS (
    SELECT AVG(CAST(Price AS FLOAT)) AS MeanPrice, STDEV(CAST(Price AS FLOAT)) AS StdPrice
    FROM dbo.Products
)
SELECT
    p.ProductIndex,
    p.ProductName,
    p.Category,
    p.Price,
    CAST((p.Price - s.MeanPrice) / NULLIF(s.StdPrice, 0) AS DECIMAL(6,2)) AS PriceZScore
FROM dbo.Products p
CROSS JOIN Stats s
WHERE ABS((p.Price - s.MeanPrice) / NULLIF(s.StdPrice, 0)) > 1.5
ORDER BY PriceZScore DESC;

-- Q45: Multi-CTE Inventory Risk Scoring Engine (Composite Priority Score)
WITH RiskMetrics AS (
    SELECT
        ProductIndex,
        ProductName,
        Category,
        Price,
        Stock,
        InventoryValue,
        Availability,
        CASE
            WHEN Availability = 'out_of_stock' AND Stock > 0 THEN 100
            WHEN Availability = 'discontinued' AND Stock > 0 THEN 85
            WHEN Price < 50 THEN 75
            WHEN Availability = 'limited_stock' AND Stock < 250 THEN 60
            ELSE 10
        END AS RiskScore
    FROM dbo.Products
)
SELECT
    ProductIndex,
    ProductName,
    Category,
    Availability,
    InventoryValue,
    RiskScore,
    CASE
        WHEN RiskScore >= 85 THEN 'Critical Action Required'
        WHEN RiskScore >= 60 THEN 'Medium Priority Audit'
        ELSE 'Healthy'
    END AS ActionPriority
FROM RiskMetrics
WHERE RiskScore >= 60
ORDER BY RiskScore DESC, InventoryValue DESC;

-- Q46: Category Concentration Index (Top 5 Categories Share of Entire Portfolio)
WITH CatTotals AS (
    SELECT Category, SUM(InventoryValue) AS CatVal
    FROM dbo.Products
    GROUP BY Category
),
RankedCats AS (
    SELECT Category, CatVal,
           ROW_NUMBER() OVER (ORDER BY CatVal DESC) AS rn,
           SUM(CatVal) OVER () AS TotalPortfolioVal
    FROM CatTotals
)
SELECT
    CASE WHEN rn <= 5 THEN 'Top 5 Categories' ELSE 'Remaining 27 Categories' END AS PortfolioSegment,
    COUNT(*) AS CategoryCount,
    SUM(CatVal) AS SegmentValue,
    CAST(SUM(CatVal) * 100.0 / MAX(TotalPortfolioVal) AS DECIMAL(5,2)) AS SharePct
FROM RankedCats
GROUP BY CASE WHEN rn <= 5 THEN 'Top 5 Categories' ELSE 'Remaining 27 Categories' END;

-- Q47: Brand Word Complexity & Corporate Entity Type Classification
SELECT
    CASE
        WHEN Brand LIKE '%LLC%'   THEN 'LLC'
        WHEN Brand LIKE '%Inc%'   THEN 'Incorporated (Inc)'
        WHEN Brand LIKE '%Ltd%'   THEN 'Limited (Ltd)'
        WHEN Brand LIKE '%PLC%'   THEN 'Public Limited (PLC)'
        WHEN Brand LIKE '%Group%' THEN 'Group'
        WHEN Brand LIKE '%and%'   THEN 'Partnership'
        ELSE 'Independent / Other'
    END AS BrandEntityType,
    COUNT(*) AS SKUCount,
    SUM(InventoryValue) AS TotalInventoryValue
FROM dbo.Products
GROUP BY
    CASE
        WHEN Brand LIKE '%LLC%'   THEN 'LLC'
        WHEN Brand LIKE '%Inc%'   THEN 'Incorporated (Inc)'
        WHEN Brand LIKE '%Ltd%'   THEN 'Limited (Ltd)'
        WHEN Brand LIKE '%PLC%'   THEN 'Public Limited (PLC)'
        WHEN Brand LIKE '%Group%' THEN 'Group'
        WHEN Brand LIKE '%and%'   THEN 'Partnership'
        ELSE 'Independent / Other'
    END
ORDER BY SKUCount DESC;

-- Q48: Create Production Analytical View for Power BI DirectQuery / Import
GO
CREATE OR ALTER VIEW dbo.vw_PowerBI_ProductAnalytics AS
SELECT
    ProductIndex,
    ProductName,
    Brand,
    Category,
    Price,
    Stock,
    InventoryValue,
    Availability,
    Color,
    Size,
    InternalID,
    CASE
        WHEN Price <= 200 THEN 'Budget ($1-$200)'
        WHEN Price <= 500 THEN 'Mid-Range ($201-$500)'
        WHEN Price <= 750 THEN 'Premium ($501-$750)'
        ELSE 'Luxury ($751+)'
    END AS PriceTier,
    CASE
        WHEN Availability = 'out_of_stock' AND Stock > 0 THEN 'Sync Error (OOS w/ Stock)'
        WHEN Availability = 'discontinued' AND Stock > 0 THEN 'Liquidation Risk'
        WHEN Price < 50 THEN 'Pricing Audit'
        ELSE 'Normal'
    END AS RiskFlag
FROM dbo.Products;
GO

-- Q49: Create Parameterized Stored Procedure for Dynamic Category & Status Filtering
CREATE OR ALTER PROCEDURE dbo.usp_GetInventoryReport
    @Category     NVARCHAR(100) = NULL,
    @Availability VARCHAR(30)   = NULL,
    @MinPrice     DECIMAL(10,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ProductIndex,
        ProductName,
        Brand,
        Category,
        Price,
        Stock,
        InventoryValue,
        Availability
    FROM dbo.Products
    WHERE (@Category IS NULL OR Category = @Category)
      AND (@Availability IS NULL OR Availability = @Availability)
      AND Price >= @MinPrice
    ORDER BY InventoryValue DESC;
END;
GO
-- Example Execution:
-- EXEC dbo.usp_GetInventoryReport @Availability = 'out_of_stock', @MinPrice = 100;

-- Q50: Create Scalar Function for Reorder Urgency Classification
CREATE OR ALTER FUNCTION dbo.fn_GetReorderStatus (
    @Availability VARCHAR(30),
    @Stock        INT
)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE @Status VARCHAR(30);
    SET @Status = CASE
        WHEN @Availability = 'discontinued' THEN 'Do Not Reorder'
        WHEN @Availability = 'out_of_stock' THEN 'Urgent Sync Audit'
        WHEN @Availability IN ('backorder', 'limited_stock') AND @Stock < 300 THEN 'Immediate Reorder'
        WHEN @Stock < 200 THEN 'Low Stock Watch'
        ELSE 'Stock Sufficient'
    END;
    RETURN @Status;
END;
GO
-- Example Execution:
-- SELECT ProductName, Availability, Stock, dbo.fn_GetReorderStatus(Availability, Stock) AS ReorderAction FROM dbo.Products;
