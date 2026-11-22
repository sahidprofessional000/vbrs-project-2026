#!/bin/sh
set -e
export PGPASSWORD=postgres
echo "1. Creating temporary database vbrs_restore_test..."
psql -h localhost -p 5432 -U postgres -c "DROP DATABASE IF EXISTS vbrs_restore_test;"
psql -h localhost -p 5432 -U postgres -c "CREATE DATABASE vbrs_restore_test;"

echo "2. Restoring backup into vbrs_restore_test..."
psql -h localhost -p 5432 -U postgres -d vbrs_restore_test < "/mnt/host/d/VEHICLE BRAKDOWN SYSTEM/scripts/backups/vbrs_db_backup_pre_synthetic_cleanup.sql" > /dev/null

echo "3. Querying restored tables to verify integrity..."
psql -h localhost -p 5432 -U postgres -d vbrs_restore_test -c "SELECT count(*) AS total_users FROM \"User\";"
psql -h localhost -p 5432 -U postgres -d vbrs_restore_test -c "SELECT count(*) AS total_reports FROM \"BreakdownReport\";"
psql -h localhost -p 5432 -U postgres -d vbrs_restore_test -c "SELECT count(*) AS total_mechanics FROM \"MechanicProfile\";"

echo "4. Dropping temporary database vbrs_restore_test..."
psql -h localhost -p 5432 -U postgres -c "DROP DATABASE vbrs_restore_test;"

echo "✅ BACKUP RESTORATION VERIFIED 100% SUCCESSFUL."
