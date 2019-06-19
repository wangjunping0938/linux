CentOS配置网络yum源
===


### 配置教程

**配置本地yum源**
```Bash
cat > /etc/yum.repos.d/CentOS.Media.repo << EOF
[local-media]
name=Local Media
baseurl=file:///media
gpgcheck=0
enabled=1
EOF

# 挂在本地镜像安装下载工具
mount /dev/cdrom /media/
yum install wget -y
```

**配置网络yum源**
```Bash
# CentOS查看系统版本
yum install redhat-lsb-core -y
lsb_release -a|grep Release|awk '{print $2}'|awk -F"." '{print $1}'

# 备份本地源文件
cd etc/yum.repos.d
rename .repo .bak *.repo

# 安装网络yum源文件
wget -O etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i "s#\$releasever#7#g" etc/yum.repos.d/CentOS-Base.repo
rpm --import http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
```
