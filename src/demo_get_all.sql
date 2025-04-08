USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

SELECT 'All QA Pairs:' as message;
SELECT * FROM TABLE(get_all_qa_pairs());
