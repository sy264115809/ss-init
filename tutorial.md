# tutorial

本教程基于Debian发行版撰写

## 安全

### iptables

对`iptables`的配置可以参考[官方教程](https://wiki.debian.org/iptables)。

首先查看`iptables`的规则：

```shell
iptables -L
```

如果没有经过配置，那么`iptables`中应该是没有规则的：

```
 Chain INPUT (policy ACCEPT)
 target     prot opt source               destination
 Chain FORWARD (policy ACCEPT)
 target     prot opt source               destination
 Chain OUTPUT (policy ACCEPT)
 target     prot opt source               destination
```

我们创建一个新的规则：

```shell
vim /etc/iptables.test.rules
```

并按官方的建议配置：

```
*filter

# Allows all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT

# Accepts all established inbound connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allows all outbound traffic
# You could modify this to only allow certain traffic
-A OUTPUT -j ACCEPT

# Allows HTTP and HTTPS connections from anywhere (the normal ports for websites)
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

# Allows SSH connections 
# The --dport number is the same as in /etc/ssh/sshd_config
-A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# Now you should read up on iptables rules and consider whether ssh access 
# for everyone is really desired. Most likely you will only allow access from certain IPs.

# Allow ping
#  note that blocking other types of icmp packets is considered a bad idea by some
#  remove -m icmp --icmp-type 8 from this line to allow all kinds of icmp:
#  https://security.stackexchange.com/questions/22711
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# log iptables denied calls (access via 'dmesg' command)
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

# Reject all other inbound - default deny unless explicitly allowed policy:
-A INPUT -j REJECT
-A FORWARD -j REJECT

COMMIT
```

然后激活这个配置：

```shell
iptables-restore < /etc/iptables.test.rules
```

这个时候再使用`iptables -L`查看就可以看到新的配置了。

我们再把配置保存起来：

```shell
iptables-save > /etc/iptables.up.rules
```

并且让这个配置在系统重启后依然生效：

```shell
vim /etc/network/if-pre-up.d/iptables 
```

将以下内容添加到刚刚创建好的文件中：

```bash
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.up.rules
```

并另这个文件变为可执行的：

```shell
chmod +x /etc/network/if-pre-up.d/iptables  
```

即完成了对`iptables`的配置

### fail2ban

`fail2ban`是由Python语言开发监控软件，通过监控系统日志的错误登录信息来调用iptables屏蔽相应登录IP，以阻止某个IP不停尝试密码。这里用来防止暴力破解。

我们通过`apt-get`来安装：

```shell
apt-get install fail2ban  
```

安装完后fail2ban就自动开始运行。接下来配置fail2ban。

首先需要将配置`jail.conf`复制一份到`jail.local`（这是因为fail2ban升级时会覆盖旧的`jail.conf`而导致配置丢失，但`jail.local`不受影响）：

```shell
cd /etc/fail2ban  
cp jail.conf jail.local
```

打开`jail.local`文件后可看到方括号圈起来的`[DEFAULT]`、`[ssh]`、`[apache]`、`[vsftpd]`等等。其中`[DEFAULT]`的参数如下：

```ini
findtime = 6000  
#findtime ，对尝试登录ip在一定时间范围内监控。单位为秒。 
bantime  = 36000000  
#bantime  给垃圾ip设置阻止时间，单位为秒。建议至少设置一天
maxretry = 2  
#maxretry 尝试多少次错误密码后触发fail2ban。 默认是6次。
backend = polling  
#backend这个要设置为polling，默认是auto
action = iptables[name=SSH, port=ssh, protocol=tcp]  
```

其他`[ssh]`、`[apache]`、`[vsftpd]`下面都有一个`enabled`选项，如果想开启对应的监控则将`enabled = false`改为`enabled = true`。

其中`[SSH]`配置里加上一句：

```ini
action = iptables[name=SSH, port=ssh, protocol=tcp]
```

其他选项默认就OK。设置好后，重启fail2ban：

```shell
service fail2ban restart 
```

再看看`iptables —L`的变化：

```
Chain fail2ban-SSH (1 references)  
target     prot opt source               destination  
RETURN     all  --  anywhere             anywhere            

Chain fail2ban-ssh-ddos (1 references)  
target     prot opt source               destination  
RETURN     all  --  anywhere  
```

日志则在`/var/log/fail2ban.log`中查看。
