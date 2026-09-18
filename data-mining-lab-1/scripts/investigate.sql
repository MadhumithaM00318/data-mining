ATTACH 'dbname=annapurna host=localhost port=5432 user=admin password=admin123' AS pg (TYPE postgres);

SELECT f.line_type, count(*) AS n
FROM fact_sales_line f
WHERE f.product_sk IS NULL
GROUP BY f.line_type
ORDER BY n DESC;

SELECT DISTINCT f.line_type, fr.product_code
FROM fact_sales_line f
JOIN fact_sales_raw fr ON f.bill_no = fr.bill_no AND f.line_no = fr.line_no
WHERE f.product_sk IS NULL
LIMIT 30;

SELECT DISTINCT fr.product_code
FROM fact_sales_raw fr
WHERE fr.product_code NOT IN (SELECT product_code FROM pg.products) AND fr.product_code != 'DISC'
LIMIT 30;