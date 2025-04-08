USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

SELECT 'Updating QA pair with ID 1:' as message;
CALL update_qa_pair(1, 'What is Snowflake?', 
  'Snowflake is a cloud-native data platform that offers data warehouse, data lake, data engineering, data sharing, and application development capabilities through Snowpark.');

SELECT 'Updated QA pair:' as message;
SELECT * FROM TABLE(get_qa_pair_by_id(1));
