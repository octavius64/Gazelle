# Gazelle
Gazelle is a web framework geared towards private BitTorrent trackers. Although naturally focusing on music, it can be modified for most needs. Gazelle is written in PHP, JavaScript, and MySQL.

Forked from: https://github.com/WhatCD/Gazelle

This repo is a work in progress to update the codebase and depenencies, dockerize it, and fix any bugs.

## Deployment Instructions
Clone submodules: `git submodule update --init`

Create a file named `secrets` with key value pairs at `docker/secrets`. Each secret must only contain alpha-numeric characters, and must be 32 characters long. Something like the following:

```ini
GAZELLE_ENCKEY=5iQRiYjQmy44ofLV9OyD7k7dp7f93zy4
GAZELLE_HOST=LnGeGxbzq3YfZ9AkKGUeOUWnO6jqaBBk
GAZELLE_REPORT_PASSWORD=Ak5vtJAWka4qJbKN3Y980BAzVDcBNUHq
GAZELLE_RSS_KEY=jI8UOZvXWDGkJ9G4AOolat0aBATU0gCw
GAZELLE_SCHEDULE_KEY=CVSs0j8FcziSxihbKfyVKZC2hrdI4aY1
GAZELLE_SITE_PASSWORD=8KHdOe7968UoNA73Rp6xWmbGgtfsktNR
GAZELLE_SITE_SALT=jPXKQ8Gkb29Qq2NZEHrIhBKRzRhlULz9
MYSQL_PASSWORD=CBBA8taEd5Sr4pEpD9UZbrGWkWwSJwPy
MYSQL_ROOT_PASSWORD=X6AKUKX0y4aJX4baPyh5MSxhEGp7s8GW
```

And then you must use the included docker compose wrapper script to launch all containers:
- `cd docker`
- `./docker_compose up`

## Original WCD/Gazelle Change Log
You may have noticed that commits in the repository do not have descriptive messages. If you are looking for a change log of Gazelle, it can be [viewed here](https://raw.github.com/WhatCD/Gazelle/master/docs/CHANGES.txt).
