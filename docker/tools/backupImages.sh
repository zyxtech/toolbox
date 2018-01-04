#!/usr/bin/env bash
sudo docker images | sed -n '2,$p'|while IFS= read -r line; do
  id=$(echo "$line"|awk '{print $3}')
  name=$(echo "$line"|awk '{printf "%s_%s.tar",$1,$2}')
  sudo docker save -o $name $id
done