\echo === Analyste : lecture autorisee ===
SET ROLE analyst_login;
SELECT current_user, COUNT(*) FROM retail.orders;

\echo === Analyste : modification refusee attendue ===
BEGIN;
UPDATE retail.orders SET status = 'paid' WHERE order_id = 1;
ROLLBACK;
RESET ROLE;

\echo === Application : modification autorisee ===
SET ROLE app_login;
BEGIN;
UPDATE retail.orders
SET status = 'paid'
WHERE order_id = 1
RETURNING order_id, status;
ROLLBACK;
RESET ROLE;
