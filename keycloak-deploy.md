###
1 - Deploy Tool With Docker
###
docker network create \
  --driver bridge \
  --subnet 10.43.102.0/24 \
  --gateway 10.43.102.1 \


docker run -d \
  --name keycloak \
  --restart unless-stopped \
  --network keycloak-net \
  -p 9898:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD='##senhanocofre##' \
  -e KC_DB=mysql \
  -e KC_DB_URL='jdbc:mysql://keycloak-db:3306/keycloak' \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD='##senhanocofre##' \
  -e KC_PROXY_HEADERS=xforwarded \
  -e KC_HTTP_ENABLED=true \
  -e KC_HOSTNAME=keycloak.grpereira.com.br \
  -v /opt/keycloak/keycloak-data/data:/opt/keycloak/data \
  -v /opt/keycloak/keycloak-data/providers:/opt/keycloak/providers \
  -v /opt/keycloak/keycloak-data/conf:/opt/keycloak/conf \
  -v /opt/keycloak/keycloak-data/export:/opt/keycloak/export \
  quay.io/keycloak/keycloak:24.0.4 \
  start


###
2 - Nginx Config
###

>

server {
    # Redireciona HTTP para HTTPS
    listen 80;
    server_name keycloak.tool.com.br www.keycloak.tool.com.br;

    return 301 https://$server_name$request_uri;
}

server {
    # Configuração para HTTPS
    listen 443 ssl;
    server_name keycloak.tool.com.br www.keycloak.tool.com.br;

    # Caminhos dos certificados SSL
    ssl_certificate /etc/ssl/certs/tool-cert-2025.pem;
    ssl_certificate_key /etc/ssl/certs/tool-key-2025.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Configuração do proxy reverso
    location / {
        proxy_pass http://127.0.0.1:9898;  # Substitua pela URL interna do container
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
