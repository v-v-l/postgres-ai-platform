-- Production security configuration
-- This runs only in production mode to enable security features

-- Enable SSL if certificates exist
DO $$
BEGIN
    -- Try to enable SSL
    BEGIN
        PERFORM pg_reload_conf();
        ALTER SYSTEM SET ssl = 'on';
        ALTER SYSTEM SET ssl_cert_file = '/var/lib/postgresql/server.crt';
        ALTER SYSTEM SET ssl_key_file = '/var/lib/postgresql/server.key';
        PERFORM pg_reload_conf();
        RAISE NOTICE 'SSL enabled successfully';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'SSL configuration skipped: %', SQLERRM;
    END;
END $$;

-- Enable connection logging
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_statement = 'mod';  -- Log modifications only
ALTER SYSTEM SET log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';

-- Reload configuration
SELECT pg_reload_conf();