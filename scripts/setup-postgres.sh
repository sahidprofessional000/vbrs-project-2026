#!/bin/sh
set -e

IMG="/mnt/host/d/VEHICLE BRAKDOWN SYSTEM/pgdata.img"
MOUNT_DIR="/var/lib/postgresql/mnt"
DATA_DIR="/var/lib/postgresql/mnt/data"

mkdir -p "$MOUNT_DIR"
if ! mountpoint -q "$MOUNT_DIR"; then
  mount -o loop "$IMG" "$MOUNT_DIR"
fi

mkdir -p "$DATA_DIR"
mkdir -p /run/postgresql
chown -R postgres:postgres /run/postgresql
chown -R postgres:postgres "$MOUNT_DIR"
chmod 700 "$DATA_DIR"

if [ ! -f "$DATA_DIR/PG_VERSION" ]; then
  su - postgres -c "initdb -D '$DATA_DIR' -U postgres -A trust"
  echo "listen_addresses = '*'" >> "$DATA_DIR/postgresql.conf"
  echo "host all all 0.0.0.0/0 trust" >> "$DATA_DIR/pg_hba.conf"
  echo "host all all ::0/0 trust" >> "$DATA_DIR/pg_hba.conf"
fi

su - postgres -c "pg_ctl -D '$DATA_DIR' -l /var/lib/postgresql/logfile start" || true
sleep 2

su - postgres -c "psql -U postgres -tc \"SELECT 1 FROM pg_user WHERE usename = 'vbrs_admin'\"" | grep -q 1 || \
su - postgres -c "psql -U postgres -c \"CREATE USER vbrs_admin WITH SUPERUSER PASSWORD 'vbrs_secure_password_dev_123';\""

su - postgres -c "psql -U postgres -tc \"SELECT 1 FROM pg_database WHERE datname = 'vbrs_db'\"" | grep -q 1 || \
su - postgres -c "psql -U postgres -c \"CREATE DATABASE vbrs_db OWNER vbrs_admin;\""

echo "=== POSTGRESQL STATUS ==="
su - postgres -c "psql -U vbrs_admin -d vbrs_db -c 'SELECT current_user, current_database(), version();'"
