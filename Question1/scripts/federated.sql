ATTACH 'dbname=annapurna host=localhost port=5432 user=admin password=admin123' AS pg (TYPE postgres);

EXPLAIN ANALYZE
SELECT s.store_name, s.city,
       SUM(f.qty * f.unit_price) AS revenue
FROM fact_sales_line f
JOIN pg.stores s ON f.store_id = s.store_id
WHERE f.is_revenue
GROUP BY s.store_name, s.city
ORDER BY revenue DESC;