FROM mysql:8.0

COPY docker/db_initializer_docker_entrypoint.sh gazelle.sql /home/

WORKDIR /home
RUN chmod +x db_initializer_docker_entrypoint.sh

ENTRYPOINT []
CMD ./db_initializer_docker_entrypoint.sh
