-- Use the correct context
USE DATABASE KV_STORE;
USE SCHEMA PUBLIC;

-- Create a procedure for batch JSON insertion
CREATE OR REPLACE PROCEDURE batch_insert_qa_pairs_proc(json_data VARIANT)
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