# MS SQL Server (T-SQL) Analytical Findings Summary

This document summarizes key verified outputs from executing `02_50_business_sql_queries.sql` against `EcommerceAnalyticsDB`.

## 1. Executive Catalog KPIs (Q01)
| Metric | Value |
| :--- | ---: |
| **Total SKUs** | 100 |
| **Unique Brands** | 100 |
| **Unique Categories** | 32 |
| **Total Stock Units** | 54,571 |
| **Total Inventory Value** | $24,452,583 |
| **Average Unit Price** | $451.19 |
| **Median Unit Price** | $407.50 |
| **Weighted Average Unit Price** | $448.09 |

## 2. Availability & Capital-at-Risk Breakdown (Q21 & Q28)
| Availability Status | SKU Count | % SKUs | Total Units | Avg Price | Total Inventory Value | % Capital |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| `in_stock` | 20 | 20.00% | 11,394 | $518.20 | $5,719,031 | 23.39% |
| `pre_order` | 25 | 25.00% | 12,966 | $350.44 | $4,792,856 | 19.60% |
| `backorder` | 16 | 16.00% | 8,566 | $446.38 | $3,948,248 | 16.15% |
| `limited_stock` | 17 | 17.00% | 8,914 | $446.18 | $3,779,042 | 15.45% |
| `out_of_stock` | 10 | 10.00% | 5,225 | $606.60 | $3,219,633 | 13.17% |
| `discontinued` | 12 | 12.00% | 7,506 | $433.42 | $2,993,773 | 12.24% |

## 3. Data Quality & ERP Audit Flags (Q03–Q08)
- **ERP Inventory Sync Failure (Q06):** 10 SKUs flagged as `out_of_stock` still report **5,225 physical units** totaling **$3,219,633** in trapped capital.
- **Liquidation Exposure (Q07):** 12 `discontinued` SKUs hold **7,506 units** worth **$2,993,773** requiring clearance or write-off strategy.
- **Duplicate Product Names (Q03):** `"Tablet"` appears twice (`Index 2` in Shoes & Footwear and `Index 53` in Beauty & Personal Care).
- **Non-Unique Internal IDs (Q04):** 24 `InternalID` values are shared across multiple distinct SKUs, indicating `InternalID` cannot be used as a primary key.
- **Pricing Outliers (Q08):** 5 SKUs are priced under $50 (lowest at $1 and $3), warranting pricing governance verification.
