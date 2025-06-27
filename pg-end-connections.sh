#!/bin/bash

# Script to terminate all connections to a PostgreSQL database
# Usage: ./pg-end-connections.sh <database_name>

# Check if database name is provided
if [ $# -eq 0 ]; then
    echo "Error: Database name is required"
    echo "Usage: $0 <database_name>"
    exit 1
fi

# Get the database name from the first argument
DB_NAME="$1"

# Validate database name (basic check for empty string)
if [ -z "$DB_NAME" ]; then
    echo "Error: Database name cannot be empty"
    exit 1
fi

echo "Terminating all connections to database: $DB_NAME"

# Execute the SQL command to terminate all connections to the specified database
psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME';"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Successfully terminated all connections to database: $DB_NAME"
else
    echo "Error: Failed to terminate connections to database: $DB_NAME"
    exit 1
fi