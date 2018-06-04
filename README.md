example
==============

[Create a new instance](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://s3.eu-central-1.amazonaws.com/prestashop-data/example.template.yml&stackName=example)


Generate LetsEncrypt certificates
---------------------------------

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


Nice to have
------------

- écrire script ou playbook qui transforme une instance de test en prod
- configurer les services suivants pour qu'ils utilisent l'adresse commune contact@example.com
  - letsencrypt
  - AWS route53
- voir logs postfix de prod qui dit qu'il faut rajouter un record DNS

Can wait
--------

- voir si le record SPF doit être un TXT ou un SPF
  - des réponses sur internet disent que le record SPF est déprécié et qu'il faut utiliser un TXT à la place
  - https://support.google.com/a/answer/33786
- See if possible to change the mysql parameter 40xxxx to sthing like "40M"
- enhance CloudFormation with [Grouping and Labeling](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html)
- ne changer le hostname que s'il n'est pas bon (idempotence) idem pour les DNS (idempotence)
- au sujet du bucket S3 "prestashop-data"
  - renommer le bucket "prestashop-data" en "backup_bucket: example-backup"
  - utiliser des sous-répertoires pour chaque role
  - Attention à la compat avec l'état actuel des backups
    D'ailleurs pour plus de simplicité
    - on pourrait créer un nouveau bucket
    - une fois la nouvelle hiérarchie mise en place, mv les anciens backups dans le nouveau bucket (et en enlever certains)
- voir s'il n'est pas intéressant de faire mettre à jour l'IP des instance de test dans le template cloudformation comme ça on peut ssh et pinger l'instance de test même si un des rôles ansible plante
- créer un compte galaux dans le BO PS
- transformer le compte BO PS "postmaster" en "guillaume" (GDB) ensuite virer toute occurence de "postmaster"
- run mysql script that removes test db
- backup results of mysqltuner etc to S3
- see deactivation of apache engine in php.ini
- Create ansible "users" and update
  - monit conf (user email addresses)
  - set these users in the htpasswd
- les infos textuelles que l'on backup devraient être backupées dans un fichier text commun `config.yml`
  - pour l'instant il n'y a que la version de PS donc pas besoin …
- monit peut vérifier les certificats SSL (voir la conf par défaut dans /etc/monitrc)
- voir s'il n'est pas possible de factoriser le morceaux de codes qui crééent les répertoires comme /etc/monit.d et /etc/collectd.d
- aucun service systemd ne devrait être "started" de façon autoritaire
  - au lieu de ça, chaque service qui l'utilise devrait déclarer un `notify restart` sur lui
  - ex :
    - les rôles nginx et php-fpm ne devraient pas déclarer `service started`
    - mais les rôles wordpress et prestashop, eux, devraient avoir un `notify restart nginx` et `… php-fpm`
    - ils devraient aussi avoir un notify reload sur leur propre conf
  - idem pour monit, collectd, … : ils ne devraient pas être started mais devraient avoir un `notify reload` sur leur propre conf
  - attention à mysql qui doit être démarré pour pouvoir créer les BD et users
    - chaque rôle qui a besoin de créer un user/bd peut vérifier qu'il est lancé!
- attention les volumes associés aux images ne sont pas "marked as delete when terminated" ce qui fait qu'ils persistent après que j'aie "terminate" l'instance!
- mettre rôle backup-instance après le rôle postfix pour éviter les "erreurs" dans les logs :
- php-fpm loggue dans www.access.log au lieu de www-access.log
- nginx loggue dans blog.error.log au lieu de blog-error.log
- php-fpm loggue tout www dans le même fichier : splitter en blog/ps
- configurer PS pour utiliser le postfix local?

- voir quels doivent être les droits de /etc/letsencrypt sur prod et les fixer
- attention quand on transforme une test en prod il reste les anciennes entrées de test dans /etc/postfix/virtual


About performances
------------------

- setup cache for WP in nginx?
- Nginx optimisation
  - See this [Nginx tweak guide](https://tweaked.io/guide/nginx/)
    - see "client caching"
    - see "Tuning for PHP"
    - as advised, installer APC (see about that. Aren't there as many advice NOT to do so?)
  - Compare our Nginx conf with [official suggestion](https://github.com/PrestaShop/PrestaShop/blob/develop/docs/server_config/nginx.conf.dist)
  - [If need to optimize Nginx some more](https://linode.com/docs/web-servers/nginx/configure-nginx-for-optimized-performance/)








Procédure de MEP
----------------

- rajouter 8.8.4.4 dans resolv.conf de ma machine
- créer nouvelle instance EC2 "test"
  - BackupDate: latest_backup
  - Branch: develop
  - DomainPrefix: 'test'
  - InstanceType: 't2.micro'
- attendre que cette instance soit up, la rebooter
- vérifier que tout fonctionne
- sur test : lancer ansible sur le playbook `drop-data`
- sur actuelle prod :
  - mettre PS en maintenance
  - lancer script de backup
- lancer Ansible sur test avec `domain_prefix=''`

- switcher elastic IP
- enlever site de nouvelle prod de maintenance
- sur ancienne prod :
  - attention elle ne répond plus au nom de example.com !!!
- éteindre/supprimer ancienne prod
