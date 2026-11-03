\set ON_ERROR_STOP on

SELECT current_user;

BEGIN;

INSERT INTO retail.orders (customer_id, ordered_at, status, channel)
VALUES (1, CURRENT_TIMESTAMP, 'pending', 'web')
RETURNING order_id AS nouvelle_commande \gset

INSERT INTO retail.order_items (order_id, product_id, quantity, unit_price)
VALUES (:nouvelle_commande, 1, 2, 10.00)
RETURNING item_id, order_id, product_id, quantity, unit_price;

SELECT COUNT(*) = 1 AS commande_creee
FROM retail.orders
WHERE order_id = :nouvelle_commande;

SELECT COUNT(*) = 1 AS ligne_creee
FROM retail.order_items
WHERE order_id = :nouvelle_commande;

ROLLBACK;

SELECT COUNT(*) = 0 AS commande_annulee
FROM retail.orders
WHERE order_id = :nouvelle_commande;

SELECT COUNT(*) = 0 AS ligne_annulee
FROM retail.order_items
WHERE order_id = :nouvelle_commande;
