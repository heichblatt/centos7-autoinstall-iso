#!/bin/bash

set -e

# finalize automatically installed system

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

DEFAULT_DOMAIN=example.com

echo Set hostname.
echo "Hostname (xxx."$DEFAULT_DOMAIN"):"
read hn
hostnamectl set-hostname "$hn"."$DEFAULT_DOMAIN"   

echo Set password for admin
passwd admin

echo Delete password for root, effectively disabling that account.
passwd -d root

echo Restore SELinux contexts everywhere
restorecon -R -p /

echo Refresh yum cache
yum makecache 

echo Configuring firewall.
systemctl enable firewalld
systemctl restart firewalld

echo Commit all changes in /etc
git config --global user.name "root@$hn.$DEFAULT_DOMAIN"
git config --global user.email root@$hn.$DEFAULT_DOMAIN
cd /etc
git add . -u
git commit -m "firstrun.sh: finalized system" 
