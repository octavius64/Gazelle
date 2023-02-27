FROM nginx:1.23

RUN apt-get update && apt-get install -y netcat-openbsd

COPY config.template docker/nginx_docker_entrypoint.sh /home/
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/ssl_cert_tmp_store/fullchain.pem docker/ssl_cert_tmp_store/privkey.pem /home/

RUN chmod +x /home/nginx_docker_entrypoint.sh

ENTRYPOINT []
CMD /home/nginx_docker_entrypoint.sh
