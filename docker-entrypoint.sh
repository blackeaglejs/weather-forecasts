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

echo "Preparing database..."
bin/rails db:prepare

echo "Starting Rails server..."
exec "$@"