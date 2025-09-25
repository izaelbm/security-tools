#!/bin/bash

docker network create \
  --driver bridge \
  --subnet 10.43.101.0/24 \
  --gateway 10.43.101.1 \
  metabase-net

sudo docker run -d \
  --name metabase-db \
  --restart=unless-stopped \
  --network metabase-net \
  -e POSTGRES_USER=metabase \
  -e POSTGRES_PASSWORD="##pegarsenhanocofre##" \
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
  -e MB_DB_PASS="##pegarsenhanocofre##" \
  -e MB_DB_HOST=metabase-db \
  -e MB_DB_PORT=5432 \
  -e MB_PLUGINS_DIR=/plugins \
  -e JAVA_TOOL_OPTIONS='-Duser.timezone=America/Sao_Paulo' \
  -v /opt/metabase/metabase-plugins:/plugins \
  metabase/metabase:latest


sudo docker run -d \
  --name metabase \
  --restart=unless-stopped \
  --network metabase-net \
  -p 3000:3000 \
  -e MB_DB_TYPE=mysql \
  -e MB_DB_DBNAME=metabase \
  -e MB_DB_USER=metabase \
  -e MB_DB_PASS='@metabase#pass' \
  -e MB_DB_HOST=metabase-db \
  -e MB_DB_PORT=3306 \
  -e MB_PLUGINS_DIR=/plugins \
  -e JAVA_TOOL_OPTIONS='-Duser.timezone=America/Sao_Paulo' \
  -v /opt/metabase/metabase-plugins:/plugins \
  metabase/metabase:latest
