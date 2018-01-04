#!/usr/bin/env bash
sudo docker ps -a|grep -v Up|awk '{print $1}'|sed '2,$p'|xargs sudo docker rm
sudo docker images|awk '{print $3}'|sed -n '2,$p'|xargs sudo docker rmi
