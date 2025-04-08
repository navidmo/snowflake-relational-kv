# Snowflake QA Pairs Management System

A comprehensive system for managing Question and Answer (QA) pairs in Snowflake, featuring a complete set of CRUD operations, search capabilities, analytics functions, and batch processing capabilities.

## System Overview

This system provides a robust solution for storing and managing QA pairs with the following features:
- Automatic ID generation using sequences
- Timestamp tracking for creation and updates
- Full text search capabilities
- Statistical analysis
- Date range filtering
- Recent items retrieval
- Batch insertion support via JSON

## Directory Structure

```
│  └── src/
│       ├── cleanup_schema.sql           # Cleanup script for removing all objects
│       ├── create_objects.sql           # Creates initial database objects
│       ├── daily_qa_pairs_functions.sql # Core functions and procedures
│       ├── create_batch_procedure.sql   # Creates batch insert procedure
│       ├── demo_batch_insert.sql        # Demonstrates batch insert functionality
│       ├── demo_delete.sql             # Demonstrates deletion functionality
│       ├── demo_date_range.sql         # Demonstrates date range filtering
│       ├── demo_get_all.sql            # Demonstrates retrieving all QA pairs
│       ├── demo_recent.sql             # Demonstrates recent items retrieval
│       ├── demo_search.sql             # Demonstrates search functionality
│       ├── demo_stats.sql              # Demonstrates statistics gathering
│       ├── demo_update.sql             # Demonstrates update functionality
│       ├── example-EAV-01.sql          # Example EAV model implementation
│       └── insert_sample_data.sql      # Inserts sample data for demonstration
├── run_demo.sh                        # Main demonstration script
└── README.md                          # This documentation
```

## Database Objects

### Database Context
- Database: `KV_STORE`
- Schema: `PUBLIC`

### Table Structure

```sql
CREATE TABLE daily_qa_pairs (
    id NUMBER,                    -- Auto-incrementing ID
    question TEXT,               -- The question text
    answer TEXT,                 -- The answer text
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),  -- Creation timestamp
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()   -- Last update timestamp
);
```

### Sequence
- `daily_qa_pairs_seq`: Used for auto-incrementing IDs, starts at 1 and increments by 1

## Available Functions and Procedures

### Query Functions

1. `get_all_qa_pairs()`
   - Purpose: Retrieves all QA pairs ordered by creation date
   - Returns: Table(id, question, answer, created_at, updated_at)
   - Order: Most recent first
   - Example: `SELECT * FROM TABLE(get_all_qa_pairs());`

2. `get_qa_pair_by_id(qa_id NUMBER)`
   - Purpose: Retrieves a specific QA pair by ID
   - Parameter: qa_id - The ID of the QA pair to retrieve
   - Returns: Table(id, question, answer, created_at, updated_at)
   - Example: `SELECT * FROM TABLE(get_qa_pair_by_id(1));`

3. `search_qa_pairs(keyword TEXT)`
   - Purpose: Full-text search in questions and answers
   - Parameter: keyword - Text to search for
   - Case-insensitive search using LIKE
   - Returns: Table(id, question, answer, created_at, updated_at)
   - Example: `SELECT * FROM TABLE(search_qa_pairs('security'));`

4. `get_qa_pairs_by_date_range(start_date TIMESTAMP_NTZ, end_date TIMESTAMP_NTZ)`
   - Purpose: Retrieves QA pairs created within a specific date range
   - Parameters:
     - start_date: Beginning of the date range
     - end_date: End of the date range
   - Returns: Table(id, question, answer, created_at, updated_at)
   - Example:
     ```sql
     SELECT * FROM TABLE(get_qa_pairs_by_date_range(
       CONVERT_TIMEZONE('UTC', DATEADD(hours, -24, CURRENT_TIMESTAMP()))::TIMESTAMP_NTZ,
       CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
     ));
     ```

5. `get_recent_qa_pairs(limit_count NUMBER)`
   - Purpose: Retrieves the most recent QA pairs
   - Parameter: limit_count - Number of pairs to retrieve
   - Returns: Table(id, question, answer, created_at, updated_at)
   - Uses ROW_NUMBER() for efficient pagination
   - Example: `SELECT * FROM TABLE(get_recent_qa_pairs(5));`

6. `get_qa_pairs_count()`
   - Purpose: Returns the total number of QA pairs
   - Returns: NUMBER
   - Example: `SELECT get_qa_pairs_count();`

7. `get_qa_pairs_stats()`
   - Purpose: Provides statistical information about QA pairs
   - Returns: Table(total_pairs, oldest_pair_date, newest_pair_date, average_answer_length)
   - Example: `SELECT * FROM TABLE(get_qa_pairs_stats());`

### Modification Procedures

1. `add_qa_pair(question TEXT, answer TEXT)`
   - Purpose: Adds a new QA pair
   - Parameters:
     - question: The question text
     - answer: The answer text
   - Returns: NUMBER (the ID of the new pair)
   - Example: `CALL add_qa_pair('What is Snowflake?', 'A cloud data platform');`

2. `update_qa_pair(qa_id NUMBER, new_question TEXT, new_answer TEXT)`
   - Purpose: Updates an existing QA pair
   - Parameters:
     - qa_id: The ID of the pair to update
     - new_question: Updated question text
     - new_answer: Updated answer text
   - Returns: BOOLEAN (success status)
   - Automatically updates the updated_at timestamp
   - Example: `CALL update_qa_pair(1, 'Updated question', 'Updated answer');`

3. `delete_qa_pair(qa_id NUMBER)`
   - Purpose: Deletes a QA pair
   - Parameter: qa_id - The ID of the pair to delete
   - Returns: BOOLEAN (success status)
   - Example: `CALL delete_qa_pair(1);`

4. `batch_insert_qa_pairs_proc(json_data VARIANT)`
   - Purpose: Batch inserts multiple QA pairs from JSON data
   - Parameter: json_data - JSON array of QA pairs
   - Returns: ARRAY of inserted IDs
   - Supports both 'QUESTION'/'ANSWER' and 'question'/'answer' keys
   - Skips invalid entries (missing question or answer)
   - Example: 
     ```sql
     CALL batch_insert_qa_pairs_proc(PARSE_JSON('[{"question": "Q1", "answer": "A1"}, {"question": "Q2", "answer": "A2"}]'));
     ```

## Demo Script Usage

The `run_demo.sh` script provides a complete demonstration of all functionality:

```bash
./run_demo.sh
```

The script:
1. Cleans up any existing objects
2. Creates all necessary database objects (tables, sequences, functions, procedures)
3. Populates sample data
4. Demonstrates batch insert functionality
5. Demonstrates each core function and procedure:
   - Getting all QA pairs
   - Searching QA pairs
   - Getting recent QA pairs
   - Getting statistics
   - Updating QA pairs
   - Filtering by date range
   - Deleting QA pairs

### Error Handling

The script includes comprehensive error handling:
- Exits on any error (`set -euo pipefail`)
- Provides color-coded output for better visibility
- Reports detailed error messages
- Ensures proper cleanup even on failure

## Batch Insert Demonstration

The batch insert functionality demonstrates a sophisticated approach to efficiently ingesting multiple QA pairs simultaneously while maintaining data integrity and traceability. This implementation showcases the hybrid nature of our system, combining SQL-based row-level operations with Python-based batch processing capabilities.

The implementation begins by establishing the correct context in the Snowflake environment using `USE DATABASE` and `USE SCHEMA` commands, ensuring operations are performed in the appropriate namespace. A clean reset is performed by dropping any previously defined procedures, functions, sequences, and tables related to QA management, providing a fresh environment for demonstration.

The core table structure is recreated with the `daily_qa_pairs` table, which includes audit fields (`created_at`, `updated_at`) and an auto-increment sequence `daily_qa_pairs_seq` to generate unique IDs. This foundation ensures consistent data tracking and identification across all operations.

For individual QA pair insertion, a scalar stored procedure `add_qa_pair` is defined using Snowflake SQL. This procedure handles the insertion of individual QA entries with generated IDs and returns the inserted ID, ensuring controlled and traceable insert operations. The procedure encapsulates the logic for ID generation, timestamp management, and data validation, providing a robust interface for single-record operations.

To support efficient batch ingestion, the system defines a Python-based stored procedure `batch_insert_qa_pairs_proc` using Snowpark. This procedure accepts a JSON array of QA pairs and processes them efficiently. For each valid entry, it invokes the `add_qa_pair` SQL procedure using parameterized queries to safely insert the data while collecting the generated IDs. This hybrid approach leverages the procedural robustness of Snowflake SQL for row-level inserts and the flexibility of Python for batch control flow and JSON handling.

The batch processing includes several key features:
- **JSON Flexibility**: Accepts both uppercase ('QUESTION'/'ANSWER') and lowercase ('question'/'answer') keys, accommodating various input formats
- **Data Validation**: Skips invalid entries (missing question or answer) to maintain data integrity
- **ID Tracking**: Returns an array of successfully inserted IDs for downstream processing
- **Error Handling**: Gracefully handles malformed JSON or missing required fields
- **Transaction Management**: Each insert operation is atomic, ensuring data consistency

The demonstration includes sample calls that showcase different JSON formats and data patterns, illustrating the system's flexibility in handling various input structures. The final SELECT query confirms successful ingestion by displaying the stored entries, providing immediate feedback on the batch operation's outcome.

This batch insert implementation exemplifies the system's ability to bridge the gap between structured and semi-structured data models, offering efficient bulk data ingestion while maintaining the integrity and traceability of a relational system.

## Best Practices

1. **Data Integrity**
   - Always use the provided procedures for modifications
   - Use transactions for multiple operations
   - Validate input data before insertion

2. **Performance**
   - Use `get_recent_qa_pairs()` instead of `get_all_qa_pairs()` for large datasets
   - Include specific date ranges when querying historical data
   - Use the search function with specific keywords

3. **Maintenance**
   - Regularly check system statistics using `get_qa_pairs_stats()`
   - Archive old QA pairs if needed
   - Run cleanup script before major modifications

## Cleanup

To remove all objects created by this system:

```bash
snow sql -f src/cleanup_schema.sql -c snow_dev_conn --database KV_STORE --schema PUBLIC
```

## Error Codes and Troubleshooting

Common error scenarios and solutions:
1. Object already exists: Run cleanup script first
2. Invalid date format: Ensure TIMESTAMP_NTZ format
3. ID not found: Verify QA pair existence before updates
4. Search returns no results: Check case sensitivity and exact matching
5. Batch insert failures: Check JSON format and ensure required fields are present

## Security Considerations

1. All database operations use schema-level security
2. Timestamp fields are automatically managed
3. IDs are system-generated using sequences
4. No direct table modifications allowed (use procedures)
5. Batch operations use parameterized queries for security


## License

Copyright (C) 2025–present Navid Mohaghegh

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 3 only
as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You must retain the above copyright notice and author attribution
in all copies or substantial portions of this software.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.