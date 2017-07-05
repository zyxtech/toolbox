#!/usr/bin/env bash
# TESTED IN DOCKER UBUNTU:17.04
apt-get update
apt-get install -y ruby-full

apt-get install -y git
git clone https://github.com/current/vuash
#adduser vuash
grep -q "vuash" /etc/passwd
if [ $? -eq 0 ];then
echo "User vuash does already exist."
echo "please chose another username."
exit 70 #user exists
fi
groupadd vuash
useradd -p "vuash" -d /home/vuash -m -g vuash -s /bin/bash "vuash"
chown vuash:vuash -R vuash

cd vuash/
sed -i "s/^ruby/#ruby/" Gemfile
#https://github.com/bundler/bundler
gem install bundler
#https://github.com/copiousfreetime/hitimes/issues/48
#The compiler failed to generate an executable file.
apt-get install -y build-essential
#https://stackoverflow.com/questions/4827092/unable-to-install-pg-gem
#No pg_config... trying anyway
apt-get -y install libpq-dev
#https://github.com/flapjack/omnibus-flapjack/issues/72
#zlib is missing; necessary for building libxml2
apt-get install -y zlib1g-dev
#An error occurred while installing nokogiri
gem install nokogiri -v '1.6.6.2'

#Downloading rdoc-4.2.0 revealed dependencies not in the API or the lockfile
bundle update rdoc

gem install pg -v '0.18.2'


apt-get install -y postgresql postgresql-contrib
service postgresql start
su postgres<<EOF
psql -c "CREATE USER vuash WITH PASSWORD 'vuash';"
psql -c "ALTER USER vuash WITH SUPERUSER;"
psql -c "CREATE DATABASE vuash_development;"
EOF
apt-get install -y nodejs
su vuash<<EOF
bundle
bin/rake db:migrate RAILS_ENV=development
rails server --binding=0.0.0.0 -d
EOF