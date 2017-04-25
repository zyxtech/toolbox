#!/bin/bash

##sslocal for centos6
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
	cp /etc/resolv.conf auto_proxy
fi
vpn4IP="`dig vpn4.zyxtech.org @114.114.114.114|\
grep vpn4.zyxtech.org|grep -v 114.114.114.114 |
grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'|uniq `"
echo "nameserver $vpn4IP" > /etc/resolv.conf

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
nohup /usr/bin/sslocal -c auto_proxy/ssclient.json -d start &

#add epel centos6 and set privoxy and set env in /etc/profile
if [ ! -f "/etc/yum.repos.d/epel.repo" ];then
	rpm -Uvh http://download.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
fi
unset http_proxy https_proxy
if [ ! "`rpm -qa|grep privoxy`" ];then
	sed -i 's/^proxy=http:\/\/127.0.0.1:8118\/$/#proxy=http:\/\/127.0.0.1:8118\//' /etc/yum.conf
	yum install privoxy -y
fi
privoxy_count=`cat /etc/privoxy/config|sed -n "/^        forward-socks5   \/               127.0.0.1:10800 ./p"|wc -l`
if [ $privoxy_count = 0 ];then
	echo "        forward-socks5   /               127.0.0.1:10800 ." >> /etc/privoxy/config
fi
service privoxy restart
sed -i "s/^proxy/#proxy/g" /etc/yum.conf
if [ `sed -n '/^#proxy=http:\/\/127.0.0.1:8118\/$/p' /etc/yum.conf ` ];then
	sed -i 's/^#proxy=http:\/\/127.0.0.1:8118\/$/proxy=http:\/\/127.0.0.1:8118\//' /etc/yum.conf
else
	echo "proxy=http://127.0.0.1:8118/" >> /etc/yum.conf
fi
if [ ! "`sed -n "/http_proxy/p" /etc/profile`" ];then
	echo "export http_proxy=\"http://127.0.0.1:8118/\"" >> /etc/profile
	echo "export https_proxy=\"http://127.0.0.1:8118/\"" >> /etc/profile
fi

