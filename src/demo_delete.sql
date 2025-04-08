USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

SELECT 'Deleting QA pair with ID 5:' as message;
CALL delete_qa_pair(5);

SELECT 'Remaining QA pairs:' as message;
SELECT * FROM TABLE(get_all_qa_pairs());
