# snow-crash

## Info

As a developer, you may have to work on softwares that will be used by hundreds
of persons in your career.

If your software shows some weaknesses, these weaknesses will expose the users
through your software.

It is your duty to understand the different techniques used to exploit these
weaknesses in order to spot them and avoid them.

This project is a modest introduction to the wide world of cyber security.
A world where you’ll have no margin for errors.

This project aims to make you discover, through several little challenges,
cyber security in various fields.

Each level consist on obtaining the password of the next user, with a total of
15 users.

- Status: finished
- Result: 125%
- Observations: null

## Initial enum

Every good pentester (not me) knows that a good initial enum is key, so, before
even starting with level00, I enumarete the system (with `level00` user) using
the usual pentesting tools, here's what I got, before even starting:

- Ports 5151, 4646, 4747 and 80 are open, all webs excepts 5151, which ask for a passwd
- `/etc/passwd` has the password of the `flag01` user
- `00`: the `flag00` user has a readable file in `/usr/sbin/john`, some cipher text probably
- `01`: the `/etc/passwd` hash seems pretty cool
- `02`: `NULL`
- `03`: `NULL`
- `04`: does not have an apache site, but has a `/var/www/level04` directory
- `05`: has an apache site, and a mailbox, and some weird stuff in cron: `/opt/openarenaserver` and `/usr/sbin/openarenaserver`
- `06`: `NULL`
- `07`: `NULL`
- `08`: `NULL`
- `09`: `NULL`
- `10`: `NULL`
- `11`: has some weird stuff running: `lua /home/user/level11/level11.lua`
- `12`: has an apache site and a `/var/www/level12` directory
- `13`: `NULL`
- `14`: `NULL`

Enumeration go brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr

*NOTE: more detailed info on each level README.md, this is just the initial system enum`

## Dirty COW

Hehe, this machine is runnig linux 3.2.0, hehe 7u7

##

[![forthebadge](https://forthebadge.com/images/badges/makes-people-smile.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/no-ragrets.svg)](https://forthebadge.com)
