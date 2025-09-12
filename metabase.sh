#!/bin/bash

# rede para os containers se verem
sudo docker network create metabase-net || true

# banco
sudo docker run -d \
  --name metabase-db \
  --restart=unless-stopped \
  --network metabase-net \
  -e POSTGRES_USER=metabase \
  -e POSTGRES_PASSWORD="@metabase#pass" \
  -e POSTGRES_DB=metabase \
  -v /opt/metabase/metabase-data:/var/lib/postgresql/data \
  postgres:14

# metabase
sudo docker run -d \
  --name metabase \
  --restart=unless-stopped \
  --network metabase-net \
  -p 3000:3000 \
  -e MB_DB_TYPE=postgres \
  -e MB_DB_DBNAME=metabase \
  -e MB_DB_USER=metabase \
  -e MB_DB_PASS="@metabase#pass" \
  -e MB_DB_HOST=metabase-db \
  -e MB_DB_PORT=5432 \
  -e MB_PLUGINS_DIR=/plugins \
  -e JAVA_TOOL_OPTIONS='-Duser.timezone=America/Sao_Paulo' \
  -v /opt/metabase/metabase-plugins:/plugins \
  metabase/metabase:latest
