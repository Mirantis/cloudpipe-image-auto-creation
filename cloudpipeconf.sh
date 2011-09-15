#!/bin/bash

###########################################
#
# Turn base ubuntu image into cloudpipe
#
###########################################


PACKAGES="vim openvpn vzctl bridge-utils unzip"

function eprint {
    echo "updating $FILE ..."
}


# first of all, install openvpn and vzctl

apt-get update

apt-get -y install $PACKAGES

if [ $? = "0" ]; then
    echo "successful packages installation!"
else
    echo "error during packages installation!"
    exit 1
fi


#edit /etc/network/interfaces

FILE="/etc/network/interfaces"
eprint

cat > $FILE << FILE_EOF
auto lo
iface lo inet loopback
 
auto eth0
iface eth0 inet manual
 
auto br0
iface br0 inet dhcp
  bridge_ports eth0
FILE_EOF


#edit /etc/rc.local

FILE="/etc/rc.local"
eprint

cat > $FILE << FILE_EOF

. /lib/lsb/init-functions
 
LOG=/tmp/rc.log
SUCCESS=false
COUNT=0
ADDR=\$(ip addr show br0 | egrep -o "inet [0-9\.]+" | cut -d' ' -f2)
echo "Booting..." > \$LOG
while [ \$COUNT -lt 10 ]; do
  echo "[count: \$COUNT]: Trying to download payload from userdata..." >> \$LOG
  wget --header="X-Forwarded-For: \$ADDR" http://169.254.169.254/latest/user-data -O /tmp/payload.b64 && SUCCESS=true
  [ \$SUCCESS = true ] && break
  COUNT=\`expr \$COUNT + 1\`
  sleep 5
done
 
echo "Sending Gratuitous ARP..." >> \$LOG
arpsend -U -i \$ADDR br0 -c 1
 
if [ \$SUCCESS = true ]; then
  echo "Decrypting base64 payload" >> \$LOG
  openssl enc -d -base64 -in /tmp/payload.b64 -out /tmp/payload.zip
 
  mkdir -p /tmp/payload
  echo Unzipping payload file >> \$LOG
  unzip -o /tmp/payload.zip -d /tmp/payload/
fi
if [ -e /tmp/payload/autorun.sh ]; then
  echo Running autorun.sh >> \$LOG
  cd /tmp/payload
  sh /tmp/payload/autorun.sh
else
  echo rc.local : No autorun script to run >> \$LOG
fi
 
exit 0
FILE_EOF


#edit /etc/openvpn/server.conf.template

FILE="/etc/openvpn/server.conf.template"
eprint
cat > $FILE << FILE_EOF
port 1194
proto udp
dev tap
up "/etc/openvpn/up.sh br0"
down "/etc/openvpn/down.sh br0"
 
persist-key
persist-tun

ca ca.crt
cert server.crt
key server.key
 
dh dh1024.pem
 
server-bridge VPN_IP DHCP_SUBNET DHCP_LOWER DHCP_UPPER
 
client-to-client
keepalive 10 120
comp-lzo
 
max-clients 1
 
user nobody
group nogroup
 
status openvpn-status.log
status openvpn.log
 
verb 3
mute 20
 
management 0.0.0.0 7505
FILE_EOF


#edit /etc/openvpn/up.sh

FILE="/etc/openvpn/up.sh"
eprint

cat > $FILE << FILE_EOF
#!/bin/sh
 
BR=\$1
DEV=\$2
MTU=\$3
/sbin/ifconfig \$DEV mtu \$MTU promisc up
/usr/sbin/brctl addif \$BR \$DEV
FILE_EOF

chmod a+x $FILE


#edit /etc/openvpn/down.sh

FILE="/etc/openvpn/down.sh"
eprint

cat > $FILE << FILE_EOF
#!/bin/sh
 
BR=\$1
DEV=\$2
 
/usr/sbin/brctl delif \$BR \$DEV
/sbin/ifconfig \$DEV down
FILE_EOF

chmod a+x $FILE


exit 0
