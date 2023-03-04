# Gazelle
Gazelle is a web framework geared towards private BitTorrent trackers. Although naturally focusing on music, it can be modified for most needs. Gazelle is written in PHP, JavaScript, and MySQL.

Forked from: https://github.com/WhatCD/Gazelle

This repo is a work in progress to update the codebase and depenencies, dockerize it, and fix any bugs.

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
# When testing locally you can set up a local DNS mapping for this test domain
GAZELLE_SITE_HOST=myawesometracker.com
OCELOT_SITE_HOST=tracker.myawesometracker.com
# You can set the value of these 2 props to the file paths of SSL cert and private key.
# You can also set them to "null", in which case a self signed cert will be generated.
# Note that the same cert will be used for both domains, so make sure this cert is
# for a wildcard domain. And that both domains above belong to the same root domain.
GAZELLE_SSL_CERT_PATH=null
GAZELLE_SSL_PRIV_KEY_PATH=null
```

And then you must use the included docker compose wrapper script to build and launch all containers:
- `cd docker`
- `./docker_compose build`
- `./docker_compose up`

## SSL Tips
If you want to use Cloudflare's reverse proxy, then you can get an origin server SSL cert from them which is free and is valid for 15 years. It is a wildcard domain cert which means you can use it for both the web app and the tracker (assuming they both use the same wildcard domain). Note that only Cloudflare servers trust it though so you can't use it if you're not using Cloudflare's reverse proxy.

If you want to use Let's Encrypt (which is also free but only valid for 3 months) then use the following command line and make sure to give it a wildcard domain name like `*.example.com`:
```
sudo certbot certonly --manual --preferred-challenges dns
```

## Original WCD/Gazelle Change Log
You may have noticed that commits in the repository do not have descriptive messages. If you are looking for a change log of Gazelle, it can be [viewed here](https://raw.github.com/WhatCD/Gazelle/master/docs/CHANGES.txt).
