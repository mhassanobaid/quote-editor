#!/bin/bash

echo "⏳ Waiting for Postgres..."

# Loop until DB is reachable
while ! nc -z $DATABASE_HOST 5432; do
  sleep 1
done

echo "✅ Postgres is ready!"
