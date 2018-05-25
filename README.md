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


Nice to have **for next PROD delivery**
---------------------------------------

- changer les crons pour des timers systemd


Nice to have
------------

- ne changer le hostname que s'il n'est pas bon (idempotence) idem pour les DNS (idempotence)
- remplacer les utilisation de "template" par "lineinfile" quand c'est un fichier qui initialement appartient à un package
- setup cache for WP in nginx?
- au sujet du bucket S3 "prestashop-data"
  - renommer le bucket "prestashop-data" en "backup_bucket: example-backup"
  - utiliser des sous-répertoires pour chaque role
  - Attention à la compat avec l'état actuel des backups
    D'ailleurs pour plus de simplicité
    - on pourrait créer un nouveau bucket
    - une fois la nouvelle hiérarchie mise en place, mv les anciens backups dans le nouveau bucket (et en enlever certains)
- configurer les services suivants pour qu'ils utilisent l'adresse commune contact@example.com
  - letsencrypt
  - AWS route53
- voir s'il n'est pas intéressant de faire mettre à jour l'IP des instance de test dans le template cloudformation comme ça on peut ssh et pinger l'instance de test même si un des rôles ansible plante
- voir s'il n'est pas possible d'utiliser une option de tar qui préserve les user/group comme ça plus besoin de faire de chown etc
- php-fpm log toutes les requêtes mais sans aucune information utile dans /var/log/php-fpm/www.access.log → désactiver les logs
- vérifier que les slow-queries de mysql sont bien enable
- setup DNS SPF record pour les instances de test
  - les configurer dans route53
  - les faire mettre à jour dans le script au démarrage des instances de test
- setup postfix and DNS MX record for .fr ???
    guillaume       → owner@example.com
    galaux          → guillaume@alaux.net
    contact         → contact@example.com → GDB + GAX
    postmaster      → owner@example.com # TODO à dégager
    root            → guillaume@alaux.net
    *               → owner@example.com
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


Procédure de MEP
----------------

- créer nouvelle instance EC2
  - AlertingSendsEmail: false
  - BackupDate: latest_backup
  - Branch: develop
  - CreateBackups: false (pour éviter qu'elle n'écrase les vrais backups actuels de PROD)
  - DomainPrefix: '' ← empty
  - InstanceType: 't2.micro'
- attendre que cette instance soit up, la rebooter
- vérifier que tout fonctionne (pour cette MEP il faudra générer et copier les nouveaux certificats à la main depuis actuelle prod vers nouvelle prod)
- sur nouvelle prod : lancer ansible sur le playbook `drop-data`
- sur actuelle prod :
  - mettre PS en maintenance
  - lancer script de backup
- configurer `~/.ssh/config` et `/etc/hosts` pour pouvoir ssh facilement sur la nouvelle prod et rajouter son nom de domaine temporaire dans fichier Ansible `hosts`
- lancer Ansible sur nouvelle prod **avec tous les roles** pour remettre la conf au carat (enable les emails par Monit, enable les backups de certifs et tous les backups, …)
- switcher elastic IP
- enlever site de nouvelle prod de maintenance
- sur ancienne prod
  - disable backups!
  - disable envoi de mails par monit
- éteindre/supprimer ancienne prod
