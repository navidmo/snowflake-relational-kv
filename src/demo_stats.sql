USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

SELECT 'QA Pairs Statistics:' as message;
SELECT * FROM TABLE(get_qa_pairs_stats());
