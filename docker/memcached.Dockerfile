FROM memcached:1.6

# I'm not too sure but it looks like if you want to use socket files
# instead of TCP, then you have to use root?
USER root
WORKDIR /home

CMD memcached -u root -a 0777 -s /home/memcached_socket/memcached.sock
