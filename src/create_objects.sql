USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

-- Create sequence for auto-incrementing IDs
CREATE OR REPLACE SEQUENCE daily_qa_pairs_seq START = 1 INCREMENT = 1;

-- Create the table with timestamp management
CREATE OR REPLACE TABLE daily_qa_pairs (
    id NUMBER,                    -- Auto-incrementing ID
    question TEXT,               -- The question text
    answer TEXT,                 -- The answer text
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),  -- Creation timestamp
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()   -- Last update timestamp
);

SELECT 'Database objects created successfully' as status;
