-- Enable AI/ML and vector extensions for advanced capabilities
-- This must be run as superuser (postgres user)

-- Performance Monitoring (must be in shared_preload_libraries)
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements"; -- Query performance statistics for AI/ML optimization

-- Core Vector Operations
CREATE EXTENSION IF NOT EXISTS vector;       -- pgvector for embeddings and similarity search

-- Text & Search Extensions  
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- Trigram matching for fuzzy text search
CREATE EXTENSION IF NOT EXISTS "fuzzystrmatch"; -- Fuzzy string matching (Levenshtein, etc.)
CREATE EXTENSION IF NOT EXISTS "unaccent";   -- Remove accents for better text search

-- Advanced Indexing for AI/ML
CREATE EXTENSION IF NOT EXISTS "btree_gin";  -- GIN indexes for btree operations
CREATE EXTENSION IF NOT EXISTS "btree_gist"; -- GiST indexes for btree operations

-- JSON & Analytics Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- UUID generation for unique identifiers
CREATE EXTENSION IF NOT EXISTS "ltree";      -- Tree-like data structures (hierarchies)
CREATE EXTENSION IF NOT EXISTS "hstore";     -- Key-value store within PostgreSQL

-- Statistical & ML Extensions (if available)
DO $$
BEGIN
    -- Try to create advanced extensions (may not be available in all PostgreSQL versions)
    BEGIN
        CREATE EXTENSION IF NOT EXISTS "cube";           -- Multi-dimensional cube data type
        RAISE NOTICE 'CUBE extension enabled for multi-dimensional data';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'CUBE extension not available: %', SQLERRM;
    END;
    
    BEGIN
        CREATE EXTENSION IF NOT EXISTS "earthdistance"; -- Geographic distance calculations
        RAISE NOTICE 'EARTHDISTANCE extension enabled for geo calculations';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'EARTHDISTANCE extension not available: %', SQLERRM;
    END;
END $$;

-- Verify core AI/ML extensions are installed
SELECT extname, extversion FROM pg_extension 
WHERE extname IN ('vector', 'pg_trgm', 'fuzzystrmatch', 'unaccent', 'btree_gin', 'btree_gist', 'ltree', 'hstore', 'cube')
ORDER BY extname;