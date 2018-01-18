example
==============

- [Create a new instance](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://s3.eu-central-1.amazonaws.com/prestashop-data/example.template.yml&stackName=example)
- [Issue list](https://gitlab.com/galaux/shop-ami-user-data/issues)


TODO
----

- run mysql script that removes test db
- when/if writing apache role
  - do not forget to set .htaccess from S3
- once aws_user.sh is deprecated,remove s3 files
  - httpd_conf.tgz
  - monit_conf
  - settings.inc.php
- see php-fpm conf:
  - setup curl_json to retrieve /status-php-fpm info and display it in collectd
- in backup script: save collectd data and write role to restore them
  - will remove a manual step for next PROD migrations
  - no problem if we are setuping a TEST env, the won't collide as they will be displayed under a different FQDN
- backup results of mysqltuner etc to S3
- role ansible should be removed (now that it is done by cloud-formation template)
- report install of php56-pecl-acpu to ansible (do not forget that this must be enabled in PS backend … but this should be backuped by our DB dump)
- see deactivation of apache engine in php.ini
- Nginx optimisation
  - See this [Nginx tweak guide](https://tweaked.io/guide/nginx/)
    - see "client caching"
    - see "Tuning for PHP"
    - as advised, installer APC (see about that. Aren't there as many advice NOT to do so?)
  - Compare our Nginx conf with [official suggestion](https://github.com/PrestaShop/PrestaShop/blob/develop/docs/server_config/nginx.conf.dist)
  - [If need to optimize Nginx some more](https://linode.com/docs/web-servers/nginx/configure-nginx-for-optimized-performance/)
- decrease backup script verbosity and/or configure logrotate with compression
- Create ansible "users" and update
  - monit conf (user email addresses)
  - create nominated accounts "owner" and "galaux" for mysql?
  - set these users in the htpasswd
- In backup script: use dynamic list of tarballs
- See if possible to change the mysql parameter 40xxxx to sthing like "40M"
- remove `socket` from local .my.cnf if it is not compulsory
