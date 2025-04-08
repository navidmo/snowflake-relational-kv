USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

SELECT '3 Most Recent QA Pairs:' as message;
SELECT * FROM TABLE(get_recent_qa_pairs(3));
