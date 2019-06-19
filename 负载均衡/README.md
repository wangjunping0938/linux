LVS负载均衡
===


### 简介
LVS (Linux Virtual Server) 是由章文嵩博士主导的开源负载均衡项目,
已经被集成至Linux内核

终端用户从外部访问公司的外部负载均衡服务器, 终端用户的web请求会发送至LVS调度器,
调度器根据预设算法将请求发送至后端某台web服务器,
终端用户访问LVS调度器虽然被转发至后端真实服务器, 但真实服务器连接相同存储,
提供相同服务, 用户最终得到的服务内容是一样的

LVS 工作模式: NAT, TUN, DR

![LVS负载均衡结构图](/load_balanc/pictures/LVS负载均衡结构图.png "LVS负载均衡结构图")


### 基于NAT的LVS模式负载均衡
NAT (Network Address Translation) 即网络地址转换, 作用是通过修改数据报头,
使得内部私有IP地址可以访问外网, 及外部用户可以访问内部私有IP主机,
LVS负载调度器可以分配2块网卡配置不同IP地址,
网卡1设置私有IP与内部网络通过交换设备互连, 网卡2设置外网IP与外网联通

![LVS-NAT模式](/load_balanc/pictures/LVS-NAT模式.png "LVS-NAT模式")

- LVS-NAT模式访问流程
    1. 终端用户通过DNS解析至负载均衡器外网IP (LVS外网IP又称VIP (Vitual IP
       Address)) 用户通过访问VIP即可连接后端真实服务器RS (Real Server)
    2. 用户将请求发送至VIP, LVS根据算法将请求转发至RS,
       转发前LVS会修改数据包中的目标地址及端口为选定的RS的IP地址及端口
    3. RS将响应的数据包返回给LVS,
       LVS将响应数据包源地址及源端口修改为VIP及VIP对应端口, 并将响应发送至用户,
       LVS本身有一个连接Hash表, 记录之前的请求及转发信息,
       这样保证同一个人的下一次请求可以转发至上次相同的RS

- 配置教程
    client:`192.168.199.111`

    LVS:VIP`192.168.235.128`, IntranetIP``

    1. 临时开启路由转发,永久请编辑`/etc/sysctl.conf`, 并修改`net.ipv4.ip_forward`的值为1
    ```Bash
    echo 1 > /proc/sys/net/ipv4/ip_forward
    ```
