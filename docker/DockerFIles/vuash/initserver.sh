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
