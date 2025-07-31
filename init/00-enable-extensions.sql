-- Enable pgvector extension for vector operations
-- This must be run as superuser (postgres user)

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable other useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- UUID generation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- Trigram matching for text search
CREATE EXTENSION IF NOT EXISTS "btree_gin";  -- GIN indexes for btree operations
CREATE EXTENSION IF NOT EXISTS "btree_gist"; -- GiST indexes for btree operations

-- Verify extensions are installed
SELECT extname, extversion FROM pg_extension WHERE extname IN ('vector', 'uuid-ossp', 'pg_trgm', 'btree_gin', 'btree_gist');