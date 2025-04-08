#!/bin/bash

# Use the snowflake venv
source ~/venvs/snowflake312/bin/activate

###########################################
# Snowflake QA Pairs Management Demo Script
# 
# This script demonstrates the complete functionality of the QA pairs
# management system using existing SQL files in the src directory.
#
# Usage: ./run_demo.sh [--database DATABASE_NAME] [--schema SCHEMA_NAME] [--connection CONNECTION_NAME]
#   --database: Snowflake database name (default: KV_STORE)
#   --schema: Snowflake schema name (default: PUBLIC)
#   --connection: Snowflake connection name (default: snow_dev_conn)
###########################################

# Enable strict error handling
# - Exit on error
# - Treat unset variables as errors
# - Exit on pipe failures
set -euo pipefail

###########################################
# Parameter Handling
###########################################
# Default values
DATABASE_NAME="KV_STORE"
SCHEMA_NAME="PUBLIC"
CONNECTION_NAME="snow_dev_conn"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --database)
      DATABASE_NAME="$2"
      shift 2
      ;;
    --schema)
      SCHEMA_NAME="$2"
      shift 2
      ;;
    --connection)
      CONNECTION_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      echo "Usage: ./run_demo.sh [--database DATABASE_NAME] [--schema SCHEMA_NAME] [--connection CONNECTION_NAME]"
      exit 1
      ;;
  esac
done

###########################################
# Color Configuration
# These colors are used to make the output more readable
###########################################
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

###########################################
# Helper Functions
###########################################

# Cleanup function to drop existing objects
cleanup() {
  print_header "Cleaning up existing objects"
  if snow sql -f "src/cleanup_schema.sql" -c "$CONNECTION_NAME" --database "$DATABASE_NAME" --schema "$SCHEMA_NAME"; then
    print_success "Cleanup completed successfully"
  else
    print_error "Cleanup failed"
    exit 1
  fi
}

# Print a section header with consistent formatting
# Args:
#   $1 - Header text to display
print_header() {
  echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

# Print a success message in green
# Args:
#   $1 - Success message to display
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# Print an error message in red
# Args:
#   $1 - Error message to display
print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Execute a SQL file and handle any errors
# Args:
#   $1 - Path to SQL file
#   $2 - Description of the operation
execute_sql() {
  local sql_file=$1
  local description=$2
  
  print_header "Executing $description"
  
  if snow sql -f "$sql_file" -c "$CONNECTION_NAME" --database "$DATABASE_NAME" --schema "$SCHEMA_NAME"; then
    print_success "$description completed successfully"
  else
    print_error "$description failed"
    exit 1
  fi
}

###########################################
# Main Script
###########################################

echo -e "${BLUE}==== QA Pairs Management System Demo ====${NC}"
echo -e "Using database: ${GREEN}$DATABASE_NAME${NC}"
echo -e "Using schema: ${GREEN}$SCHEMA_NAME${NC}"
echo -e "Using connection: ${GREEN}$CONNECTION_NAME${NC}"

# Run cleanup before starting the demo
cleanup

###########################################
# Step 1: Database Setup
# Creates the necessary database objects:
# - daily_qa_pairs table
# - daily_qa_pairs_seq sequence
# - All functions and procedures
###########################################
print_header "Step 1: Setting up the QA Pairs System"

# 1.1 Create the table and sequence
execute_sql "src/create_objects.sql" "Creating database objects"

# 1.2 Create the functions and procedures
execute_sql "src/daily_qa_pairs_functions.sql" "Creating functions and procedures"

# 1.3 Create the batch insert procedure
execute_sql "src/create_batch_procedure.sql" "Creating batch insert procedure"

###########################################
# Step 2: Sample Data Population
# Inserts sample QA pairs about Snowflake
# to demonstrate the system's functionality
###########################################
print_header "Step 2: Inserting Sample Data"
execute_sql "src/insert_sample_data.sql" "Inserting sample data"

###########################################
# Step 3: Batch Insert Demonstration
# Demonstrates the batch insert functionality
# with various examples and error handling
###########################################
print_header "Step 3: Demonstrating Batch Insert"
execute_sql "src/demo_batch_insert.sql" "Demonstrating batch insert functionality"


###########################################
# Step 4: Feature Demonstration
# Demonstrates each function and procedure
# in the QA pairs management system
###########################################
print_header "Step 4: Demonstrating Functionality"

# 4.1 Demonstrate retrieval of all QA pairs
execute_sql "src/demo_get_all.sql" "Getting all QA pairs"

# 4.2 Demonstrate search functionality
execute_sql "src/demo_search.sql" "Searching for QA pairs containing 'security'"

# 4.3 Demonstrate pagination/limiting results
execute_sql "src/demo_recent.sql" "Getting 3 most recent QA pairs"

# 4.4 Demonstrate statistics gathering
execute_sql "src/demo_stats.sql" "Getting QA pairs statistics"

# 4.5 Demonstrate update functionality
execute_sql "src/demo_update.sql" "Updating a QA pair"

# 4.6 Demonstrate date range filtering
execute_sql "src/demo_date_range.sql" "Getting QA pairs by date range"

# 4.7 Demonstrate deletion functionality
execute_sql "src/demo_delete.sql" "Deleting a QA pair"

###########################################
# Demo Completion
###########################################
print_header "Demo Completed Successfully"
echo -e "${GREEN}All steps completed successfully!${NC}" 