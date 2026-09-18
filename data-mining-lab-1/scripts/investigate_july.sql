-- does S07 have gaps in July that other stores don't?
SELECT store_id, count(DISTINCT business_date) AS days_present
FROM fact_sales_line
WHERE business_date BETWEEN DATE '2024-07-01' AND DATE '2024-07-31'
GROUP BY store_id
ORDER BY store_id;

-- which specific July dates does S07 have vs. a full month
WITH all_days AS (
  SELECT unnest(generate_series(DATE '2024-07-01', DATE '2024-07-31', INTERVAL 1 DAY)) AS d
)
SELECT a.d AS missing_date
FROM all_days a
LEFT JOIN (SELECT DISTINCT business_date FROM fact_sales_line WHERE store_id = 'S07') s
  ON a.d = s.business_date
WHERE s.business_date IS NULL AND a.d BETWEEN DATE '2024-07-01' AND DATE '2024-07-31';