FROM nginx:1.23

RUN apt-get update && apt-get install -y netcat-openbsd

COPY config.template docker/nginx_docker_entrypoint.sh /home/

RUN chmod +x /home/nginx_docker_entrypoint.sh

ENTRYPOINT []
CMD /home/nginx_docker_entrypoint.sh
