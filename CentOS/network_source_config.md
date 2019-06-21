## CentOS安装网络yum源

```Bash
# 备份本地源
cd /etc/yum.repos.d
rename .repo .repo.bak *.repo

# 配置本地源
cat > /etc/yum.repos.d/CentOS.Media.repo << EOF
[local-media]
name=Local Media
baseurl=file:///media
gpgcheck=0
enabled=1
EOF

# 安装下载工具
mount /dev/cdrom /media/
yum install wget curl redhat-lsb-core -y

# 执行安装脚本
curl https://raw.githubusercontent.com/wangjunping0938/linux/master/CentOS/network_source_config.sh | bash
```
