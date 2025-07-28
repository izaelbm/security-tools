###
1 - Deploy Tool With Docker
###

docker run --detach \
  --restart=always \
  --publish 9392:9392 \
  --publish 5432:5432 \
  -e USERNAME=admin \
  -e PASSWORD="admin" \
  --volume openvas:/data \
  --name openvas \
  immauss/openvas

###
2 - Config Cron to Database Update
###
open crontab -e
insert line -> 0 3 * * * /usr/local/bin/update-gvm-feeds.sh >> /var/log/gvm/feed-update.log 2>&1


create file update-gvm-feeds.sh
>
#!/bin/bash

greenbone-feed-sync --type NVT
greenbone-feed-sync --type SCAP
greenbone-feed-sync --type CERT

runuser -u gvm -- gvmd --update-feed
<

change permissions -> chmod +x /usr/local/bin/update-gvm-feeds.sh

start cron -> service cron start

###
3 - Deploy Nginx
###
>
server {
    # Redireciona HTTP para HTTPS
    listen 80;
    server_name scan.tool.com.br www.scan.tool.com.br;

    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name scan.tool.com.br www.scan.tool.com.br;

    ssl_certificate /etc/ssl/certs/tool-cert.pem;
    ssl_certificate_key /etc/ssl/certs/tool-cert-key.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Configuração do proxy reverso
    location / {
        proxy_pass http://127.0.0.1:9392;
        proxy_http_version 1.1;
        proxy_ssl_verify off;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header Origin "";
        proxy_buffering off;

        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;

        #tamanho de upload
        client_max_body_size 5G;

        # Cabeçalhos CORS
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
        add_header Access-Control-Allow-Headers "Origin, Content-Type, X-Requested-With, Authorization, X-Auth-Token" always;
        add_header Access-Control-Allow-Credentials "true" always;

        # Lidar com requisições OPTIONS (pre-flight) para CORS
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE" always;
            add_header Access-Control-Allow-Headers "Origin, Content-Type, X-Requested-With, Authorization, X-Auth-Token" always;
            add_header Access-Control-Allow-Credentials "true" always;
            return 204;  # Retorna 204 sem corpo
        }

    }

    # Cabeçalhos de segurança adicionais
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
<
###
notes
###

1 - Change admin PWD

docker exec -it id_container bash
sudo runuser -u gvm -- gvmd --user=admin --new-password=MinhaSenhaSegura123

2 - New Users

docker exec -it id_container bash
sudo runuser -u gvm -- gvmd --create-user=admin
sudo runuser -u gvm -- gvmd --user=admin --new-password=MinhaSenhaSegura123

3 - Update Feed
docker exec -it da063a7356bf greenbone-feed-sync --type all

