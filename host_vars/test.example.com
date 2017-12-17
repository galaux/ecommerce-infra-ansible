---
ssh_port: 22
fqdn: "test.example.com"
prestashop_version: "1.6.1.17"
backup_date: "2017-11-25-023001"
prestashop_tarballs:
  - classes.tgz
  - download.tgz
  - img.tgz
  - mails.tgz
  - modules.tgz
  - themes_simple-great.tgz
  - themes_example.tgz
  - translations.tgz
  - upload.tgz
www_path: "/var/www"
prestashop_path: "{{ www_path }}/prestashop"
monitoring_path: "{{ www_path }}/monitoring"
letsencrypt_path: "/etc/letsencrypt"
