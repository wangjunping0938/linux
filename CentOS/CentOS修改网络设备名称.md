将eth1修改为eth0
===


### 配置教程

编辑 `/etc/udev/rules.d/70-persistent-net.rules` 注释掉eth1的行保留eth0的行

重启系统 `reboot`
