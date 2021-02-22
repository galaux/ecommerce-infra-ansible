example
==============

[Create a new instance](https://eu-central-1.console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://s3.eu-central-1.amazonaws.com/prestashop-data/example.template.yml&stackName=example)


Local setup to use this playbook
--------------------------------

If generating self-signed certs (for a local VirtualBox instance), you will
need to `ansible-galaxy collection install community.crypto` on your local
machine.


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


2020-12-02 supposed situation of the code base
----------------------------------------------

See "2021-02-18 git branches summary" for an up to date summary of the situation

- I _think_ I remember I planed on applying the current "test2"/PS1.7 setup to
  this git repository but that I have actually never started it but thinking
  that it should be rather simple.
- As far as I remember I have not done it yet. Still today, I've had to add a
  specific config to Prestashop Nginx config ([this
  commit](https://gitlab.com/example/example-ansible/-/merge_requests/1/diffs?commit_id=1912bab816c59cfd22f9bded5358ee7e6f036904))
  so I've saved this commit in a brand new branch just pulled from `master`
  that should thus now be considered as the up-to-date branch for test2/PS1.7
  and where I should apply all the PS1.7 setup from test2
- Important note about the git branches:
  - it seems I used to work with branch `develop` – CloudFormation template
    uses `develop` – but I can't remember what for
  - it seems at the moment, `develop` is behind `master` with no conflict/mixup
    so I could just remove the use of `develop` all together and consider
    `master` is the most up-to-date branch that current prod (PS1.6) is used
    for
- Today, GDB mentions that « test2 is the future "prod" » so it looks like my
  plan was to let him configure and work on this instance and when he is ready
  I would just switch the route52 DNS to this one and deprecate the current 1.6
  prod.  This would be OK. I would just need to be sure I am able to bootstrap
  an instance of 1.7 (as well as an instance of 1.6 just for security in case
  we want to rollback) in one command on test or test2


2021-02-16 state of git branches
--------------------------------

See "2021-02-18 git branches summary" for an up to date summary of the situation

- as explained on the previous paragraph, branch ps1.7 is only one commit ahead
  of `master`. This is a commit to fix the `/fr` redirection in Nginx for test2
  (PS 1.7).
- this branch should thus **not** allow me to setup a fresh PS 1.7 but a 1.6
  (as it is actually just pulled from `master` which tracks 1.6). I've pulled
  this branch so that I would just have a place to store this commit (which
  once again belongs to PS 1.7 instances) but this branch does not hold **yet**
  the setup for a full blown 1.7.
- the current test2 (PS 1.7) must be an instance that I setup
  semi-automatically with Ansible with manual modifications that have not yet
  been written into Ansible.
- I need to add to this ps1.7 branch, all modifications that I've made to
  enable test2 to work with PS 1.7 (that should not be so complicated: just run
  Ansible from branch ps1.7 in dry mode, look at the reported diff and change
  Ansible code until it doesn't report any diff)


2021-02-16 Nice and complete guide on how to setup mail on CentOS
-----------------------------------------------------------------

- https://www.linuxbabe.com/redhat/run-your-own-email-server-centos-postfix-smtp-server


2021-02-16 ideas for future developments
----------------------------------------

- use Terraform to spin instances (test, test2 and prod).
  - This should enable me to get rid of clumsy scripts
    `update-instance-dns-record` and `update-dns-record` but also the
    CloudFormation template and thus improve my confidence in spinning a new
    instance.
- I need some sort of UI to enable GDB but also myself to spin up instances
  - use one/multiple of these? (no clue what this does or even if they conflict
    with each other)
    - https://app.terraform.io
      - I've setup an account today
      - https://app.terraform.io/app/example/workspaces/new
    - https://codeherent.tech/
    - https://www.terrahub.io/how-it-works/
  - if too complicated, I've read on Reddit that one can simply use Rundeck or
    any CI/CD tool


2021-02-16 left TODO for emails
-------------------------------

- get out of the SES _sandbox_
  - requested today, [conversation with AWS support](https://console.aws.amazon.com/support/home?#/case/?caseId=7998378901&displayId=7998378901&language=en)
- do we need to setup SPF/DKIM/DMARC for mailchimp emails?
  - doesn't seem to be necessary as one can see when displaying the _show
    original_ on Gmails that mailchimp uses its own domain name with its own
    SPF (so does AWS with `amazonses`). Showing the original on Gmails shows
    that both SPF and DKIM are ok on these.
- write quick summary of the current email/DNS setup
  - postfix on current prod
    - sends email with locally installed Postfix
    - has a SPF record pointing at the Prod IP
    - doesn't have DKIM (nor DMARC)
  - mail through SES
    - I've setup the domain example.com as verified by AWS
    - test2 is configured and able to send emails using an AWS IAM named
      `ses-smtp-user.example`.  AWS automatically configured this user
      to have privs to use an SMTP account that I've setup PS 1.7 to use (its
      credentials are stored in `../bn.md.gpg`)
    - test email sent to test-ses@alaux.net show both SPF and DKIM pass
    - I've thus also manually added a `_dmarc.example.com` record
      configured to send report and extended reports to both GDB and myself.
      The current policy is `none` but this mustn't be a problem as it seems
      downstream mail server are not required to follow the policy and I'm
      pretty sure they actually don't and make their own decisions.
    - see output of `nslookup -type=TXT _dmarc.example.com`
  - mailchimp
    - sends its mails from its own domain which has its own SPF and DKIM.
      Showing the original in gmail shows both pass so this should be ok
- [DMARC inspector](https://dmarcian.com/dmarc-inspector/)
- decommission postfix from all instances
  - watch-out:
    - systemd is setup to send alerts using Postfix
    - also Postfix handles the **incoming** mails to be forwarded to our
      respective gmail addresses


2021-02-18 git branches summary
-------------------------------

How branches should be used (basically, a regular _Git flow_ with its `develop`
branch – the reason for this is because we currently don't have any automatic
way to track which commit the prod is currently at which is usually done at
work by CircleCI. Once we manage some kind of automatic deployment, we could
switch to something similar to GitHub flow):

- `master` should track what **is currently** deployed in prod
- `develop` should track what **should be deployed next** in prod
- other _devs_ branches should be pulled from `develop`
- potential hot fixes should be pulled from `master` then backported into
  `develop`


PS 1.6 and 1.7 pages for Nginx conf (where one sees that the 1.6 one lacks the
conf to prevent using `tools` and such)

- https://devdocs.prestashop.com/1.7/basics/installation/nginx/
- http://doc.prestashop.com/display/PS16/System+Administrator+Guide


Work locally
------------

- start VirtualBox `AnsibleSeedbox2019`
- add its IP to `/etc/hosts`: `192.168.0.213 dev.example.com`
- check correct SSH client conf:
  ```
  Host dev.example.com
      Port                22
      User                centos
      IdentityFile        ~/.ssh/id_rsa_perso
      UserKnownHostsFile  /dev/null
      StrictHostKeyChecking no
  ```

Boto and aws once and for all!
------------------------------

- the `aws` CLI and the Ansible `aws_s3` are two unrelated things
- Ansible module `aws_s3`
  - requires packages `python2-botocore` and `python-boto3`
- `aws` CLI
  - exists in v1 and v2
  - v1 (don't use it) can be installed with pip:
    ```
    - name: awscli installed
      pip:
        virtualenv: "{{ virtualenv_path }}/awscli"
        name: awscli
    ```
  - v2 can be [installed manually (no package it seems)](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
    ```
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    ```
- If run from an EC2 instance, one does not need to configure credentials:
  [they are retrieved from the instance
  metadata](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-metadata.html):
  > When you run the AWS CLI from within an Amazon Elastic Compute Cloud
  > (Amazon EC2) instance, you can simplify providing credentials to your
  > commands. Each Amazon EC2 instance contains metadata that the AWS CLI can
  > directly query for temporary credentials. When an IAM role is attached to
  > the instance, the AWS CLI automatically and securely retrieves the
  > credentials from the instance metadata.

In conclusion:
- if one wants to run `aws` from CLI
  - install v2 with the given official AWS method that curls the source and hard-install it locally
- if one wants to run Ansible
  - install said 'boto' dependencies

- if on a real EC2 instance, no need to setup credentials, but if on
  VirtualBox, setup credentials and pay attention to which user you set it up
  for: Ansible will want `/root/.aws/`


2021-02-21 TODO fix web file owner
----------------------------------

At the moment, files on the SB are owned by `nginx:nginx` and files on shop are
owned by `apache:apache`. It seems this is wrong. Try to implement correct file
ownership as explained in this article:
https://www.getpagespeed.com/server-setup/nginx-and-php-fpm-what-my-permissions-should-be
