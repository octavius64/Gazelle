FROM octavius64/nginx_base:v1

COPY config.template nginx.conf docker/whitelist_ips.txt docker/nginx_docker_entrypoint.sh /home/
COPY docker/ssl_cert_tmp_store/fullchain.pem docker/ssl_cert_tmp_store/privkey.pem /home/

RUN chmod +x /home/nginx_docker_entrypoint.sh

ENTRYPOINT []
CMD ["/home/nginx_docker_entrypoint.sh"]
