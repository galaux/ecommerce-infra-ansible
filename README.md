example
==============

[Create a new instance](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://s3.eu-central-1.amazonaws.com/prestashop-data/example.template.yml&stackName=example)


Situation and solution about how we perform backups
---------------------------------------------------

- At the moment:
  - prod instance:
    - install all backup snippets
    - run backup timer
    - have a `/usr/local/bin/backup-instance` that pushes to S3
  - test instances:
    - only install the certificates snippet
    - run the backup timer
- explanation:
  The reason to do so was to enable backup of up-to-date test certificates.
  There is no reason to want to have the up-to-date versions of the test certificates, we already have one (outdated) version on S3, this is enough because when we perform a certbot update, the age of the certif does not matter
- Solution:
  - whether test or prod, all instances should
    - have all snippets installed
    - have a `/usr/local/bin/backup-instance` script that takes a `--dry-run` (script should push to S3 only if this option is **not** set)
    - enable the backup timer that calls this script,
      - on prod without the `--dry-run`
      - on test, with the `--dry-run`

Situation with the renewal of certificates
------------------------------------------

- at the moment
  - _big mess_ whith whether certifcates are renewed between dev, test and prod instance
  - it works on PROD so _everything is OK_
  - it should work on `test* ` but no big deal if it does not because this is easy to fix manually
  - it should **not** work on dev because Ansible is going to try to immediatly renew the certif (which will fail for dev)
- solution: try to do less
  - dev instance should use self signed cert and thus never try to update anything
  - test should update once at boot
  - prod should update every day

Todo
----

- Implement solution for "situation and solution about how we perform backups" ↑
- solve "Situation withe the renewal of certificates"
- finish mod-security
- faire version sans AWS (?)
- faire version PS 1.7
