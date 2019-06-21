#! /bin/bash

# 配置本地源
cat > /etc/yum.repos.d/CentOS.Media.repo << EOF
[local-media]
name=Local Media
baseurl=file:///media
gpgcheck=0
enabled=1
EOF

# 挂载安装下载工具
mount /dev/cdrom /media/
yum install wget curl redhat-lsb-core -y

# 备份本地源
cd /etc/yum.repos.d
rename .repo .repo.bak *.repo

# 安装阿里云yum源
version=`lsb_release -a|grep Release|awk '{print $2}'|awk -F"." '{print $1}'`

wget http://mirrors.aliyun.com/repo/Centos-$version.repo -O /etc/yum.repos.d/CentOS-Base.repo

sed -i "s#\$releasever#$version#g" /etc/yum.repos.d/CentOS-Base.repo

rpm --import http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-$version

# 清空并重新生成缓存
yum clean all && yum makecache && yum update -y
