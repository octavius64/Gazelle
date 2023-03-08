# Gazelle
Gazelle is a web framework geared towards private BitTorrent trackers. Although naturally focusing on music, it can be modified for most needs. Gazelle is written in PHP, JavaScript, and MySQL.

Forked from: https://github.com/WhatCD/Gazelle

**This repo is a work in progress**

## Goals of this Fork
- Update the codebase and depenencies (PHP, MySQL, sphinxsearch, etc.)
- Dockerize it
- Make it easy to run for both development and production workloads

## Some Nice Features of this Fork
- Only one domain required for both the web app (Gazelle) and the BitTorrent tracker (Ocelot). Both apps use SSL by default.
    - This allows the entire system to run behind Cloudflare, which means no need to pay for SSL certs and no renewals required.
- One central way to configure many settings and secrets which are automatically propagated to many containers in the app.
- The `gzl_log` PHP function allows logging custom messages/variables to a separate container in debug mode (`gazelle_log_collector`).

## Deployment Instructions
Clone submodules: `git submodule update --init`

Create a file named `secrets` with key value pairs at `docker/secrets`. It should be owned by root, and permissions should be 600. Each secret must only contain alpha-numeric characters, and must be 32 characters long. Something like the following:

```ini
GAZELLE_ENCKEY=5iQRiYjQmy44ofLV9OyD7k7dp7f93zy4
GAZELLE_REPORT_PASSWORD=Ak5vtJAWka4qJbKN3Y980BAzVDcBNUHq
GAZELLE_RSS_KEY=jI8UOZvXWDGkJ9G4AOolat0aBATU0gCw
GAZELLE_SCHEDULE_KEY=CVSs0j8FcziSxihbKfyVKZC2hrdI4aY1
GAZELLE_SITE_PASSWORD=8KHdOe7968UoNA73Rp6xWmbGgtfsktNR
GAZELLE_SITE_SALT=jPXKQ8Gkb29Qq2NZEHrIhBKRzRhlULz9
MYSQL_PASSWORD=CBBA8taEd5Sr4pEpD9UZbrGWkWwSJwPy
MYSQL_ROOT_PASSWORD=X6AKUKX0y4aJX4baPyh5MSxhEGp7s8GW
```

Create a file named `config` with key value pairs at `docker/config`. Something like the following:

```ini
GAZELLE_DEBUG=1
# In production you will have to use a fully qualified domain name here.
# When testing locally you can set up a local DNS mapping for this test domain,
# Or use an IP address.
GAZELLE_SITE_HOST=10.0.0.123
# You can set the value of these 2 props to the file paths of SSL cert and private key.
# You can also set them to "null", in which case a self signed cert will be generated.
# You will have to figure out how to make your torrent client disable cert validation if
# using a self signed cert.
GAZELLE_SSL_CERT_PATH=null
GAZELLE_SSL_PRIV_KEY_PATH=null
```

Create a file named `whitelist_ips.txt` with IP address subnets at `docker/whitelist_ips.txt`.
If this file is empty, then no restrictions will be applied to source IP addresses.
This is useful when using a reverse proxy like Cloudflare, in which case we would only want
Cloudflare IPs to talk to our server. The list of Cloudflare IP addresses can be retrieved
from `https://www.cloudflare.com/ips-v4`

This is an example file with some whitelisted subnets:

```
173.245.48.0/20
103.21.244.0/22
103.22.200.0/22
103.31.4.0/22
```

And then you must use the included docker compose wrapper script to build and launch all containers:
- `cd docker`
- `./docker_compose build`
- `./docker_compose up`

## SSL Tips
If you want to use Cloudflare's reverse proxy, then you can get an origin server SSL cert from them which is free and is valid for 15 years.
Note that only Cloudflare servers trust it though so you can't use it if you're not using Cloudflare's reverse proxy.

If you want to use Let's Encrypt (which is also free but only valid for 3 months) then use the following command line:
```
sudo certbot certonly --manual --preferred-challenges dns
```

## Ocelot Development Tips
The current Docker setup allows making changes to the Ocelot source code, build it incrementally, and deploy it without rebuilding or restarting any containers.
You will have to make an edit to `docker-entrypoint.sh` inside `Ocelot/docker`. Look at the comment in that file for more info. After making that change,
you'll be able to follow this development workflow:
- Make changes to the source code (it is mounted read-only in the Ocelot container)
- Open up a shell in the container: `sudo docker exec -it gazelle-ocelot-1 /bin/bash`
- Run an incremental build: `make`
- Kill the current Ocelot process and wait for it to exit: `kill -SIGTERM $(pgrep ocelot)`
- Run the newly built Ocelot version:
    - `cp ocelot ocelot.live`
    - `./ocelot.live -c ocelot.cnf > /proc/1/fd/1 2> /proc/1/fd/2`
- In order to kill this new version of Ocelot, you can use Ctrl-C

## Other Tips
- PhpMyAdmin container is also available for more convenient DB management. It only listens on 127.0.0.1 though for security reasons, so you
  will have to forward that port to your local machine to access it. Something like this: `ssh -L 127.0.0.1:8080:127.0.0.1:8080 user@remote -N -v`.
  This will also ensure that everything is encrypted in transit, even though it's running without SSL.

## Original WCD/Gazelle Change Log
The original WCD change log is available here: docs/CHANGES.txt
