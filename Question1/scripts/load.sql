-- ===== connect to Postgres live, no copying =====
INSTALL postgres;
LOAD postgres;
ATTACH 'dbname=annapurna host=localhost port=5432 user=admin password=admin123' AS pg (TYPE postgres);

-- ===== dialect 1: S01-S05, comma, ISO timestamps =====
CREATE OR REPLACE VIEW raw_s01_05 AS
SELECT bill_no, line_no, product_code, qty, unit_price, line_type,
       ts::TIMESTAMP AS ts,
       regexp_extract(filename, 'SALES_(S\d+)_', 1) AS store_id,
       regexp_extract(filename, '_(\d{8})', 1) AS business_date_str
FROM read_csv('processed/sales/store_id=S0[1-5]/*/*/SALES_*.csv',
    columns={'bill_no':'VARCHAR','line_no':'INTEGER','product_code':'VARCHAR',
             'qty':'INTEGER','unit_price':'DOUBLE','line_type':'VARCHAR','ts':'VARCHAR'},
    header=true, delim=',', filename=true);

-- ===== dialect 2: S06-S09, semicolon, dd-mm-yyyy =====
CREATE OR REPLACE VIEW raw_s06_09 AS
SELECT bill_no, line_no, item_code AS product_code, quantity AS qty,
       rate AS unit_price, type AS line_type,
       strptime(txn_time, '%d-%m-%Y %H:%M:%S') AS ts,
       regexp_extract(filename, 'SALES_(S\d+)_', 1) AS store_id,
       regexp_extract(filename, '_(\d{8})', 1) AS business_date_str
FROM read_csv('processed/sales/store_id=S0[6-9]/*/*/SALES_*.csv',
    columns={'bill_no':'VARCHAR','line_no':'INTEGER','item_code':'VARCHAR',
             'quantity':'INTEGER','rate':'DOUBLE','type':'VARCHAR','txn_time':'VARCHAR'},
    header=true, delim=';', filename=true);

-- ===== dialect 3: S10-S12, BOM + epoch seconds, reordered columns =====
CREATE OR REPLACE VIEW raw_s10_12 AS
SELECT bill_no, line_no, product_code, qty, unit_price, line_type,
       to_timestamp(ts) AS ts,
       regexp_extract(filename, 'SALES_(S\d+)_', 1) AS store_id,
       regexp_extract(filename, '_(\d{8})', 1) AS business_date_str
FROM read_csv('processed/sales/store_id=S1[0-2]/*/*/SALES_*.csv',
    columns={'ts':'BIGINT','bill_no':'VARCHAR','line_no':'INTEGER','line_type':'VARCHAR',
             'product_code':'VARCHAR','unit_price':'DOUBLE','qty':'INTEGER'},
    header=true, delim=',', filename=true);

-- ===== union all three dialects =====
CREATE OR REPLACE VIEW raw_sales_all AS
SELECT * FROM raw_s01_05
UNION ALL BY NAME SELECT * FROM raw_s06_09
UNION ALL BY NAME SELECT * FROM raw_s10_12;

-- ===== idempotent dedup: safe unit is (bill_no, line_no) =====
CREATE OR REPLACE TABLE fact_sales_raw AS
SELECT
    bill_no, line_no, store_id,
    strptime(business_date_str, '%Y%m%d')::DATE AS business_date,
    product_code, qty, unit_price, line_type, ts
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY bill_no, line_no
               ORDER BY store_id, business_date_str, product_code,
                        qty, unit_price, line_type, ts
           ) AS rn
    FROM raw_sales_all
)
WHERE rn = 1;

-- ===== resolve product identity as-of the sale date, build the fact table =====
CREATE OR REPLACE TABLE fact_sales_line AS
SELECT
    f.bill_no, f.line_no, f.store_id, f.business_date,
    f.qty, f.unit_price, f.line_type,
    p.product_sk, p.category_id,
    (f.line_type IN ('SALE','RETURN','DISCOUNT','VOID')) AS is_revenue
FROM fact_sales_raw f
LEFT JOIN pg.products p
  ON f.product_code = p.product_code
 AND f.business_date BETWEEN p.valid_from AND p.valid_to
WHERE f.line_type NOT IN ('TAX','TENDER');

-- ===== sanity output =====
SELECT count(*) AS row_count FROM fact_sales_raw;
SELECT count(*) AS fact_row_count FROM fact_sales_line;
SELECT count(*) AS unresolved_products FROM fact_sales_line WHERE product_sk IS NULL;