#!/bin/bash

# Script to terminate all connections to a PostgreSQL database
# Usage: ./pg-end-connections.sh <database_name> [-h host] [-p port] [-u username]
# 
# Arguments:
#   database_name - Name of the database to terminate connections for (required)
#
# Options:
#   -h host      - PostgreSQL server host (default: localhost)
#   -p port      - PostgreSQL server port (default: 5432)
#   -u username  - PostgreSQL username (default: current user)
#
# Environment variables:
#   PGPASSWORD   - PostgreSQL password (recommended for security)

# Set default values
PG_HOST="localhost"
PG_PORT="5432"
PG_USER="$USER"

# Function to display usage
usage() {
    echo "Usage: $0 <database_name> [-h host] [-p port] [-u username]"
    echo ""
    echo "Arguments:"
    echo "  database_name - Name of the database to terminate connections for (required)"
    echo ""
    echo "Options:"
    echo "  -h host      - PostgreSQL server host (default: localhost)"
    echo "  -p port      - PostgreSQL server port (default: 5432)"
    echo "  -u username  - PostgreSQL username (default: current user)"
    echo ""
    echo "Environment variables:"
    echo "  PGPASSWORD   - PostgreSQL password (recommended for security)"
    echo ""
    echo "Examples:"
    echo "  $0 mydatabase"
    echo "  $0 mydatabase -h 192.168.1.100 -p 5433 -u postgres"
    echo "  PGPASSWORD=mypass $0 mydatabase -h server.example.com -u dbuser"
}

# Check if at least one argument (database name) is provided
if [ $# -eq 0 ]; then
    echo "Error: Database name is required"
    echo ""
    usage
    exit 1
fi

# Get the database name from the first argument
DB_NAME="$1"
shift  # Remove the database name from the argument list

# Parse command line options
while getopts "h:p:u:" opt; do
    case $opt in
        h)
            PG_HOST="$OPTARG"
            ;;
        p)
            PG_PORT="$OPTARG"
            ;;
        u)
            PG_USER="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            echo ""
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            echo ""
            usage
            exit 1
            ;;
    esac
done

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