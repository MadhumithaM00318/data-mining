ATTACH 'dbname=annapurna host=localhost port=5432 user=admin password=admin123' AS pg (TYPE postgres);

CREATE OR REPLACE VIEW v_priced_sales AS
SELECT
    f.bill_no, f.line_no, f.store_id, f.business_date,
    f.product_sk, f.qty, f.unit_price AS till_price,
    pr.selling_price AS asof_price,
    pr.effective_from, pr.effective_to
FROM fact_sales_line f
JOIN pg.price_revisions pr
  ON f.product_sk = pr.product_sk
 AND f.business_date BETWEEN pr.effective_from AND pr.effective_to
WHERE f.is_revenue;

-- run 1: March 2024
SELECT 'march_2024' AS period, count(*) AS lines, sum(qty*asof_price) AS revenue_at_asof_price
FROM v_priced_sales
WHERE business_date BETWEEN DATE '2024-03-01' AND DATE '2024-03-31';

-- run 2: a different month, SAME query shape, only the dates change
SELECT 'december_2024' AS period, count(*) AS lines, sum(qty*asof_price) AS revenue_at_asof_price
FROM v_priced_sales
WHERE business_date BETWEEN DATE '2024-12-01' AND DATE '2024-12-31';

-- proof till price and as-of price sometimes disagree (billing_notes says ~1 in 70 lines)
SELECT count(*) AS total_lines,
       count(*) FILTER (WHERE till_price != asof_price) AS mismatched_lines,
       count(*) FILTER (WHERE till_price != asof_price) * 1.0 / count(*) AS mismatch_rate
FROM v_priced_sales;