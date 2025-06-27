#!/bin/bash

# Script to terminate all connections to a PostgreSQL database
# Usage: ./pg-end-connections.sh <database_name> [host] [port] [username]
# 
# Arguments:
#   database_name - Name of the database to terminate connections for (required)
#   host         - PostgreSQL server host (optional, defaults to localhost)
#   port         - PostgreSQL server port (optional, defaults to 5432)
#   username     - PostgreSQL username (optional, defaults to current user)
#
# Environment variables:
#   PGPASSWORD   - PostgreSQL password (recommended for security)

# Check if database name is provided
if [ $# -eq 0 ]; then
    echo "Error: Database name is required"
    echo "Usage: $0 <database_name> [host] [port] [username]"
    echo ""
    echo "Optional parameters:"
    echo "  host     - PostgreSQL server host (default: localhost)"
    echo "  port     - PostgreSQL server port (default: 5432)"
    echo "  username - PostgreSQL username (default: current user)"
    echo ""
    echo "Set PGPASSWORD environment variable for password authentication"
    exit 1
fi

# Get the database name from the first argument
DB_NAME="$1"

# Get optional connection parameters
PG_HOST="${2:-localhost}"
PG_PORT="${3:-5432}"
PG_USER="${4:-$USER}"

# Validate database name (basic check for empty string)
if [ -z "$DB_NAME" ]; then
    echo "Error: Database name cannot be empty"
    exit 1
fi

# Check if password is set via environment variable
if [ -z "$PGPASSWORD" ]; then
    echo "Warning: PGPASSWORD environment variable not set"
    echo "You may be prompted for a password"
fi

echo "Connection details:"
echo "  Host: $PG_HOST"
echo "  Port: $PG_PORT"
echo "  User: $PG_USER"
echo "  Database: $DB_NAME"
echo ""
echo "Terminating all connections to database: $DB_NAME"

# Execute the SQL command to terminate all connections to the specified database
psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME';"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Successfully terminated all connections to database: $DB_NAME"
else
    echo "Error: Failed to terminate connections to database: $DB_NAME"
    exit 1
fi