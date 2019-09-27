set -ex

# install softwares
apt-get update
apt-get install -y vim supervisor

# install ss
https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.7.2/shadowsocks-v1.7.2-stable.x86_64-unknown-linux-musl.tar.xz
tar -C /usr/local/bin -xf shadowsocks-v1.7.2-stable.x86_64-unknown-linux-musl.tar.xz

# clone the shadowsocks configuration
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/shadowsocks.json -P /etc

# clone the supervisor config
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/supervisor.conf -O /etc/supervisor/conf.d/shadowsocks.conf
supervisorctl reload

# config iptables
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/iptables.rules -O /etc/iptables.test.rules
iptables-restore < /etc/iptables.test.rules
iptables -L
iptables-save > /etc/iptables.up.rules
echo -e "#!/bin/sh\n/sbin/iptables-restore < /etc/iptables.up.rules" > /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

# install fail2ban
apt-get install fail2ban  
wget --no-check-certificate https://raw.githubusercontent.com/sy264115809/ss-init/master/jail.local -P /etc/fail2ban
service fail2ban restart 
