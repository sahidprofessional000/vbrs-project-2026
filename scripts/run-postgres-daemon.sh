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

echo "Starting PostgreSQL foreground daemon..."
exec su - postgres -c "postgres -D '$DATA_DIR'"
