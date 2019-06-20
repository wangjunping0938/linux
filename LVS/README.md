LVS负载均衡
===


## 简介

LVS (Linux Virtual Server) 由章文嵩博士主导的开源负载均衡项目

![LVS工作原理示意图](/LVS/pictures/LVS基本模型.jpg)


## LVS三种调度模式

- LVS-NAT (Network Address Transform) 网络地址转换模式
![NAT模式原理示意图](/LVS/pictures/LVS-NAT模式示意图.jpg)

- LVS-TUN (IP Tuneling) 隧道模式
![TUN模式原理示意图](/LVS/pictures/LVS-TUN模式示意图.jpg)

- LVS-DR (Direct Routing) 直连路由模式
![DR模式原理示意图](/LVS/pictures/LVS-DR模式示意图.jpg)


## LVS十种调度算法

- 静态调度算法
    - 轮询调度 (Round Robin) 简称'RR'
    
        请求平均分配至各个RS

    - 加权轮询调度 (Weight Round Robin) 简称'WRR'

        请求根据权重分配至各个RS

    - 源地址哈希调度 (SourceIP Hash) 简称'SH'

        根据源地址哈希表, 将同一请求分配至同一RS

    - 目标地址哈希调度 (Destination Hash) 简称'DH'

        根据请求目标地址哈希表, 将同一请求分配至同一RS

- 动态调度算法
    - 最小连接数 (least connections) 简称'LC'

        根据RS连接数负载, 将请求分配至负载最小的RS

    - 加权最小连接数 (Weighted Least Connection) 简称'WLC'
        
        根据权重将请求分配至连接数负载低的RS

    - 最小期望延迟 (Shortest Expection Delay) 简称'SED'

        WLC算法的改进版, 将请求分配至SED运算结果最小的RS

    - 最少队列调度 (Never Queue) 简称'NQ'

        SED算法的改进版, 直接将请求发送至连接数为0的RS

    - 基于局部的最少连接 (Locality-Based Least Connections) 简称'LBLC'
    
        相当于DH+LC算法

    - 带复制的基于局部性的最少连接 (Locality-Based Least Connections with Replication) 简称'LBLCR'
