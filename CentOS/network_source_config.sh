#! /bin/bash

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
