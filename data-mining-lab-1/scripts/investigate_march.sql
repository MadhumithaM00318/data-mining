SELECT bill_no, SUM(qty*unit_price) AS bill_total
FROM fact_sales_line
WHERE is_revenue AND business_date BETWEEN DATE '2024-03-01' AND DATE '2024-03-31'
GROUP BY bill_no
ORDER BY bill_total DESC
LIMIT 15;