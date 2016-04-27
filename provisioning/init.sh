#!/bin/bash

echo
echo "Updating APT sources."
echo
apt-get update > /dev/null
echo
echo "Installing for Ansible."
echo
apt-get -y install software-properties-common
add-apt-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible
ansible_version=`dpkg -s ansible 2>&1 | grep Version | cut -f2 -d' '`
echo
echo "Ansible installed ($ansible_version)"

ANS_BIN=`which ansible-playbook`

if [[ -z $ANS_BIN ]]
    then
    echo "Whoops, can't find Ansible anywhere. Aborting run."
    echo
    exit
fi

echo
echo "Validating Ansible hostfile permissions."
echo
chmod 644 /vagrant/provisioning/hosts

# More continuous scroll of the ansible standard output buffer
export PYTHONUNBUFFERED=1

# $ANS_BIN /vagrant/provisioning/playbook.yml -i /vagrant/provisioning/hosts
# use -v for verbose
$ANS_BIN /vagrant/provisioning/playbook.yml --connection=local --extra-vars "target=127.0.0.1 ForwardAgent=yes"
if [ $? -eq 0 ]; 
    then
    echo
    echo "Post build tasks."
    echo
    su postgres -s $SHELL
    createuser --no-superuser --createdb --no-createrole www-data
    exit
fi