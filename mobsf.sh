docker network create \
  --driver bridge \
  --subnet 10.43.106.0/24 \
  --gateway 10.43.106.1 \
  mobsf-net

docker run -d \
  --name mobsf \
  --restart=unless-stopped \
  --network mobsf-net \
  -p 8000:8000 \
  -v "/opt/mobsf/uploads:/home/mobsf/uploads" \
  -v "/opt/mobsf/static:/home/mobsf/static" \
  -v "/opt/mobsf/tools:/home/mobsf/tools" \
  -e SECRET_KEY="#########" \
  opensecurity/mobile-security-framework-mobsf:latest
