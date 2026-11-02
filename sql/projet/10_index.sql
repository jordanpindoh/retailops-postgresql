CREATE INDEX idx_orders_customer_date
ON retail.orders (customer_id, ordered_at DESC);

ANALYZE retail.orders;
