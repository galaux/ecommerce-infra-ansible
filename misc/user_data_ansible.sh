#!/bin/bash

# TODO See how to run this in an AWS CloudFormation template

# ANSIBLE_DIR="example-ansible"
# ANSIBLE_GIT_URL="https://gitlab.com/example/$ANSIBLE_DIR"

# # TODO setup a token so that the git commands work
# if [ -d $ANSIBLE_DIR ]; then
#   cd $ANSIBLE_DIR
#   git pull
# else
#   git clone $ANSIBLE_GIT_URL
#   cd $ANSIBLE_DIR
# fi

yum --assumeyes update

# TODO add dependencies here and remove them from role `ansible-dependencies`
yum --assumeyes install \
  ansible

ansible-playbook \
  --connection=local \
  playbooks/apollo.yml
