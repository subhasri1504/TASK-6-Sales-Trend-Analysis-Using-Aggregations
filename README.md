# Task 6 — Sales Trend Analysis (MySQL Workbench)

**Dataset:** Online Retail.csv (timeframe: Dec 2010 — Dec 2011)

## Objective
Compute monthly revenue and order volume, and identify the top 3 months by revenue.

## Files included
- `task6_mysql.sql` — SQL script to reproduce the steps in MySQL.
- `monthly_sales.csv` — Monthly revenue & order volume (Dec 2010 — Dec 2011).
- `top3_months.csv` — Top 3 months by revenue.
- `Task6_MySQL_Workbench.pdf` — Step-by-step screenshots and README.

## How to reproduce (MySQL Workbench)
1. Create database:
   ```sql
   CREATE DATABASE task6;
   USE task6;
   ```
2. Create `raw_lines` table (see `task6_mysql.sql` for schema).
3. Import `Online Retail.csv` using **Table Data Import Wizard** into `raw_lines`.
4. Convert `InvoiceDate` to `DATETIME`:
   ```sql
   ALTER TABLE raw_lines ADD COLUMN invoice_dt DATETIME;
   UPDATE raw_lines SET invoice_dt = STR_TO_DATE(InvoiceDate, '%d/%m/%Y %H:%i');
   ```
5. Aggregate to `orders` table (exclude returns):
   ```sql
   CREATE TABLE orders AS
   SELECT InvoiceNo AS order_id, DATE(invoice_dt) AS order_date, SUM(Quantity*UnitPrice) AS amount
   FROM raw_lines
   WHERE Quantity > 0 AND InvoiceNo NOT LIKE 'C%'
   GROUP BY InvoiceNo, DATE(invoice_dt);
   ```
6. Run monthly trend query (see `task6_mysql.sql`).
7. Export results from the result grid (right-click → Export Resultset to CSV).

## Notes
- Adjust `STR_TO_DATE` format if your `InvoiceDate` uses a different pattern.
- Excluding returns is optional; the script above excludes negative Quantity and invoice numbers starting with 'C'.

Generated on: 2025-08-12 13:54 UTC
