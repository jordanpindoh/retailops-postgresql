\echo === Preparation : solde initial de 100 ===
CREATE TEMP TABLE transaction_demo (
    id INTEGER PRIMARY KEY,
    solde INTEGER NOT NULL CHECK (solde >= 0)
);
INSERT INTO transaction_demo VALUES (1, 100);

\echo === COMMIT : modification conservee ===
BEGIN;
UPDATE transaction_demo SET solde = solde - 20 WHERE id = 1;
COMMIT;
SELECT solde, solde = 80 AS commit_valide FROM transaction_demo;

\echo === ROLLBACK : modification annulee ===
BEGIN;
UPDATE transaction_demo SET solde = solde - 30 WHERE id = 1;
SELECT solde AS solde_pendant_transaction FROM transaction_demo;
ROLLBACK;
SELECT solde, solde = 80 AS rollback_valide FROM transaction_demo;

DROP TABLE transaction_demo;
