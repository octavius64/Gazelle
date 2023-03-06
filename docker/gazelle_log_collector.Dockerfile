FROM alpine:3.17

COPY gazelle_log_collector.sh /home/
RUN chmod +x /home/gazelle_log_collector.sh

CMD ["/home/gazelle_log_collector.sh"]
