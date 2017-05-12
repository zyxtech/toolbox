#!/bin/bash

##sslocal for UBUNTU
##will set http_proxy and https_proxy and proxy in /etc/yum.conf
#input serverIP and server_port and password
if [ ! -f "config.json" ];then
	echo "input serverIP server_port password (space and serperator)"
	read INPUTINFO
	serverIP="`echo $INPUTINFO|awk '{FS = " " }{print $1}'`"
	server_port="`echo $INPUTINFO|awk '{FS = " " }{print $2}'`"
	password="`echo $INPUTINFO|awk '{FS = " " }{print $3}'`"
	echo "input http&https proxy,like http://httproxy:port/"
	read INPUTINFO
	proxy=$INPUTINFO
else
	config="`cat config.json`"
	serverIP="`echo $config|awk '{FS = " " }{print $1}'`"
	server_port="`echo $config|awk '{FS = " " }{print $2}'`"
	password="`echo $config|awk '{FS = " " }{print $3}'`"
	proxy="`echo $config|awk '{FS = " " }{print $4}'`"
fi
#configure nameserver
if [ ! -d auto_proxy ];then
	mkdir auto_proxy
fi
if [ ! -f auto_proxy/resolv.conf ];then
	sudo cp /etc/resolv.conf auto_proxy
fi
vpn4IP="`dig vpn4.zyxtech.org @114.114.114.114|\
grep vpn4.zyxtech.org|grep -v 114.114.114.114 |
grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'|uniq `"
sudo echo "nameserver $vpn4IP" > /etc/resolv.conf

#install ss client
export http_proxy="$proxy"
export https_proxy="$proxy"

if [ ! "`type -a pip  2>/dev/null`" ];then
	curl https://bootstrap.pypa.io/get-pip.py|python
	pip install git+https://github.com/shadowsocks/shadowsocks.git@master
	pip install shadowsocks
fi
#configure ssh client
cat <<EOF >auto_proxy/ssclient.json
{
"server":"$serverIP",
"server_port":$server_port,
"local_address":"127.0.0.1",
"local_port":10800,
"password":"$password",
"timeout":300,
"method":"aes-256-cfb",
"fast_open":true,
"workers":2
}
EOF
if [ "`ps aux|grep sslocal|grep -v grep|wc -l`" ];then
	kill `ps aux|grep sslocal|grep -v grep|awk '{print $2}'`
fi
nohup sslocal -c auto_proxy/ssclient.json -d start &

#add epel centos6 and set privoxy and set env in /etc/profile
#if [ ! -f "/etc/yum.repos.d/epel.repo" ];then
#	rpm -Uvh http://download.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
#fi
unset http_proxy https_proxy
if [ ! -f /etc/apt/apt.conf ];then
	sudo touch /etc/apt/apt.conf
fi
if [ ! "`dpkg -l|grep privoxy`" ];then
	sed -i 's/^Acquire::http::proxy "http:\/\/127.0.0.1:8118\/";$/#Acquire::http::proxy "http:\/\/127.0.0.1:8118\/";/' /etc/apt/apt.conf
	sed -i 's/^Acquire::https::proxy "http:\/\/127.0.0.1:8118\/";$/#Acquire::https::proxy "http:\/\/127.0.0.1:8118\/";/' /etc/apt/apt.conf
	sudo apt-get update
	sudo apt-get install privoxy -y
fi
privoxy_count=`sudo cat /etc/privoxy/config|sed -n "/^        forward-socks5   \/               127.0.0.1:10800 ./p"|wc -l`
if [ $privoxy_count = 0 ];then
	sudo echo "        forward-socks5   /               127.0.0.1:10800 ." >> /etc/privoxy/config
fi
service privoxy restart
sed -i "s/^Acquire/#Acquire/g" /etc/apt/apt.conf
if [ `sed -n '/^#Acquire::http::proxy "http:\/\/127.0.0.1:8118\/";$/p' /etc/apt/apt.conf ` ];then
	sed -i 's/^#Acquire::http::proxy "http:\/\/127.0.0.1:8118\/";$/Acquire::http::proxy "http:\/\/127.0.0.1:8118\/";/' /etc/apt/apt.conf
	sed -i 's/^#Acquire::https::proxy "http:\/\/127.0.0.1:8118\/";$/Acquire::https::proxy "http:\/\/127.0.0.1:8118\/";/' /etc/apt/apt.conf
else
	sudo cat <<EOF >/etc/apt/apt.conf
	Acquire::http::proxy "http://127.0.0.1:8118/";
	Acquire::https::proxy "http://127.0.0.1:8118/";
EOF
fi
if [ ! "`sed -n "/http_proxy/p" /etc/profile`" ];then
	echo "export http_proxy=\"http://127.0.0.1:8118/\"" >> /etc/profile
	echo "export https_proxy=\"http://127.0.0.1:8118/\"" >> /etc/profile
fi

