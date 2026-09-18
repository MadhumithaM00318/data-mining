-- your computed monthly net revenue
CREATE OR REPLACE VIEW my_monthly AS
SELECT strftime(business_date, '%Y-%m') AS month,
       SUM(qty * unit_price) AS my_revenue
FROM fact_sales_line
WHERE is_revenue
GROUP BY 1
ORDER BY 1;

SELECT * FROM my_monthly;

-- finance's numbers, read straight from the CSV
SELECT * FROM read_csv_auto('raw/finance_monthly.csv');

-- the actual diff, side by side
SELECT m.month, m.my_revenue, f.revenue_inr,
       round(m.my_revenue - f.revenue_inr, 2) AS diff,
       round((m.my_revenue - f.revenue_inr) / f.revenue_inr * 100, 3) AS pct_diff
FROM my_monthly m
JOIN read_csv_auto('raw/finance_monthly.csv') f
  ON m.month = f.month
ORDER BY m.month;