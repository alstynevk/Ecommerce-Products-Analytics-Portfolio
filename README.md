# E-Commerce Product & Inventory Analytics Portfolio

![SQL Server](https://img.shields.io/badge/MS%20SQL%20Server-T--SQL-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Microsoft Excel](https://img.shields.io/badge/Microsoft%20Excel-Formulas%20%26%20Dashboards-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-DAX%20%26%20Power%20Query-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Status](https://img.shields.io/badge/Portfolio-Production%20Ready-0078D4?style=for-the-badge)

## Project Overview
An end-to-end **Data Analytics Portfolio Project** examining an e-commerce product catalog (`100 SKUs`, `32 Categories`, `100 Brands`, `54,571 Units`, **$24.45M Total Inventory Capital**). Built across the complete Microsoft BI stack — **MS SQL Server (T-SQL)**, **MS Excel**, and **Microsoft Power BI** — to uncover inventory valuation drivers, pricing anomalies, ERP synchronization failures, and Pareto (ABC) capital concentration.

---

## Executive KPI Snapshot
| KPI Metric | Verified Value | Business Context |
| :--- | ---: | :--- |
| **Total Inventory Value** | **$24,452,583** | Combined capital tied across 54,571 physical units |
| **Total Catalog SKUs** | **100 SKUs** | Spanning 32 product categories & 100 unique brands |
| **Average / Median Price** | **$451.19 / $407.50** | Stock-weighted average price sits at **$448.09** |
| **At-Risk Inventory Capital** | **$6,213,406 (25.41%)** | Combined `out_of_stock` sync errors + `discontinued` dead stock |
| **Class A SKUs (Pareto 70%)** | **35 SKUs** | Top 35% of SKUs drive 70% of total inventory capital |

---

## Key Business Findings & Recommendations
1. **Critical ERP-to-Storefront Sync Failure ($3.22M Trapped Capital):** 100% of `out_of_stock` SKUs (10 products) still hold **5,225 physical units** worth **$3,219,633** (13.17% of total value). *Action:* Trigger an immediate warehouse-to-storefront inventory reconciliation to unlock blocked revenue.
2. **Discontinued Inventory Liquidation Exposure ($2.99M Dead Capital):** 12 `discontinued` SKUs retain **7,506 units** valued at **$2,993,773** (12.24% of capital). *Action:* Launch targeted B2B clearance or bundling campaigns to recover working capital.
3. **Luxury Tier Capital Concentration:** The **Luxury ($751+)** segment comprises only **18% of SKUs** (18 items) yet accounts for **35.58% ($8.70M)** of total inventory value.
4. **Master Data Governance Gaps:** 24 `Internal ID` values are shared across multiple distinct SKUs, 2 distinct products share the exact name `"Tablet"`, and 5 SKUs are priced under $50 (down to $1 and $3) requiring immediate pricing audit.

---

## Repository Structure
```text
Ecommerce-Products-Analytics-Portfolio/
├── README.md                                  # Executive project overview & visual showcase
├── LICENSE                                    # MIT License
├── data/
│   ├── raw/ecommerce_products.csv             # Original source dataset
│   └── processed/ecommerce_products_cleaned.csv # Enriched dataset with ABC & Risk flags
├── sql/
│   ├── 01_database_schema_and_setup.sql       # MS SQL Server DDL, Indexes & BULK INSERT
│   ├── 02_50_business_sql_queries.sql         # 50 T-SQL queries (Profiling → Window Functions → SPs)
│   └── sql_query_results_summary.md           # Verified SQL output summary
├── excel/
│   ├── Ecommerce_Inventory_Analytics.xlsx     # 5-tab formula-driven Excel workbook with charts
│   └── Excel_Concepts_and_Formulas_Guide.md   # Complete Excel concepts & formula documentation
├── powerbi/
│   ├── DAX_Measures_and_Calculations.dax      # 30+ production DAX measures & calculated columns
│   ├── Power_Query_M_Transformations.pq       # Repeatable Power Query M ETL script
│   └── PowerBI_Dashboard_Architecture.md      # Star schema & visual design documentation
└── screenshots/
    ├── 01_sql_ssms_inventory_valuation.png
    ├── 02_sql_ssms_window_functions.png
    ├── 03_excel_executive_dashboard.png
    ├── 04_excel_category_pivot_analysis.png
    ├── 05_powerbi_executive_overview.png
    └── 06_powerbi_inventory_risk_pricing.png
```

---

## Visual Showcase

### 1. MS SQL Server (SSMS) — 50 Production T-SQL Queries
- Covers Data Profiling, Quality Audits, Aggregations, Window Functions (`DENSE_RANK`, `ROW_NUMBER`, `NTILE`, `PERCENT_RANK`, `PERCENTILE_CONT`, `LAG`), `PIVOT`, `ROLLUP`, Z-Score Outlier Detection, Analytical Views, Stored Procedures, and Scalar Functions.

![SQL SSMS Inventory Valuation](screenshots/01_sql_ssms_inventory_valuation.png)
![SQL SSMS Window Functions](screenshots/02_sql_ssms_window_functions.png)

### 2. MS Excel — Interactive Formula-Driven Dashboard & Audit Workbook
- Built with `SUMIFS`, `COUNTIFS`, `AVERAGEIF`, `SUMPRODUCT`, `INDEX/MATCH`, `RANK`, nested `IF/AND`, Conditional Formatting, Data Validation dropdowns, and native Excel charts.

![Excel Executive Dashboard](screenshots/03_excel_executive_dashboard.png)
![Excel Category Pivot Analysis](screenshots/04_excel_category_pivot_analysis.png)

### 3. Microsoft Power BI — Executive & Risk Analytics Dashboards
- Powered by a Star Schema model, Power Query M transformations, and 30+ DAX measures (`SUMX`, `CALCULATE`, `RANKX`, `TOPN`, `ALLSELECTED`, `SWITCH`).

![Power BI Executive Overview](screenshots/05_powerbi_executive_overview.png)
![Power BI Inventory Risk and Pricing](screenshots/06_powerbi_inventory_risk_pricing.png)

---

## How to Use / Upload to GitHub
```bash
git init
git add .
git commit -m "Initial commit: E-Commerce Product & Inventory Analytics Portfolio (SQL, Excel, Power BI)"
git branch -M main
git remote add origin https://github.com/<your-username>/Ecommerce-Products-Analytics-Portfolio.git
git push -u origin main
```
