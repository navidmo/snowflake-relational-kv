USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

SELECT 'QA Pairs containing "security":' as message;
SELECT * FROM TABLE(search_qa_pairs('security'));
