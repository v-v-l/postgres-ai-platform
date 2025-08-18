-- AI/ML Example Tables and Functions
-- This demonstrates advanced AI/ML capabilities beyond basic pgvector

-- Example 1: Multi-modal Embeddings Table
CREATE TABLE IF NOT EXISTS ai_embeddings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    content_type VARCHAR(50) NOT NULL, -- 'text', 'image', 'audio', 'multimodal'
    original_content TEXT,
    metadata JSONB DEFAULT '{}',
    text_embedding vector(1536),      -- OpenAI text embeddings
    image_embedding vector(512),      -- CLIP image embeddings  
    multimodal_embedding vector(768), -- Combined embeddings
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for different similarity searches
CREATE INDEX IF NOT EXISTS idx_ai_embeddings_text_cosine 
    ON ai_embeddings USING hnsw (text_embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_ai_embeddings_image_cosine 
    ON ai_embeddings USING hnsw (image_embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_ai_embeddings_multimodal_cosine 
    ON ai_embeddings USING hnsw (multimodal_embedding vector_cosine_ops);

-- Metadata search index
CREATE INDEX IF NOT EXISTS idx_ai_embeddings_metadata_gin 
    ON ai_embeddings USING gin (metadata);

-- Content type index  
CREATE INDEX IF NOT EXISTS idx_ai_embeddings_content_type 
    ON ai_embeddings (content_type);

-- Example 2: Fuzzy Text Search with AI Enhancement
CREATE TABLE IF NOT EXISTS smart_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'en',
    tags TEXT[],
    embedding vector(1536),
    
    -- Text search vectors
    title_tsvector tsvector GENERATED ALWAYS AS (to_tsvector('english', title)) STORED,
    content_tsvector tsvector GENERATED ALWAYS AS (to_tsvector('english', content)) STORED,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Combined text search and vector search indexes
CREATE INDEX IF NOT EXISTS idx_smart_documents_title_gin 
    ON smart_documents USING gin (title_tsvector);
CREATE INDEX IF NOT EXISTS idx_smart_documents_content_gin 
    ON smart_documents USING gin (content_tsvector);
CREATE INDEX IF NOT EXISTS idx_smart_documents_embedding_cosine 
    ON smart_documents USING hnsw (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_smart_documents_tags_gin 
    ON smart_documents USING gin (tags);

-- Example 3: Hierarchical AI Data (for tree-structured ML data)
CREATE TABLE IF NOT EXISTS ai_taxonomy (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    path ltree NOT NULL,           -- Hierarchical path
    embedding vector(384),         -- Smaller embeddings for taxonomy
    metadata JSONB DEFAULT '{}',
    level INTEGER GENERATED ALWAYS AS (nlevel(path)) STORED
);

CREATE INDEX IF NOT EXISTS idx_ai_taxonomy_path_gist 
    ON ai_taxonomy USING gist (path);
CREATE INDEX IF NOT EXISTS idx_ai_taxonomy_embedding 
    ON ai_taxonomy USING hnsw (embedding vector_cosine_ops);

-- Example 4: Time-series AI Data
CREATE TABLE IF NOT EXISTS ai_metrics (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    metric_name TEXT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    values NUMERIC[] NOT NULL,      -- Array of metric values
    embedding vector(256),          -- Embedding of the metric pattern
    metadata JSONB DEFAULT '{}'
);

-- Time-series specific indexes
CREATE INDEX IF NOT EXISTS idx_ai_metrics_timestamp 
    ON ai_metrics (timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_ai_metrics_name_time 
    ON ai_metrics (metric_name, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_ai_metrics_embedding 
    ON ai_metrics USING hnsw (embedding vector_cosine_ops);

-- Example Functions for AI/ML Operations

-- Function: Hybrid search combining text and vector similarity
CREATE OR REPLACE FUNCTION hybrid_search(
    query_text TEXT,
    query_embedding vector(1536),
    text_weight FLOAT DEFAULT 0.3,
    vector_weight FLOAT DEFAULT 0.7,
    result_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    doc_id UUID,
    title TEXT,
    content TEXT,
    text_score REAL,
    vector_score REAL,
    combined_score REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sd.id,
        sd.title,
        sd.content,
        ts_rank(sd.content_tsvector, plainto_tsquery('english', query_text)) as text_score,
        (1 - (sd.embedding <=> query_embedding)) as vector_score,
        (text_weight * ts_rank(sd.content_tsvector, plainto_tsquery('english', query_text)) + 
         vector_weight * (1 - (sd.embedding <=> query_embedding))) as combined_score
    FROM smart_documents sd
    WHERE sd.content_tsvector @@ plainto_tsquery('english', query_text)
       OR sd.embedding <=> query_embedding < 0.8  -- Similarity threshold
    ORDER BY combined_score DESC
    LIMIT result_limit;
END;
$$ LANGUAGE plpgsql;

-- Function: Find similar items across different modalities
CREATE OR REPLACE FUNCTION cross_modal_search(
    input_embedding vector,
    embedding_type TEXT DEFAULT 'text',
    similarity_threshold FLOAT DEFAULT 0.8,
    result_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
    item_id UUID,
    content_type TEXT,
    similarity_score FLOAT,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ae.id,
        ae.content_type,
        CASE 
            WHEN embedding_type = 'text' THEN (1 - (ae.text_embedding <=> input_embedding))
            WHEN embedding_type = 'image' THEN (1 - (ae.image_embedding <=> input_embedding))
            WHEN embedding_type = 'multimodal' THEN (1 - (ae.multimodal_embedding <=> input_embedding))
            ELSE 0.0
        END as similarity_score,
        ae.metadata
    FROM ai_embeddings ae
    WHERE 
        CASE 
            WHEN embedding_type = 'text' THEN ae.text_embedding <=> input_embedding
            WHEN embedding_type = 'image' THEN ae.image_embedding <=> input_embedding
            WHEN embedding_type = 'multimodal' THEN ae.multimodal_embedding <=> input_embedding
            ELSE 1.0
        END < (1 - similarity_threshold)
    ORDER BY similarity_score DESC
    LIMIT result_limit;
END;
$$ LANGUAGE plpgsql;

-- Insert some example data (using proper 1536-dimensional vectors)
INSERT INTO smart_documents (title, content, embedding) VALUES 
    ('Machine Learning Basics', 'Introduction to neural networks and deep learning concepts', 
     ARRAY(SELECT random() FROM generate_series(1, 1536))::vector),
    ('PostgreSQL Vector Search', 'How to implement semantic search using pgvector extension', 
     ARRAY(SELECT random() FROM generate_series(1, 1536))::vector),
    ('AI Applications', 'Real-world applications of artificial intelligence in business', 
     ARRAY(SELECT random() FROM generate_series(1, 1536))::vector);

-- Example taxonomy data (using proper 384-dimensional vectors)
INSERT INTO ai_taxonomy (name, path, embedding) VALUES
    ('AI', 'AI', ARRAY(SELECT random() FROM generate_series(1, 384))::vector),
    ('Machine Learning', 'AI.ML', ARRAY(SELECT random() FROM generate_series(1, 384))::vector),
    ('Deep Learning', 'AI.ML.DL', ARRAY(SELECT random() FROM generate_series(1, 384))::vector),
    ('Computer Vision', 'AI.ML.DL.CV', ARRAY(SELECT random() FROM generate_series(1, 384))::vector),
    ('Natural Language Processing', 'AI.ML.NLP', ARRAY(SELECT random() FROM generate_series(1, 384))::vector);

RAISE NOTICE 'AI/ML example tables and functions created successfully!';
RAISE NOTICE 'Use hybrid_search() and cross_modal_search() functions for advanced AI operations';