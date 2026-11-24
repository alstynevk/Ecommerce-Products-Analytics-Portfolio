# Power BI Architecture, Data Model & DAX Functions Guide

## 1. Star Schema Data Model Design
To optimize query performance and scalability in Power BI Desktop, the dataset is structured around a central fact table (`Fact_Products`) connected to normalized dimension tables and a dedicated Measure Table (`_Key_Measures`):

- **`Fact_Products`**: `ProductIndex` (PK), `Brand`, `Category`, `Price`, `Stock`, `Inventory Value`, `Availability`, `Color`, `Size`, `Internal ID`, `Price Tier`, `Risk Flag`.
- **`Dim_Category`** *(1-to-Many → Fact_Products[Category])*: Distinct categories with sort orders and category groupings.
- **`Dim_Availability`** *(1-to-Many → Fact_Products[Availability])*: Distinct availability statuses with display labels and severity rank.
- **`_Key_Measures`**: Dedicated measure container organizing 30+ DAX calculations into display folders (`01_Core_KPIs`, `02_Risk_Audit`, `03_Ranking_Pareto`, `04_Dynamic_UI`).

## 2. Core Power BI Functions Used
| Function Category | DAX / M Functions Used | Business Application |
| :--- | :--- | :--- |
| **Iterators & Aggregators** | `SUMX`, `SUM`, `AVERAGE`, `MEDIAN`, `STDEV.S`, `COUNTROWS`, `DISTINCTCOUNT` | Computing row-level `Price * Stock` total capital without bloating model memory |
| **Filter Context Modifiers** | `CALCULATE`, `FILTER`, `ALL`, `ALLSELECTED`, `ALLEXCEPT`, `IN` | Isolating At-Risk Capital (`out_of_stock` + `discontinued`), calculating % of Total & % of Category |
| **Ranking & Pareto** | `RANKX`, `TOPN`, `DIVIDE` | Ranking all 32 categories, isolating Top 5 Categories Share %, and building cumulative ABC Pareto curves |
| **Conditional Logic & UI** | `SWITCH(TRUE(), ...)`, `SELECTEDVALUE`, `VAR / RETURN` | Dynamic chart titles, conditional hex-color alerts (`#D93025` / `#F9AB00` / `#188038`), Price Tier bucketing |
| **Power Query (M)** | `Csv.Document`, `Table.PromoteHeaders`, `Table.TransformColumnTypes`, `Table.AddColumn`, `Text.Proper`, `Text.Replace` | Automated, repeatable ETL pipeline preserving 13-digit EAN barcodes as text |

## 3. Report Pages & Visual Layout
1. **Page 1 — Executive Inventory Overview** (`screenshots/05_powerbi_executive_overview.png`):
   - **KPI Banner**: Total Inventory Value ($24.45M), Total Stock Units (54,571), Total SKUs (100), Weighted Avg Price ($448.09), At-Risk Capital ($6.21M / 25.4%).
   - **Top 10 Categories by Inventory Value**: Horizontal clustered bar chart.
   - **Capital Share by Availability Status**: Donut chart highlighting `in_stock` (23.4%) vs. `out_of_stock` (13.2%) & `discontinued` (12.2%).
   - **Price Tier Value & SKU Distribution**: Clustered bar/column chart showing Luxury ($751+) driving 35.6% of total capital from just 18 SKUs.
2. **Page 2 — Inventory Risk & Pricing Analytics** (`screenshots/06_powerbi_inventory_risk_pricing.png`):
   - **Price vs. Stock Scatter Plot**: Color-coded by Availability to instantly expose high-price, high-stock `out_of_stock` and `discontinued` anomalies.
   - **ABC Pareto Curve**: Cumulative value contribution across ranked SKUs (35 Class A SKUs = 70% of total value).
   - **Capital-at-Risk Breakdown**: Horizontal bar comparison of Healthy vs. Constrained vs. At-Risk capital.
   - **Top Priority Risk Action Table**: Conditional formatted table flagging exact SKUs needing ERP sync fixes or liquidation.
