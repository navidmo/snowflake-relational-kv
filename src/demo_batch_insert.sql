-- Use the correct context
USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

-- Clean up any existing objects
DROP PROCEDURE IF EXISTS add_qa_pair(TEXT, TEXT);
DROP PROCEDURE IF EXISTS batch_insert_qa_pairs_sp(VARIANT);
DROP FUNCTION IF EXISTS batch_insert_qa_pairs_udf(VARIANT);
DROP SEQUENCE IF EXISTS daily_qa_pairs_seq;
DROP TABLE IF EXISTS daily_qa_pairs;

-- Create the sequence
CREATE OR REPLACE SEQUENCE daily_qa_pairs_seq START = 1 INCREMENT = 1;

-- Create the table
CREATE OR REPLACE TABLE daily_qa_pairs (
    id NUMBER PRIMARY KEY,                    
    question TEXT,               
    answer TEXT,                 
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),  
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()   
);

-- Create the add_qa_pair procedure
CREATE OR REPLACE PROCEDURE add_qa_pair(question TEXT, answer TEXT)
RETURNS NUMBER
LANGUAGE SQL
AS
$$
DECLARE
    new_id NUMBER;
BEGIN
    SELECT daily_qa_pairs_seq.NEXTVAL INTO :new_id;
    
    INSERT INTO daily_qa_pairs (id, question, answer)
    VALUES (:new_id, :question, :answer);
    
    RETURN :new_id;
END;
$$;

-- Create a stored procedure (not UDF) for batch insert using Python
CREATE OR REPLACE PROCEDURE batch_insert_qa_pairs_sp(json_data VARIANT)
RETURNS ARRAY
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'run'
AS
$$
def run(session, json_data):
    inserted_ids = []
    
    # json_data is already a list of dictionaries
    for item in json_data:
        question = item.get('QUESTION') or item.get('question')
        answer = item.get('ANSWER') or item.get('answer')
        if not question or not answer:
            continue
            
        # Call add_qa_pair using parameterized query
        result = session.sql("CALL add_qa_pair(?, ?)", [question, answer]).collect()
        inserted_id = result[0][0]
        inserted_ids.append(inserted_id)
    
    return inserted_ids
$$;

-- Run the batch insert via stored procedure
CALL batch_insert_qa_pairs_sp(PARSE_JSON('[
    {
        "question": "What is Snowflake Time Travel?",
        "answer": "Time Travel is a feature that allows you to access historical data at any point within a defined period."
    },
    {
        "question": "How does Snowflake handle data loading?",
        "answer": "Snowflake supports multiple data loading methods including bulk loading, continuous loading, and Snowpipe."
    }
]'));

-- Show inserted pairs
SELECT * FROM daily_qa_pairs ORDER BY id;
