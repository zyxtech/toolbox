service postgresql start
su vuash<<EOF
cd /vuash
rails server --binding=0.0.0.0 -d
EOF
tail -f /vuash/log/development.log