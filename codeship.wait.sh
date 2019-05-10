#!/usr/bin/env bash

function test_postgresql {
  pg_isready -h "${DATABASE_HOST}" -p "${DATABASE_PORT}" -U "${DATABASE_USER}"
}

count=0
until ( test_postgresql )
do
  ((count++))
  if [ ${count} -gt 30 ]
  then
    echo "Services didn't become ready in 30s"
    exit 1
  fi
  sleep 1
done
