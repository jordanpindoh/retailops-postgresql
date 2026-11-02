SELECT pg_size_pretty(pg_database_size(current_database()))
       AS taille_base;

SELECT relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS taille_totale,
       n_live_tup, n_dead_tup,
       last_autovacuum, last_analyze
FROM pg_stat_user_tables
WHERE schemaname = 'retail'
ORDER BY pg_total_relation_size(relid) DESC;

VACUUM (ANALYZE) retail.orders;

SELECT spcname, pg_tablespace_location(oid) AS emplacement
FROM pg_tablespace;
