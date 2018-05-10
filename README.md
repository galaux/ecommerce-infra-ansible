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







ne changer le hostname que s'il n'est pas bon (idempotence)
idem pour les DNS (idempotence)



```
   certbot certonly \
     --standalone \
     -d 'test.example.com' \
     -d 'blog.test.example.com' \
     -d 'www.test.example.com' \
     -d 'admin.test.example.com' \
     -d 'test.example.fr' \
     -d 'blog.test.example.fr' \
     -d 'www.test.example.fr'
```
run ansible





TODO supprimer cette histoire "d'aller voir la dernière date de svgarde dans le fichier latest de S3"
- dans backup
  - ne pas créer le fichier latest
  - à la fin du script de backup, faire un `aws s3 cp --recursive …/$DATE …/latest`
- dans ansible
  - dans all.yml utiliser un `backup-path: "/latest"` que l'on peut overrider comme on veut à la date qu'on veut
  - dans role/base, plus besoin de tout ce bordel compliqué de déclaration de variable avec des if etc etc

TODO bouger toute référence de blog dans une branche à part qu'il faudra maintenir

TODO créer une adresse "tech" genre tech@example.com ou admin@example.com qui redirige vers les adresses de GDB et GAX

TODO dans le template CloudFormation (ainsi que dans all.yml)
- créer un Parameter `MonitSendsEmails`
  - Boolean
  - default: False
- créer un Parameter `CreateBackup`
  - Boolean
  - default: True
  - si =False → déployer le script normalement mais simplement commenter le cron
- DomainPrefix ne devrait en fait conditionner que la màj des DNS puisque c'est directement lié au préfix du domaine
- Cette modif permettra
  - lors des mises en prod, de popper une nouvelle instance de PROD qui n'écrasera pas les vrais backups de prod
  - arrêter de cacher plusieurs choses derrière ce nom de variable peu informatif :
    - le fait que Monit envoie ou non des emails
    - le fait que l'instance fait des backups ou pas


- créer un script qui vire toutes les "data"
  - (prévoir des sécurités – confirmations)
  - supprime les fichiers PS de /var/www/prestashop/
  - drop la DB de PS
  - drop data de collectd
  - … autre? Voir en fait ce qu'on sauvegarde dans le script de backup!
- créer un script qui installe les data depuis un backup S3
  - récupère une version donnée de S3
  - install PS et le dump de la DB
  - cette partie du script n'est pas un appel à ansible mais bel et bien un script et ansible aussi doit l'appeler

De cette manière, pour une màj de la PROD :
- créer nouvelle instance EC2 version "PROD" mais avec CreateBackup=False
- attendre que cette instance soit up, la rebooter
- vérifier que tout fonctionne (pour cette MEP il faudra générer et copier les nouveaux certificats à la main depuis actuelle prod vers nouvelle prod)
- sur future prod : lancer script qui drop les data
- sur actuelle prod :
  - la mettre en maintenance
  - lancer backup
- sur future prod, lancer script d'import des data
- switcher elastic IP
- enlever site de nouvelle prod de maintenance
- enable les backups sur la nouvelle prod en décommentant le cron
- supprimer ancienne prod
