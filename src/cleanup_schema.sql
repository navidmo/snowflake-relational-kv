-- Use the correct context
USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

-- Drop all functions and procedures
DROP FUNCTION IF EXISTS get_all_qa_pairs();
DROP PROCEDURE IF EXISTS get_all_qa_pairs();
DROP FUNCTION IF EXISTS get_qa_pair_by_id(NUMBER);
DROP PROCEDURE IF EXISTS get_qa_pair_by_id(NUMBER);
DROP FUNCTION IF EXISTS search_qa_pairs(TEXT);
DROP PROCEDURE IF EXISTS search_qa_pairs(TEXT);
DROP FUNCTION IF EXISTS get_qa_pairs_by_date_range(TIMESTAMP_NTZ, TIMESTAMP_NTZ);
DROP PROCEDURE IF EXISTS get_qa_pairs_by_date_range(TIMESTAMP_NTZ, TIMESTAMP_NTZ);
DROP FUNCTION IF EXISTS get_recent_qa_pairs(NUMBER);
DROP PROCEDURE IF EXISTS get_recent_qa_pairs(NUMBER);
DROP FUNCTION IF EXISTS get_qa_pairs_count();
DROP PROCEDURE IF EXISTS get_qa_pairs_count();
DROP FUNCTION IF EXISTS get_qa_pairs_stats();
DROP PROCEDURE IF EXISTS get_qa_pairs_stats();
DROP PROCEDURE IF EXISTS batch_insert_qa_pairs_proc(VARIANT);

-- Drop all stored procedures
DROP PROCEDURE IF EXISTS add_qa_pair(TEXT, TEXT);
DROP PROCEDURE IF EXISTS update_qa_pair(NUMBER, TEXT, TEXT);
DROP PROCEDURE IF EXISTS delete_qa_pair(NUMBER);
DROP PROCEDURE IF EXISTS add_qa_pairs_batch(VARIANT);

-- Drop the sequence
DROP SEQUENCE IF EXISTS daily_qa_pairs_seq;

-- Drop the main table
DROP TABLE IF EXISTS daily_qa_pairs;

-- Drop optional views (if any were created later)
-- DROP VIEW IF EXISTS qa_pairs_view;

-- Final status confirmation
SELECT 'Cleanup completed successfully' AS status;
