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

EMPTY :)

Nice to have
------------

- ne changer le hostname que s'il n'est pas bon (idempotence) idem pour les DNS (idempotence)
- lineinfile
  - remplacer les utilisation de "template" par "lineinfile" quand c'est un fichier qui initialement appartient à un package
  - ré-écrire les utilisations de lineinfile pour qu'elles soient plus claires (extraire le caractére de commentaire optionel du `with_items`)
  - voir s'il y a toujours besoin du `backrefs`
  - ré-écrire le lineinfile de phpmyadmin pour utiliser des `with_items` du style:
    `{ key: "auth_type" value: "config" }`
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
- see deactivation of apache engine in php.ini
- decrease backup script verbosity and/or configure logrotate with compression
- Create ansible "users" and update
  - monit conf (user email addresses)
  - create nominated accounts "owner" and "galaux" for mysql?
  - set these users in the htpasswd
- See if possible to change the mysql parameter 40xxxx to sthing like "40M"
- enhance CloudFormation with [Grouping and Labeling](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-cloudformation-interface.html)
- dans la conf postfix et autres endroits où on envoit des mails, faire envoyer les mails à guillaume+test@alaux.net ou guillaume@alaux.net en afonction de is_prod
- use Ansible `htpasswd` in roles/nginx
- voir si on ne peut pas utiliser le module ansible `service: state=reloaded` plutôt que des handlers
- sur prod : sauvegarder les IP blacklistées et les faire restorer par ansible
  - idée : ces infos devraient être backupées dans un fichier text commun `config.yml` dans lequel je pourrais aussi mettre la version de PS, …
- changer les "tel_service restart" par de simples "tel_service reload" 
- vérifier que Monit recharge bien sa conf quand on lui "systemctl reload monit"
- bouger les snippets collectd dans leurs roles respectifs
- voir si selinux n'est pas un process qu'il faudrait `notify` quand on change sa conf dans `base`

- Nginx optimisation
  - See this [Nginx tweak guide](https://tweaked.io/guide/nginx/)
    - see "client caching"
    - see "Tuning for PHP"
    - as advised, installer APC (see about that. Aren't there as many advice NOT to do so?)
  - Compare our Nginx conf with [official suggestion](https://github.com/PrestaShop/PrestaShop/blob/develop/docs/server_config/nginx.conf.dist)
  - [If need to optimize Nginx some more](https://linode.com/docs/web-servers/nginx/configure-nginx-for-optimized-performance/)


Procédure de MEP
----------------

- créer nouvelle instance EC2 "test"
  - BackupDate: latest_backup
  - Branch: develop
  - DomainPrefix: 'test'
  - InstanceType: 't2.micro'
- attendre que cette instance soit up, la rebooter
- vérifier que tout fonctionne (pour cette MEP il faudra générer et copier les nouveaux certificats à la main depuis actuelle prod vers nouvelle prod)
- sur nouvelle prod : lancer ansible sur le playbook `drop-data`
- sur actuelle prod :
  - mettre PS en maintenance
  - lancer script de backup
- lancer Ansible sur nouvelle prod **avec tous les roles** pour remettre la conf au carat
- switcher elastic IP
- enlever site de nouvelle prod de maintenance
- sur ancienne prod :
  - attention elle ne répond plus au nom de example.com !!!
  - relancer ansible pour la configurer en "test" (ou prévoire un autre subdomain genre `oldprod.example.com`?)
- éteindre/supprimer ancienne prod



- voir pourquoi j'ai retrouvé 30 "volumes" dans la console AWS (mes instances générées via CloudFormation génèrent-elles des backups automatiquement?)
