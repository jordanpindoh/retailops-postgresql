SELECT 'Doublons clients' AS controle,
       COUNT(*) - COUNT(DISTINCT customer_id) AS anomalies
FROM retail.customers
UNION ALL
SELECT 'Doublons produits',
       COUNT(*) - COUNT(DISTINCT product_id)
FROM retail.products
UNION ALL
SELECT 'Doublons commandes',
       COUNT(*) - COUNT(DISTINCT order_id)
FROM retail.orders
UNION ALL
SELECT 'Doublons lignes de commande',
       COUNT(*) - COUNT(DISTINCT item_id)
FROM retail.order_items
UNION ALL
SELECT 'Commandes sans client valide', COUNT(*)
FROM retail.orders o
LEFT JOIN retail.customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'Lignes sans commande valide', COUNT(*)
FROM retail.order_items i
LEFT JOIN retail.orders o ON o.order_id = i.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'Lignes sans produit valide', COUNT(*)
FROM retail.order_items i
LEFT JOIN retail.products p ON p.product_id = i.product_id
WHERE p.product_id IS NULL;
