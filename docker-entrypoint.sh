#!/bin/bash
set -e

echo "Installing gems..."
bundle check || bundle install

echo "Removing old PID..."
rm -f tmp/pids/server.pid

echo "Waiting for database..."
until pg_isready -h db -U postgres; do
  sleep 1
done

echo "Creating database..."
bin/rails db:create || true

echo "Running migrations..."
bin/rails db:migrate

echo "Starting Rails server..."
exec "$@"