# Démonstration de blocage entre deux sessions

## Observation réalisée
Deux transactions ont tenté de modifier la commande 1.
La session A détenait le verrou ; la session B attendait sa libération.

Résultats relevés pendant le test :
- Session A : PID 3309.
- Session B : PID 3403.
- pg_blocking_pids(3403) : {3309}.
- Attente de B : wait_event_type = Lock ; wait_event = transactionid.
- Transaction 813 : ExclusiveLock accordé à A ; ShareLock non accordé à B.

Ces identifiants correspondent au test effectué et changeront à chaque essai.
Il s'agit d'une attente de verrou, pas d'un deadlock : aucune attente circulaire
n'a été observée.

Preuve brute : evidence/preuve_blocage.txt, capture du 3 novembre 2026 à
13:33:09 UTC. Une ancienne session A, PID 1300, est idle et ne bloque rien.
La libération du verrou a été effectuée interactivement ; elle ne figure
pas dans cette capture de l’attente.

## Reproduction
Ouvrir deux onglets du Terminal. Dans chacun, depuis le dossier du projet :
docker compose exec db psql -U postgres -d retail_admin

### Session A
SET application_name = 'retailops_session_A';
BEGIN;
UPDATE retail.orders SET status = 'paid' WHERE order_id = 1;

Laisser la transaction ouverte.

### Session B
SET application_name = 'retailops_session_B';
BEGIN;
UPDATE retail.orders SET status = 'pending' WHERE order_id = 1;

L'UPDATE reste en attente.

### Diagnostic dans A
SELECT pid, application_name, state, wait_event_type, wait_event,
       pg_blocking_pids(pid) AS bloque_par
FROM pg_stat_activity
WHERE application_name IN ('retailops_session_A', 'retailops_session_B');

SELECT a.application_name, l.locktype, l.mode, l.granted, l.transactionid
FROM pg_locks l
JOIN pg_stat_activity a ON a.pid = l.pid
WHERE a.application_name IN ('retailops_session_A', 'retailops_session_B')
ORDER BY a.application_name, l.granted, l.locktype;

### Résolution
Dans A : ROLLBACK;
L'UPDATE de B se termine alors avec UPDATE 1.
Dans B : ROLLBACK;

Les deux modifications sont annulées.
Terminer les deux connexions avec \q.

## Prévention
Garder les transactions courtes et toujours terminer par COMMIT ou ROLLBACK.
Un lock_timeout adapté peut limiter l'attente, mais ne résout pas sa cause.
Identifier le bloqueur avant toute intervention sur une session.
