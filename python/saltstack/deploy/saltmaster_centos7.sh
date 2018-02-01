#!/usr/bin/env bash

export saltrepo="https://repo.saltstack.com/yum"
export saltFpath="$saltrepo""/redhat/salt-repo-latest-2.el7.noarch.rpm"
#install salt-master
yum -y install "$saltFpath"
yum -y install salt-master
systemctl start salt-master
systemctl enable salt-master

#
type -a pip >> /dev/null 2>&1
if [ $? == 1 ];then
curl https://bootstrap.pypa.io/get-pip.py|python
yum -y install sshpass
fi
#
pip install -U pip setuptools wheel
pip install ruamel.yaml

#install nginx for share files
cp nginx.repo /etc/yum.repos.d/
yum -y install nginx
systemctl start nginx
systemctl enable nginx

cp minion /usr/share/nginx/html/
python yaml.py




