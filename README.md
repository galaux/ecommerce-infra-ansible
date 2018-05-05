example
==============

[Create a new instance](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://s3.eu-central-1.amazonaws.com/prestashop-data/example.template.yml&stackName=example)


Generate LetsEncrypt certificates
---------------------------------

`certbot certonly --webroot  -d blog.test2.example.com`


TODO
----

- run mysql script that removes test db
- backup results of mysqltuner etc to S3
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
- See if possible to change the mysql parameter 40xxxx to sthing like "40M"
- enhance CloudFormation with [Grouping and Labeling](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html)
- enable setup of any `*.shop.company` instance with automatic Route53 DNS creation/update!
- remove `lineinfile` option `backrefs` and rather use sthing such as `"^#?compress"` instead of `"^#compress"`
- optionally add collectd `collectdctl` config: `LoadPlugin unixsock` to be able to `collectdctl  getval test.example.com/df-root/df_complex-used`

- push latest monit conf from PROD to ansible
- in Ansible, put a _vanilla then modified_ /etc/monitrc file to git (simplifies the `yum updates`)
- perform a `yum update in prod`. Watchout for files:
  - /etc/php.ini.rpmnew
  - /etc/monitrc.rpmnew
  - /etc/php-fpm.d/www.conf.rpmnew
- write ansible role for vsftp


Things to remember when pushing Wordpress to PROD for the first time:
---------------------------------------------------------------------

- remember to run the following roles (for the following reasons)
  - base (adds `blog` as FQDN)
  - nginx (add `blog` config)
  - wordpress
  - backup instance
- watchout: a `yum update` might be needed for cacert to work. Watchout for the 3 previous files with rpmnew!
- remember to check that /var/www/{wordpress,prestashop} are group traversable (see changes made by commit for vsftpd and wordpress)
- check "blog" DNS entry for prod
- check prod certificates are on prod


TODO next
---------

- generate certificates and back them up for test
- scratch test and set-it up again brand new
- check:
  - ftp works
  - wordpress works
- generate certificates and back them up for prod
- create "blog" DNS entry for prod
- create "blog" DNS entry for test
- setup PS to log in /var/log/nginx/www.error.log and www.access.log
- setup cache for WP in nginx?

