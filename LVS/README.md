LVS负载均衡
===


## 简介

LVS (Linux Virtual Server) 是由章文嵩博士主导的开源负载均衡项目,
已经被集成至Linux内核

终端用户从外部访问公司的外部负载均衡服务器, 终端用户的web请求会发送至LVS调度器,
调度器根据预设算法将请求发送至后端某台web服务器,
终端用户访问LVS调度器虽然被转发至后端真实服务器, 但真实服务器连接相同存储,
提供相同服务, 用户最终得到的服务内容是一样的

LVS 3工作模式: NAT, TUN, DR

LVS 10中负载均衡调度算法:

    - 轮询调度: (Round Robin简称'RR'算法),
      当所有RS负载能力一致,调度器会将请求平均分配至每个RS

    - 加权轮询调度: (Weight Round Robin简称'WRR'算法),
      LVS根据每台RS服务器性能添加对应权重, 权重值越高, 被分配的请求越多

    - 最小连接调度: (Least Connections简称'LC'), 将新的请求分配至当前连接数最小的RS,
      RS每被分配一个请求其连接数加1,
      集群系统的RS性能相近,LC算法可以较好的均衡负载

    - 加权最小连接调度: (Weight Least Connections简称'WLC'),
      权重值代表各个RS的处理性能, RS默认权重值为1,
      WLC算法在调度新连接时,尽可能使已经建立连接数和其权值成比例,调度器可以自动询问RS负载情况,并动态调整其权值

    - 基于局部的最少连接: Locality-Based Least Connections('LBLC'),
      针对请求报文的目标IP地址的负载调度算法，主要用于Cacha集群系统,
      在RS负载平衡的情况下将同一IP的请求调度至同一台RS来提高各RS访问局部性和Cache命中率,
      若当前RS负载高,则使用最少连接原理将请求分配至其他RS

    - 带复制的基于局部性最少连接: (Locality-Based Least Connections with
      Replication 简称'LBLCR'),
      该算法也是针对目标IP地址的负载均衡,主用于Cache集群系统,
      与LBLC算法的不同在于要维护从一个目标IP到一组RS的映射,LBLC算法则维护从一个目标IP到一台RS的映射,
      按最小连接从RS组中选出一台RS,
      若RS没有超载则将请求分配至该RS,若RS超载,则按最小连接原则从整个RS集群中选出一台RS,并将该RS加入到这个RS组中,并将请i去发送至该RS,
      同时当该RS组有一段时间没有被修改,则将负载高的RS从RS组中删除,降低复制的程度

    - 目标地址哈希调度: (Destination Hashing 简称'DH')
      该算法根据请求的IP地址作为散列键(Hash Key),
      从静态分配的哈希表中找出对应RS，若该RS未超载,则请求分配至该RS,否则分配至其他RS

    - 源地址哈希调度: (Source Hashing 简称'SH') 该算法根据源IP作为散列键(Hash
      Key)
    从静态分配哈希表中找出对应RS,若该RS未超载,则将请求发送至该RS,否则返回空,与目标地址哈希算法相同

    - 最短期望延时: (Shortest Expected Delay 简称'SED')
      该算法基于WLC算法,假设3台RS,A, B, C 权重为1, 2, 3使用SED算法 A:(1+1)/1=2
      B: (1+2)/2=3/2 C: (1+3)/3=4/3 则把请求分配至结果最小的RS

    - 最少队列调度: (Never Queue简称'NQ') 该算法无需队列,
      如果有RS的连接数为0则直接分配,不需要进行SED运算

![LVS负载均衡结构图](/LVS/pictures/LVS负载均衡结构图.png "LVS负载均衡结构图")


## 基于NAT的LVS模式负载均衡

NAT (Network Address Translation) 即网络地址转换, 作用是通过修改数据报头,
使得内部私有IP地址可以访问外网, 及外部用户可以访问内部私有IP主机,
LVS负载调度器可以分配2块网卡配置不同IP地址,
网卡1设置私有IP与内部网络通过交换设备互连, 网卡2设置外网IP与外网联通

![LVS-NAT模式](/LVS/pictures/LVS-NAT模式.png "LVS-NAT模式")

**LVS-NAT模式访问流程**

1. 终端用户通过DNS解析至负载均衡器外网IP (LVS外网IP又称VIP (Vitual IP
Address)) 用户通过访问VIP即可连接后端真实服务器RS (Real Server)

2. 用户将请求发送至VIP, LVS根据算法将请求转发至RS,
转发前LVS会修改数据包中的目标地址及端口为选定的RS的IP地址及端口

3. RS将响应的数据包返回给LVS,
LVS将响应数据包源地址及源端口修改为VIP及VIP对应端口, 并将响应发送至用户,
LVS本身有一个连接Hash表, 记录之前的请求及转发信息,
这样保证同一个人的下一次请求可以转发至上次相同的RS

**配置教程**

client:`192.168.199.111`

LVS:IntranetIP=`192.168.235.128`, VIP`192.168.235.250`

RS:RS1_IP=`192.168.235.129`, RS2_IP=`192.168.235.130`

```Bash
# 临时开启路由转发,永久请编辑'/etc/sysctl.conf', 并修改'net.ipv4.ip_forward'的值为1
echo 1 > /proc/sys/net/ipv4/ip_forward

# 安装ipvsadm
yum install ipvsadm -y

# 没有双网卡的情况下配置VIP
ifconfig eth0:1 192.168.235.250/24

# 选择VIP,端口,算法
ipvsadm -A -t 192.168.235.250:80 -s rr

# 添加真实主机地址
ipvsadm -a -t 192.168.235.250:80 -r 192.168.235.129 -m
ipvsadm -a -t 192.168.235.250:80 -r 192.168.235.130 -m

# 启动服务
service ipvsadm start

# 
```

使用客户端进行测试

