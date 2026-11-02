CREATE EXTENSION IF NOT EXISTS pgaudit;
ALTER SYSTEM SET pgaudit.log = 'write, ddl, role';
ALTER SYSTEM SET pgaudit.log_parameter = 'off';
ALTER SYSTEM SET pgaudit.log_statement = 'off';
SELECT pg_reload_conf();
