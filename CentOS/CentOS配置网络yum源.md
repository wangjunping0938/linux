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
rename .repo .repo.bak *.repo

# 安装网络yum源文件
wget http://mirrors.aliyun.com/repo/Centos-6.repo -O /etc/yum.repos.d/CentOS-Base.repo
sed -i "s#\$releasever#6#g" /etc/yum.repos.d/CentOS-Base.repo
rpm --import http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-6

# 清空并重新生成yum缓存
yum clean all && yum makecache && yum update
```
