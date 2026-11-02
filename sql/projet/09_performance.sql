EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, ordered_at, status
FROM retail.orders
WHERE customer_id = 42
ORDER BY ordered_at DESC;
