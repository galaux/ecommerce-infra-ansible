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
prestashop_root_path: "/var/www/html"
prestashop_path: "{{ prestashop_root_path }}/prestashop"
