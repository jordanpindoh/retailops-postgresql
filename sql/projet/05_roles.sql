BEGIN;

CREATE ROLE retail_ro NOLOGIN;
CREATE ROLE retail_rw NOLOGIN;

CREATE ROLE analyst_login LOGIN
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
CREATE ROLE app_login LOGIN
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;

REVOKE ALL ON DATABASE retail_admin FROM PUBLIC;
GRANT CONNECT ON DATABASE retail_admin TO retail_ro, retail_rw;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA retail FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA retail FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA retail FROM PUBLIC;

GRANT USAGE ON SCHEMA retail TO retail_ro;
GRANT SELECT ON ALL TABLES IN SCHEMA retail TO retail_ro;

GRANT retail_ro TO retail_rw;
GRANT INSERT ON retail.orders, retail.order_items TO retail_rw;
GRANT UPDATE (status) ON retail.orders TO retail_rw;
GRANT USAGE ON SEQUENCE retail.orders_order_id_seq,
    retail.order_items_item_id_seq TO retail_rw;

GRANT retail_ro TO analyst_login;
GRANT retail_rw TO app_login;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA retail
    GRANT SELECT ON TABLES TO retail_ro;

COMMIT;
