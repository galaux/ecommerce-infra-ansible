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
  - sur nouvelle prod : lancer ansible sur le playbook `drop-data`
  - sur actuelle prod :
    - mettre PS en maintenance via requête SQL
    - lancer script de backup
  - lancer Ansible sur nouvelle prod **avec tous les roles** pour remettre la conf au carat
  - switcher elastic IP
  - enlever site de nouvelle prod de maintenance via requête SQL
  - sur ancienne prod :
    - attention elle ne répond plus au nom de example.com !!!
    - relancer ansible pour la configurer en "test" (ou prévoire un autre subdomain genre `oldprod.example.com`?)
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
