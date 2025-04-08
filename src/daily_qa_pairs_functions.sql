-- Use the KV_STORE database
USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

-- Create a procedure to add a new QA pair
CREATE OR REPLACE PROCEDURE add_qa_pair(question TEXT, answer TEXT)
RETURNS NUMBER
LANGUAGE SQL
AS
$$
DECLARE
    new_id NUMBER;
BEGIN
    INSERT INTO daily_qa_pairs (id, question, answer)
    VALUES (daily_qa_pairs_seq.NEXTVAL, :question, :answer);
    SELECT daily_qa_pairs_seq.CURRVAL INTO :new_id;
    RETURN :new_id;
END;
$$;

-- Create a function to get all QA pairs
CREATE OR REPLACE FUNCTION get_all_qa_pairs()
RETURNS TABLE (
    id NUMBER,
    question TEXT,
    answer TEXT,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
)
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT id, question, answer, created_at, updated_at
FROM daily_qa_pairs
ORDER BY created_at DESC';

-- Create a function to get a specific QA pair by ID
CREATE OR REPLACE FUNCTION get_qa_pair_by_id(qa_id NUMBER)
RETURNS TABLE (
    id NUMBER,
    question TEXT,
    answer TEXT,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
)
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT id, question, answer, created_at, updated_at
FROM daily_qa_pairs
WHERE id = qa_id';

-- Create a procedure to update a QA pair
CREATE OR REPLACE PROCEDURE update_qa_pair(
    qa_id NUMBER,
    new_question TEXT,
    new_answer TEXT
)
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE daily_qa_pairs
    SET 
        question = :new_question,
        answer = :new_answer,
        updated_at = CURRENT_TIMESTAMP()
    WHERE id = :qa_id;
    RETURN TRUE;
END;
$$;

-- Create a procedure to delete a QA pair
CREATE OR REPLACE PROCEDURE delete_qa_pair(qa_id NUMBER)
RETURNS BOOLEAN
LANGUAGE SQL
AS
$$
BEGIN
    DELETE FROM daily_qa_pairs
    WHERE id = :qa_id;
    RETURN TRUE;
END;
$$;

-- Create a function to search QA pairs by keyword
CREATE OR REPLACE FUNCTION search_qa_pairs(keyword TEXT)
RETURNS TABLE (
    id NUMBER,
    question TEXT,
    answer TEXT,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
)
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT id, question, answer, created_at, updated_at
FROM daily_qa_pairs
WHERE 
    LOWER(question) LIKE ''%'' || LOWER(keyword) || ''%'' OR
    LOWER(answer) LIKE ''%'' || LOWER(keyword) || ''%''
ORDER BY created_at DESC';

-- Create a function to get QA pairs by date range
CREATE OR REPLACE FUNCTION get_qa_pairs_by_date_range(
    start_date TIMESTAMP_NTZ,
    end_date TIMESTAMP_NTZ
)
RETURNS TABLE (
    id NUMBER,
    question TEXT,
    answer TEXT,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
)
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT id, question, answer, created_at, updated_at
FROM daily_qa_pairs
WHERE created_at BETWEEN start_date AND end_date
ORDER BY created_at DESC';

-- Create a function to get the most recent QA pairs
CREATE OR REPLACE FUNCTION get_recent_qa_pairs(limit_count NUMBER)
RETURNS TABLE (
    id NUMBER,
    question TEXT,
    answer TEXT,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ
)
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT id, question, answer, created_at, updated_at
FROM (
    SELECT id, question, answer, created_at, updated_at,
           ROW_NUMBER() OVER (ORDER BY created_at DESC) as rn
    FROM daily_qa_pairs
)
WHERE rn <= limit_count';

-- Create a function to get QA pairs count
CREATE OR REPLACE FUNCTION get_qa_pairs_count()
RETURNS NUMBER
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT COUNT(*) FROM daily_qa_pairs';

-- Create a function to get QA pairs statistics
CREATE OR REPLACE FUNCTION get_qa_pairs_stats()
RETURNS TABLE (
    total_pairs NUMBER,
    oldest_pair_date TIMESTAMP_NTZ,
    newest_pair_date TIMESTAMP_NTZ,
    average_answer_length NUMBER
)
LANGUAGE SQL
RETURNS NULL ON NULL INPUT
AS
'SELECT 
    COUNT(*) as total_pairs,
    MIN(created_at) as oldest_pair_date,
    MAX(created_at) as newest_pair_date,
    AVG(LENGTH(answer)) as average_answer_length
FROM daily_qa_pairs'; 