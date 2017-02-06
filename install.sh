# install softwares
apt-get update && apt-get install -y vim python-pip supervisor

# install shadowsocks
pip install shadowsocks

# clone the shadowsocks configuration
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/shadowsocks.json -P /etc

# clone the supervisor config
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/supervisor.conf -O shadowsocks.conf -P /etc/supervisor/conf.d

# config iptables
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/iptables.rules -O iptables.test.conf -P /etc
iptables-restore < /etc/iptables.test.rules
iptables -L
iptables-save > /etc/iptables.up.rules
echo -e "#!/bin/sh\n/sbin/iptables-restore < /etc/iptables.up.rules" > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

# install fail2ban
apt-get install fail2ban  
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/jail.local -P /etc/fail2ban
service fail2ban restart 
