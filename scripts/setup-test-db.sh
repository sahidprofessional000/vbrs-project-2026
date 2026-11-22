#!/bin/sh
set -e
export PGPASSWORD=vbrs_secure_password_dev_123

EXISTS=$(psql -U vbrs_admin -h localhost -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='vbrs_test_db'")

if [ "$EXISTS" = "1" ]; then
  echo "vbrs_test_db already exists. Recreating fresh..."
  dropdb -U vbrs_admin -h localhost vbrs_test_db
fi

echo "Creating clean vbrs_test_db..."
createdb -U vbrs_admin -h localhost vbrs_test_db
echo "vbrs_test_db created successfully."
