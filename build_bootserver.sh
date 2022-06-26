#!/bin/bash
#
# Run the ansible setup
#

cd ansible
sudo ansible-playbook bootserver.yml -i inventory.yml "$@"
