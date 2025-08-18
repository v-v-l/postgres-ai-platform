-- Create additional databases for different projects
-- Uncomment and modify as needed for your projects

-- CREATE DATABASE casa_connect;
-- CREATE DATABASE project2;
-- CREATE DATABASE project3;

-- Example: Create a user for each project
-- CREATE USER casa_connect_user WITH PASSWORD 'casa_connect_pass';
-- GRANT ALL PRIVILEGES ON DATABASE casa_connect TO casa_connect_user;

-- Example: Enable pgvector in project-specific databases
-- \c casa_connect;
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Example vector table (uncomment if needed)
-- CREATE TABLE IF NOT EXISTS embeddings (
--     id SERIAL PRIMARY KEY,
--     content TEXT,
--     embedding vector(1536),  -- OpenAI ada-002 dimensions
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- Create index for vector similarity search
-- CREATE INDEX ON embeddings USING hnsw (embedding vector_cosine_ops);