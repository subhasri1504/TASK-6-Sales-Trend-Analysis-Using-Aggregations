-- task6_mysql.sql
-- SQL script to reproduce Task 6: Sales Trend Analysis (MySQL)

CREATE DATABASE IF NOT EXISTS task6 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE task6;

-- Raw lines table (schema for Online Retail dataset)
CREATE TABLE IF NOT EXISTS raw_lines (
  InvoiceNo VARCHAR(30),
  StockCode VARCHAR(50),
  Description TEXT,
  Quantity INT,
  InvoiceDate VARCHAR(100),
  UnitPrice DECIMAL(12,4),
  CustomerID VARCHAR(50),
  Country VARCHAR(100)
);

-- After importing Online Retail.csv into raw_lines (via LOAD DATA or Workbench Import),
-- convert InvoiceDate to DATETIME and aggregate to orders:

ALTER TABLE raw_lines ADD COLUMN IF NOT EXISTS invoice_dt DATETIME NULL;

-- Example conversion (adjust format if needed):
UPDATE raw_lines
SET invoice_dt = STR_TO_DATE(InvoiceDate, '%d/%m/%Y %H:%i')
WHERE invoice_dt IS NULL;

-- Aggregate to orders (exclude returns / credit notes)
DROP TABLE IF EXISTS orders;
CREATE TABLE orders AS
SELECT
  InvoiceNo AS order_id,
  DATE(invoice_dt) AS order_date,
  SUM(Quantity * UnitPrice) AS amount
FROM raw_lines
WHERE invoice_dt IS NOT NULL
  AND Quantity > 0
  AND InvoiceNo NOT LIKE 'C%'
GROUP BY InvoiceNo, DATE(invoice_dt);

ALTER TABLE orders ADD INDEX idx_order_date (order_date);

-- Monthly trend query
SELECT
  YEAR(order_date) AS year,
  MONTH(order_date) AS month,
  ROUND(SUM(amount),2) AS monthly_revenue,
  COUNT(DISTINCT order_id) AS order_volume
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

-- Top 3 months by revenue
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(amount) AS monthly_revenue
FROM orders
GROUP BY year, month
ORDER BY monthly_revenue DESC
LIMIT 3;
