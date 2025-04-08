USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

-- Insert sample QA pairs with auto-incrementing IDs
INSERT INTO daily_qa_pairs (id, question, answer) VALUES 
(daily_qa_pairs_seq.NEXTVAL, 'What is Snowflake?', 
 'Snowflake is a cloud-native data platform that offers data warehouse, data lake, data engineering, and data sharing capabilities.'),
(daily_qa_pairs_seq.NEXTVAL, 'How does Snowflake handle data storage?', 
 'Snowflake uses a unique architecture that separates storage and compute, allowing for independent scaling and cost optimization.'),
(daily_qa_pairs_seq.NEXTVAL, 'What are Snowflake warehouses?', 
 'Snowflake warehouses are compute resources that process queries and DML operations. They can be started, stopped, and scaled independently.'),
(daily_qa_pairs_seq.NEXTVAL, 'What is data sharing in Snowflake?', 
 'Snowflake enables secure data sharing between accounts without copying or transferring data, using a unique approach called Secure Data Sharing.'),
(daily_qa_pairs_seq.NEXTVAL, 'How does Snowflake handle data security?', 
 'Snowflake provides comprehensive security features including encryption at rest and in transit, role-based access control, and network security policies.');

SELECT 'Sample data inserted successfully' as status;
