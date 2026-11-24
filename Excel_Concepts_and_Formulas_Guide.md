# MS Excel Concepts & Formulas Reference Guide

The accompanying workbook `Ecommerce_Inventory_Analytics.xlsx` is a fully dynamic, formula-driven analytical model with **5 structured worksheets**, native Excel charts, conditional formatting, and interactive data validation.

## Workbook Architecture
1. **`Executive_Dashboard`**: Executive KPI cards, Availability Status matrix, Price Tier segmentation, Top 10 Categories summary, and embedded native Excel charts.
2. **`Cleaned_Data`**: All 100 product records enhanced with 7 live formula columns (`Inventory_Value`, `Price_Tier`, `Stock_Bucket`, `Risk_Flag`, `Price_Rank`, `Value_Rank`, `% of Total Value`).
3. **`Category_Analytics`**: Complete 32-category dynamic summary table (acting as a formula-driven Pivot Table) with color-scale conditional formatting and a Top Categories bar chart.
4. **`Risk_and_Data_Audit`**: Automated ERP anomaly detection summary (`out_of_stock` with stock, `discontinued` stock, `<$50` pricing outliers) + an **Interactive SKU Lookup Tool** powered by `INDEX/MATCH` and Data Validation dropdowns.
5. **`Excel_Formulas_Ref`**: In-workbook cheat sheet of every formula and business use case.

## Key Excel Concepts & Exact Formulas Used

| Excel Concept | Exact Formula Used in Workbook | Analytical Purpose |
| :--- | :--- | :--- |
| **Row-Level Valuation** | `=F2*H2` | Computes `Inventory_Value` (`Price * Stock`) for each SKU |
| **Weighted Average Price** | `=SUMPRODUCT(Cleaned_Data!F2:F101, Cleaned_Data!H2:H101)/SUM(Cleaned_Data!H2:H101)` | Calculates true stock-weighted unit price ($448.09) |
| **Conditional Aggregation** | `=SUMIFS(Cleaned_Data!$N$2:$N$101, Cleaned_Data!$L$2:$L$101, A11)` | Aggregates total capital per Availability status |
| **Multi-Criteria Counting** | `=COUNTIFS(Cleaned_Data!$L$2:$L$101, "out_of_stock", Cleaned_Data!$H$2:$H$101, ">0")` | Detects ERP sync anomaly (OOS items with physical stock) |
| **Conditional Averaging** | `=AVERAGEIF(Cleaned_Data!$E$2:$E$101, A5, Cleaned_Data!$F$2:$F$101)` | Computes average unit price for each of the 32 categories |
| **Nested Logical Bucketing** | `=IF(F2<=200,"Budget ($1-$200)",IF(F2<=500,"Mid-Range ($201-$500)",IF(F2<=750,"Premium ($501-$750)","Luxury ($751+)")))` | Assigns each SKU to a commercial Price Tier |
| **Compound Risk Flagging** | `=IF(AND(L2="out_of_stock",H2>0),"Sync Error",IF(AND(L2="discontinued",H2>0),"Liquidation Risk",IF(F2<50,"Price Audit","Normal")))` | Flags operational and pricing risks dynamically |
| **Dynamic Ranking** | `=RANK(N2, $N$2:$N$101, 0)` | Ranks every SKU from #1 to #100 by total inventory value |
| **Flexible Lookup** | `=INDEX(Cleaned_Data!$B$2:$B$101, MATCH($B$15, Cleaned_Data!$A$2:$A$101, 0))` | Powers interactive SKU Audit Lookup tool without VLOOKUP column limits |
| **Statistical Profiling** | `=MEDIAN(Cleaned_Data!F2:F101)` & `=STDEV.S(Cleaned_Data!F2:F101)` | Measures central tendency ($407.50) and price dispersion ($281.61) |
| **Data Validation** | Dropdown list on `Risk_and_Data_Audit!B15` (`Cleaned_Data!$A$2:$A$101`) | Enables interactive SKU selection for ad-hoc auditing |
| **Conditional Formatting** | Color Scales (Green-Yellow-Red) & Highlight Rules on Risk Flags | Visualizes high-value categories and alerts immediately |
