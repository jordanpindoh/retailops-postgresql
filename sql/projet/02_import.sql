BEGIN;

\copy retail.customers(customer_id, full_name, email, region, created_at) FROM '/data/customers.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy retail.products(product_id, sku, label, category, list_price, active) FROM '/data/products.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy retail.orders(order_id, customer_id, ordered_at, status, channel) FROM '/data/orders.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy retail.order_items(item_id, order_id, product_id, quantity, unit_price) FROM '/data/order_items.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

SELECT setval(pg_get_serial_sequence('retail.customers', 'customer_id'),
              (SELECT MAX(customer_id) FROM retail.customers));
SELECT setval(pg_get_serial_sequence('retail.products', 'product_id'),
              (SELECT MAX(product_id) FROM retail.products));
SELECT setval(pg_get_serial_sequence('retail.orders', 'order_id'),
              (SELECT MAX(order_id) FROM retail.orders));
SELECT setval(pg_get_serial_sequence('retail.order_items', 'item_id'),
              (SELECT MAX(item_id) FROM retail.order_items));

COMMIT;

ANALYZE retail.customers;
ANALYZE retail.products;
ANALYZE retail.orders;
ANALYZE retail.order_items;

SELECT 'customers' AS table_name, COUNT(*) AS lignes FROM retail.customers
UNION ALL
SELECT 'products', COUNT(*) FROM retail.products
UNION ALL
SELECT 'orders', COUNT(*) FROM retail.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM retail.order_items;
