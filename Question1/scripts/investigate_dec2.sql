-- round each BILL's total to the nearest rupee, then sum
WITH bill_totals AS (
  SELECT bill_no, SUM(qty*unit_price) AS bill_total
  FROM fact_sales_line
  WHERE is_revenue AND business_date BETWEEN DATE '2024-12-01' AND DATE '2024-12-31'
  GROUP BY bill_no
)
SELECT
  SUM(bill_total) AS raw_revenue,
  SUM(ROUND(bill_total, 0)) AS rounded_per_bill,
  50745209.0 AS finance_figure,
  SUM(ROUND(bill_total, 0)) - 50745209.0 AS remaining_diff
FROM bill_totals;