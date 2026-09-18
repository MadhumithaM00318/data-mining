-- how many bills exist, and what's the average rounding delta needed per bill
-- to see if this is just float precision noise vs a real systematic difference
WITH bill_totals AS (
  SELECT bill_no, SUM(qty*unit_price) AS bill_total
  FROM fact_sales_line
  WHERE is_revenue AND business_date BETWEEN DATE '2024-12-01' AND DATE '2024-12-31'
  GROUP BY bill_no
)
SELECT count(*) AS n_bills,
       SUM(bill_total - ROUND(bill_total,0)) AS sum_of_fractional_parts
FROM bill_totals;