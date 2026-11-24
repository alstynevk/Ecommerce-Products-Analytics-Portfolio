/*==============================================================================
  PROJECT:  E-Commerce Product & Inventory Analytics Portfolio
  TOOL:     Power BI Power Query Editor (M Language)
  FILE:     Power_Query_M_Transformations.pq
  PURPOSE:  Automated ETL: Load, Type Enforcement, EAN Formatting, Enrichment
==============================================================================*/

let
    // 1. Ingest Raw CSV
    Source = Csv.Document(
        File.Contents("C:\Portfolio\Ecommerce-Products-Analytics-Portfolio\data\raw\ecommerce_products.csv"),
        [Delimiter=",", Columns=13, Encoding=65001, QuoteStyle=QuoteStyle.None]
    ),
    PromotedHeaders = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),

    // 2. Enforce Strict Data Types (Keep EAN as Text to prevent scientific notation)
    ChangedTypes = Table.TransformColumnTypes(PromotedHeaders, {
        {"Index", Int64.Type},
        {"Name", type text},
        {"Description", type text},
        {"Brand", type text},
        {"Category", type text},
        {"Price", Currency.Type},
        {"Currency", type text},
        {"Stock", Int64.Type},
        {"EAN", type text},
        {"Color", type text},
        {"Size", type text},
        {"Availability", type text},
        {"Internal ID", Int64.Type}
    }),

    // 3. Clean Whitespace on Text Fields
    TrimmedText = Table.TransformColumns(ChangedTypes, {
        {"Name", Text.Trim, type text},
        {"Brand", Text.Trim, type text},
        {"Category", Text.Trim, type text},
        {"Availability", Text.Trim, type text}
    }),

    // 4. Add Inventory Value Column (Price * Stock)
    AddInventoryValue = Table.AddColumn(
        TrimmedText,
        "Inventory Value",
        each [Price] * [Stock],
        Currency.Type
    ),

    // 5. Add Clean Availability Display Label
    AddAvailabilityLabel = Table.AddColumn(
        AddInventoryValue,
        "Availability Label",
        each Text.Proper(Text.Replace([Availability], "_", " ")),
        type text
    ),

    // 6. Add Price Tier Column
    AddPriceTier = Table.AddColumn(
        AddAvailabilityLabel,
        "Price Tier",
        each if [Price] <= 200 then "1. Budget ($1-$200)"
             else if [Price] <= 500 then "2. Mid-Range ($201-$500)"
             else if [Price] <= 750 then "3. Premium ($501-$750)"
             else "4. Luxury ($751+)",
        type text
    ),

    // 7. Add Inventory Risk Flag
    AddRiskFlag = Table.AddColumn(
        AddPriceTier,
        "Risk Flag",
        each if [Availability] = "out_of_stock" and [Stock] > 0 then "Sync Error: OOS w/ Stock"
             else if [Availability] = "discontinued" and [Stock] > 0 then "Liquidation Risk"
             else if [Price] < 50 then "Pricing Audit (<$50)"
             else "Normal",
        type text
    )
in
    AddRiskFlag
