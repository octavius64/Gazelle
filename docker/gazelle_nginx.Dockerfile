FROM nginx:1.23

COPY config.template docker/gazelle_nginx_docker_entrypoint.sh /home/

RUN chmod +x /home/gazelle_nginx_docker_entrypoint.sh

ENTRYPOINT []
CMD /home/gazelle_nginx_docker_entrypoint.sh
