#!/bin/bash 
 apt autoremove
 apt update -y
 apt install curl -y
 ipv4=`wget http://ipecho.net/plain -O - -q ; echo`
 ipv6=`ip addr show dev eth0 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d' | grep -v ^fe80 ; echo`
 ipv4addr=$ipv4/9993
 ipv6addr=$ipv6/9993
 curl -s https://install.zerotier.com | sudo bash
 identity=`cat /var/lib/zerotier-one/identity.public`
 echo "identity :$identity=============================================="
 wget https://github.com/zerotier/ZeroTierOne/archive/refs/tags/1.10.6.zip
 apt install unzip
 unzip 1.10.6.zip
 cd ./ZeroTierOne-1.10.6/attic/world/
 sed -i '/roots.push_back/d' ./mkworld.cpp
 sed -i '/roots.back()/d' ./mkworld.cpp 
 sed -i '85i roots.push_back(World::Root());' ./mkworld.cpp 
 sed -i '86i roots.back().identity = Identity(\"'"$identity"'\");' ./mkworld.cpp 
 sed -i '87i roots.back().stableEndpoints.push_back(InetAddress(\"'"$ipv4addr"'\"));' ./mkworld.cpp 
 sed -i '88i roots.back().stableEndpoints.push_back(InetAddress(\"'"$ipv6addr"'\"));' ./mkworld.cpp 
 sed -i '89i /*' ./mkworld.cpp 
 sed -i '105i */' ./mkworld.cpp 
 apt install nlohmann-json3-dev
 source ./build.sh
 ./mkworld
 mv ./world.bin ./planet
 \cp -r ./planet /var/lib/zerotier-one/
 \cp -r ./planet /root
 systemctl restart zerotier-one.service
 wget https://gitee.com/opopop880/ztncui/releases/download/ztncui_0.8.7/ztncui_0.8.7_amd64.deb
 dpkg -i ztncui_0.8.7_amd64.deb
 cd /opt/key-networks/ztncui/
 secret=`cat /var/lib/zerotier-one/authtoken.secret`
 echo "HTTPS_PORT = 3443" >>./.env
 echo "ZT_TOKEN = $secret" >>./.env
 echo "ZT_ADDR = 127.0.0.1:9993" >>./.env
 echo "NODE_ENV = production" >>./.env
 echo "HTTP_ALL_INTERFACES=yes" >>./.env
 systemctl restart ztncui