#!/bin/bash

# Script to terminate all connections to a PostgreSQL database
# Usage: ./pg-end-connections.sh [options] <database_name>
# 
# Arguments:
#   database_name - Name of the database to terminate connections for (required, can be in any position)
#
# Options:
#   -h, --host host      - PostgreSQL server host (default: localhost)
#   -p, --port port      - PostgreSQL server port (default: 5432)
#   -u, --user username  - PostgreSQL username (default: current user)
#
# Environment variables:
#   PGPASSWORD   - PostgreSQL password (recommended for security)

# Set default values
PG_HOST="localhost"
PG_PORT="5432"
PG_USER="$USER"
DB_NAME=""

# Function to display usage
usage() {
    echo "Usage: $0 [options] <database_name>"
    echo ""
    echo "Arguments:"
    echo "  database_name - Name of the database to terminate connections for (required)"
    echo ""
    echo "Options:"
    echo "  -h, --host host      - PostgreSQL server host (default: localhost)"
    echo "  -p, --port port      - PostgreSQL server port (default: 5432)"
    echo "  -u, --user username  - PostgreSQL username (default: current user)"
    echo ""
    echo "Environment variables:"
    echo "  PGPASSWORD   - PostgreSQL password (recommended for security)"
    echo ""
    echo "Examples:"
    echo "  $0 mydatabase"
    echo "  $0 --host 192.168.1.100 --port 5433 --user postgres mydatabase"
    echo "  $0 -h server.example.com mydatabase -u dbuser"
    echo "  PGPASSWORD=mypass $0 mydatabase --host server.example.com"
}

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
    echo "Error: Database name is required"
    echo ""
    usage
    exit 1
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            PG_HOST="$2"
            shift 2
            ;;
        -p|--port)
            PG_PORT="$2"
            shift 2
            ;;
        -u|--user)
            PG_USER="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo ""
            usage
            exit 1
            ;;
        *)
            # This is the database name (unnamed argument)
            if [ -z "$DB_NAME" ]; then
                DB_NAME="$1"
            else
                echo "Error: Multiple database names specified: '$DB_NAME' and '$1'" >&2
                echo ""
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate database name
if [ -z "$DB_NAME" ]; then
    echo "Error: Database name is required"
    echo ""
    usage
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
psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$DB_NAME" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB_NAME';"

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Successfully terminated all connections to database: $DB_NAME"
else
    echo "Error: Failed to terminate connections to database: $DB_NAME"
    exit 1
fi