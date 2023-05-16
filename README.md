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
- `04`: does not have an apache site, but has a `/var/www/level04` directory, and the `level05` site points to that dir so...
- `05`: has an apache site, and a mailbox, and some weird files with ACLs that shares perms between `level05` and `flag05`: `/opt/openarenaserver` and `/usr/sbin/openarenaserver`
- `06`: `NULL`
- `07`: `NULL`
- `08`: `NULL`
- `09`: `NULL`
- `10`: `NULL`
- `11`: has some weird stuff running: `lua /home/user/level11/level11.lua`
- `12`: has an apache site and a `/var/www/level12` directory
- `13`: `NULL`
- `14`: `NULL`

About the apache sites, `level04` does not have a site, but the `level05` site
points to the `/var/www/level04` directory.

So here is the relevant Apache config:
```xml
/etc/apache2/mods-available/php5.conf-    <FilesMatch "\.ph(p3?|tml)$">
/etc/apache2/mods-available/php5.conf:  SetHandler application/x-httpd-php
--
/etc/apache2/mods-available/php5.conf-    <FilesMatch "\.phps$">
/etc/apache2/mods-available/php5.conf:  SetHandler application/x-httpd-php-source
--
/etc/apache2/mods-enabled/php5.conf-    <FilesMatch "\.ph(p3?|tml)$">
...skipping...
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        LogLevel warn
        CustomLog ${APACHE_LOG_DIR}/access.log combined
    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>
</VirtualHost>
lrwxrwxrwx 1 root root 31 Aug 30  2015 /etc/apache2/sites-enabled/level05.conf -> ../sites-available/level05.conf
<VirtualHost *:4747>
        DocumentRoot    /var/www/level04/
        SuexecUserGroup flag04 level04
        <Directory /var/www/level04>
                Options +ExecCGI
                DirectoryIndex level04.pl
                AllowOverride None
                Order allow,deny
                Allow from all
                AddHandler cgi-script .pl
        </Directory>
</VirtualHost>
lrwxrwxrwx 1 root root 31 Aug 30  2015 /etc/apache2/sites-enabled/level12.conf -> ../sites-available/level12.conf
<VirtualHost *:4646>
        DocumentRoot    /var/www/level12/
        SuexecUserGroup flag12 level12
        <Directory /var/www/level12>
                Options +ExecCGI
                DirectoryIndex level12.pl
                AllowOverride None
                Order allow,deny
                Allow from all
                AddHandler cgi-script .pl
        </Directory>
</VirtualHost>
```

Enumeration go brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr

*NOTE: more detailed info on each level README.md, this is just the initial system enum`

## Dirty COW

Hehe, this machine is runnig linux 3.2.0, hehe 7u7

##

[![forthebadge](https://forthebadge.com/images/badges/makes-people-smile.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/no-ragrets.svg)](https://forthebadge.com)
