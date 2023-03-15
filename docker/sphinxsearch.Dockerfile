FROM ubuntu:22.04

RUN apt-get update && apt-get install -y sphinxsearch netcat-openbsd

# This is where indexes are stored
VOLUME /var/lib/sphinxsearch

COPY sphinx.conf docker/sphinxsearch_docker_entrypoint.sh docker/sphinxsearch_docker_rotations.sh /home/

RUN sed -i 's/START=no/START=yes/' /etc/default/sphinxsearch

RUN chmod +x /home/sphinxsearch_docker_entrypoint.sh && chmod +x /home/sphinxsearch_docker_rotations.sh
CMD ["/home/sphinxsearch_docker_entrypoint.sh"]
