SELECT
  SUM(qty*unit_price) AS raw_revenue,
  SUM(ROUND(qty*unit_price, 0)) AS rounded_per_line,
  50745209.0 AS finance_figure
FROM fact_sales_line
WHERE is_revenue AND business_date BETWEEN DATE '2024-12-01' AND DATE '2024-12-31';