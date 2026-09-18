ATTACH 'dbname=annapurna host=localhost port=5432 user=admin password=admin123' AS pg (TYPE postgres);

-- which catalog does each table actually live in?
SELECT table_catalog, table_schema, table_name
FROM information_schema.tables
WHERE table_name IN ('fact_sales_line', 'fact_sales_raw', 'stores', 'products', 'price_revisions')
ORDER BY table_catalog, table_name;