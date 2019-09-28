# sudo

# install ssr ===================>
# https://ssr.tools/31
wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
chmod +x shadowsocks-all.sh
./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log

# 启动SSR：
/etc/init.d/shadowsocks-r start
# 退出SSR：
/etc/init.d/shadowsocks-r stop
# 重启SSR：
/etc/init.d/shadowsocks-r restart
# SSR状态：
/etc/init.d/shadowsocks-r status
# 卸载SSR：
./shadowsocks-all.sh uninstall

# config
/etc/shadowsocks-r/config.json

# <=================== install ssr

# install bbr ===================>
# https://ssr.tools/199
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh && chmod +x bbr.sh && ./bbr.sh

# <=================== install bbr


# other vpn
# NordVPN: https://ewfjwxzc.tech/zh/
# VyprVPN: https://d7edb055-b9df-4586-a74b-6af4035a943c.realclearprivacy.biz/zh/buy-vpn
# ExpressVPN: https://www.gpxfwlj.xyz/zh-cn/order