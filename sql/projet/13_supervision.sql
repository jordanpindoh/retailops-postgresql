-- Connexions et transactions
SELECT datname, numbackends, xact_commit, xact_rollback, deadlocks
FROM pg_stat_database
WHERE datname = current_database();

-- Sessions bloquees
SELECT pid, usename, application_name,
       clock_timestamp() - query_start AS duree_requete,
       wait_event_type, wait_event,
       pg_blocking_pids(pid) AS bloque_par
FROM pg_stat_activity
WHERE datname = current_database()
  AND cardinality(pg_blocking_pids(pid)) > 0;

-- Taille de la base
SELECT pg_size_pretty(pg_database_size(current_database()))
       AS taille_base;

-- Maintenance : compteurs estimes
SELECT relname, n_live_tup, n_dead_tup,
       last_autovacuum, last_autoanalyze, last_analyze
FROM pg_stat_user_tables
WHERE schemaname = 'retail'
ORDER BY relname;

-- Etat de l'archivage
SELECT archived_count, failed_count,
       last_archived_time, last_failed_time
FROM pg_stat_archiver;

-- Requetes actives depuis plus de 5 secondes
SELECT pid, usename, application_name,
       clock_timestamp() - query_start AS duree
FROM pg_stat_activity
WHERE datname = current_database()
  AND state = 'active'
  AND pid <> pg_backend_pid()
  AND clock_timestamp() - query_start > interval '5 seconds';
