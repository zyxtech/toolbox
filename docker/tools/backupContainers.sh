#!/usr/bin/env bash
sudo docker ps | sed -n '2,$p'|while IFS= read -r line; do
  id=$(echo "$line"|awk '{print $1}')
  name=$(echo "$line"|awk -v date="$(date +"%Y-%m-%d")" '{printf "%s_%s.tar",$2,date}')
  sudo docker export $id > $name
done
