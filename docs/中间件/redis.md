# 什么是nosql

> NoSQL，泛指非关系型的数据库。随着互联网[web2.0](https://baike.baidu.com/item/web2.0/97695)网站的兴起，传统的关系数据库在处理web2.0网站，特别是超大规模和高并发的[SNS](https://baike.baidu.com/item/SNS/10242)类型的web2.0纯[动态网](https://baike.baidu.com/item/动态网)站已经显得力不从心，出现了很多难以克服的问题，而非关系型的数据库则由于其本身的特点得到了非常迅速的发展。NoSQL数据库的产生就是为了解决大规模数据集合多重数据种类带来的挑战，尤其是大数据应用难题。

# NoSQL的四大分类

##### KV键值对： 

- 新浪：==Redis==
- 美团：Redis + Tair
- 阿里，百度： Redis + memecache

##### 文档型数据库（bson格式  和 json一样）

- ==MongoDB==（一般必须要掌握）
  - MongoDB 是一个基于分布式文件存储的数据库，C++编写，主要用来处理大量的文档！
  - MongoDB 是一个介于关系型数据库和菲关系型数据库中中间的产品！MongoDB是菲关系型数据库中功能最丰富，最像关系行数据库的！
- ConthDB

##### 列存储数据库

- ==HBase==
- 分布式文件系统

##### 图关系数据库

- 不是存图形，放的是关系，比如：朋友圈社交网络，广告推荐！
- ==Neo4j==，InfoGrid

![img](https://gitee.com/lgaaip/img/raw/master//20200718164619.jpeg)

# Redis入门

## 概述

> Redis是什么？

Redis（Remote Dictionary Server )，即远程字典服务

是一个开源的使用ANSI [C语言](https://baike.baidu.com/item/C语言)编写、支持网络、可基于内存亦可持久化的日

志型、Key-Value[数据库](https://baike.baidu.com/item/数据库/103728)，并提供多种语言的API。

是当下最热门的NoSQL技术之一！也被人们称为结构化数据库！

> Redis能干嘛？

1. 内存存储，持久化，内存中是断电即失，所以说持久化很重要（rdb，aof）
2. 效率高，可以用于高速缓存 <table><tr><td bgcolor=orange>xiaoneng</td></tr></table>
3. 发布订阅系统
4. 地图信息分析
5. 计时器，计数器（浏览量！）
6. .....

> 特性

1. 多样的数据类型
2. 持久化
3. 集群
4. 事务
5. .....

==Redis推荐都是在Linux服务器上搭建的，我们是基于Linux学习==

## Windows安装

> 下载压缩包后解压即可，简简单单



## Linux安装

1. 下载tar包   `移动到linux 的 /home/Alan 目录`
2. 解压Redis的压缩包！程序一般放到opt目录下

```
mv 压缩包 /opt
```

![image-20200716160858674](https://gitee.com/lgaaip/img/raw/master//20200718164632.png)

3. 进入解压后的文件，可以看到redis的配置文件 redis.conf

![image-20200716161023413](https://gitee.com/lgaaip/img/raw/master//20200718164635.png)

4. 基本的环境安装

```linux
yum install gcc-c++  安装C++环境
make
```

> 报错

![image-20200716162455828](https://gitee.com/lgaaip/img/raw/master/img/20200718165455.png)

==解决方案：==

- 安装gcc套装

```
yum install cpp
yum install binutils
yum install glibc
yum install glibc-kernheaders
yum install glibc-common
yum install glibc-devel
yum install gcc
yum install make
```

- 升级gcc

```
yum -y install centos-release-scl

yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils

scl enable devtoolset-9 bash
```

==OK!==

![image-20200716162533429](https://gitee.com/lgaaip/img/raw/master/img/20200718164810.png)

```
make install
```

![image-20200716162557332](https://gitee.com/lgaaip/img/raw/master/img/20200718164815.png)

5. redis的默认安装路径 `usr/local/bin`

![image-20200716181444346](https://gitee.com/lgaaip/img/raw/master/img/20200718164817.png)

6. 将redis配置文件，复制到我们当前目录下

![image-20200716181730619](https://gitee.com/lgaaip/img/raw/master/img/20200718164820.png)

7. redis默认不是后台启动的，修改配置文件！

![image-20200716182311247](https://gitee.com/lgaaip/img/raw/master/img/20200718164823.png)

8. 启动Redis服务

![image-20200716182557786](https://gitee.com/lgaaip/img/raw/master/img/20200718164826.png)

9. 使用 ==redis-cli== 进行连接测试！

![image-20200716182815113](https://gitee.com/lgaaip/img/raw/master/img/20200718164829.png)

10. 查看redis的进程是否开启

![image-20200716182922167](https://gitee.com/lgaaip/img/raw/master/img/20200718164840.png)

11. 如何关闭redis服务？

![image-20200716183028463](https://gitee.com/lgaaip/img/raw/master/img/20200718164843.png)

12. 再次查看redis的进程

![image-20200716183132687](https://gitee.com/lgaaip/img/raw/master/img/20200718164845.png)

## 测试性能

**redis-benchmark**是一个压力测试工具！

官方自带的性能测试工具！

redis-benchmark命令参数

`菜鸟教程`

![image-20200717111931711](https://gitee.com/lgaaip/img/raw/master/img/20200718164847.png)

简单测试一下：

```bash
# 测试：100个并发连接  100000请求
redis-beachmark -h localhost -p 6379 -c 100 -n 100000
```

![image-20200717165055676](https://gitee.com/lgaaip/img/raw/master/img/20200718164851.png)

>  如何查看这些分析！

![image-20200717165404496](https://gitee.com/lgaaip/img/raw/master/img/20200718164854.png)

## 基础的知识

redis默认有16个数据库

![image-20200717165948524](https://gitee.com/lgaaip/img/raw/master/img/20200718164857.png)

默认使用的是第0个数据库

可以使用select进行切换数据库

![image-20200717170302361](https://gitee.com/lgaaip/img/raw/master/img/20200718164859.png)

==清空当前数据库   flushdb              清除全部数据库内容  flushall==

![image-20200717170442144](https://gitee.com/lgaaip/img/raw/master/img/20200718164901.png)



> Redis是单线程的！

明白redis是很快的，Redis是基于内存操作的，CPU不是Redis性能瓶颈，Redis的瓶颈是根据机器的内存和网络带宽，既然可以使用单线程来实现，所以就使用单线程了！

Redis是C语言写的，官方提供的数据是 100000+ 的QPS，这个完全不比同样是使用key-value的Memecache差！

`Redis为什么单线程还这么快？`

1. 误区1：高性能的服务器一定是多线程的？

2. 误区2：多线程（CPU上下文会切换）一定比单线程效率高！

   CPU>内存>硬盘的速度要有所了解

   核心：redis是将所有的数据全部放在内存中的，所以说使用单线程去操作效率就是最高的，多线程（CPU上下文切换：耗时的操作！），对于内存系统来说，如果没有上下文切换效率就是最高的！多次读写都是在一个CPU上的，在内存情况下，这个是最佳的方案！

# 五大数据类型

> 官方介绍

Redis 是一个开源（BSD许可）的，内存中的数据结构存储系统，它可以用作数据库、缓存和消息中间件。 它支持多种类型的数据结构，如 [字符串（strings）](http://www.redis.cn/topics/data-types-intro.html#strings)， [散列（hashes）](http://www.redis.cn/topics/data-types-intro.html#hashes)， [列表（lists）](http://www.redis.cn/topics/data-types-intro.html#lists)， [集合（sets）](http://www.redis.cn/topics/data-types-intro.html#sets)， [有序集合（sorted sets）](http://www.redis.cn/topics/data-types-intro.html#sorted-sets) 与范围查询， [bitmaps](http://www.redis.cn/topics/data-types-intro.html#bitmaps)， [hyperloglogs](http://www.redis.cn/topics/data-types-intro.html#hyperloglogs) 和 [地理空间（geospatial）](http://www.redis.cn/commands/geoadd.html) 索引半径查询。 Redis 内置了 [复制（replication）](http://www.redis.cn/topics/replication.html)，[LUA脚本（Lua scripting）](http://www.redis.cn/commands/eval.html)， [LRU驱动事件（LRU eviction）](http://www.redis.cn/topics/lru-cache.html)，[事务（transactions）](http://www.redis.cn/topics/transactions.html) 和不同级别的 [磁盘持久化（persistence）](http://www.redis.cn/topics/persistence.html)， 并通过 [Redis哨兵（Sentinel）](http://www.redis.cn/topics/sentinel.html)和自动 [分区（Cluster）](http://www.redis.cn/topics/cluster-tutorial.html)提供高可用性（high availability）。

## Redis-key

![image-20200717200227450](https://gitee.com/lgaaip/img/raw/master/img/20200718164906.png)

```bash
127.0.0.1:6379> keys *
1) "age"
127.0.0.1:6379> type age   #查看age 的类型
string

```

> 不会的命令在官网可以查

![image-20200717200454982](https://gitee.com/lgaaip/img/raw/master/img/20200718164910.png)



## String（字符串）

> 基本命令

```bash
127.0.0.1:6379> set key1 v1   #设置值
OK
127.0.0.1:6379> get key1   #获得值
"v1"
127.0.0.1:6379> keys *   #获得全部的key
1) "key1"
2) "age"
127.0.0.1:6379> exists key1 #判断某一个key是否存在
(integer) 1
127.0.0.1:6379> append key1 v2  #往某个key追加一个字符串  （如果当前key不存在，相当于set key）
(integer) 4
127.0.0.1:6379> get key1         
"v1v2"
127.0.0.1:6379> strlen key1  #获取key 的长度
(integer) 4
################################################################
127.0.0.1:6379> set views 0
OK
127.0.0.1:6379> get views
"0"
127.0.0.1:6379> incr views     # 自增1  
(integer) 1
127.0.0.1:6379> get views
"1"
127.0.0.1:6379> decr views    #自减1
(integer) 0
127.0.0.1:6379> get views
"0"
127.0.0.1:6379> incrby views 10   # views=views+10  指定增量
(integer) 10
127.0.0.1:6379> get views
"10"
127.0.0.1:6379> decrby views 5    # views=views-5  指定减量
(integer) 5
127.0.0.1:6379> get views
"5"
################################################################
字符串的范围  range
127.0.0.1:6379> set key1 "hello,alan"
OK
127.0.0.1:6379> get key1
"hello,alan"
127.0.0.1:6379> getrange key1 0 5           # 截取字符串从 [0，5]
"hello,"
127.0.0.1:6379> getrange key1 0 -1          # 获取整个字符串 和 get key一样
"hello,alan"

替换！
127.0.0.1:6379> set key2 abcdefg
OK
127.0.0.1:6379> setrange key2 1 xx  #将b替换成xx
(integer) 7
127.0.0.1:6379> get key2
"axxdefg"
127.0.0.1:6379> 
################################################################
setex （set with expire）# 设置过期时间
setnx （set if not exist） # 不存在在设置（在分布式锁中会常常使用！）

127.0.0.1:6379> setex key3 30 hello          #设置key3过期时间
OK
127.0.0.1:6379> ttl key3
(integer) 25
127.0.0.1:6379> setnx mykey redis          # 不存在mykey 所以设置
(integer) 1
127.0.0.1:6379> setnx key2 1                # key2存在  所以设置失败
(integer) 0
127.0.0.1:6379> ttl key3
(integer) -2
################################################################
mset
mget

127.0.0.1:6379> keys *
(empty array) 
127.0.0.1:6379> mset k1 v1 k2 v2        # 同时设置多个值
OK
127.0.0.1:6379> keys *
1) "k1"
2) "k2"
127.0.0.1:6379> mget k1 k2            # 同时获取多个值
1) "v1"
2) "v2"
127.0.0.1:6379> msetnx k1 v1 k3 v3   # msetnx 原子性才做  要么一起成功 要么一起失败
(integer) 0
127.0.0.1:6379> keys *
1) "k1"
2) "k2"

对象
set user:1 {name:zhangsan,age:3}
巧妙的设计key -->  user:id:属性
127.0.0.1:6379> mset user:1:name zhangsan user:1:age 2
OK
127.0.0.1:6379> mget user:1:name user:1:age
1) "zhangsan"
2) "2"
###############################################################
getset  #先get再set

127.0.0.1:6379> getset db redis    # 不存在db 则 输出null 并设置 db为redis
(nil)
127.0.0.1:6379> get db
"redis"
127.0.0.1:6379> getset db redis2   # 获取原来的db  然后设置 db 为 redis2
"redis"
127.0.0.1:6379> get db
"redis2"
```

String的使用场景： 

- 计数器
- 统计多单位的数量
- 粉丝量
- 对象缓存存储

## List

基本的数据类型，列表

在redis里面，我们可以把List当成栈，队列，阻塞队列

所有的list命令都是以 l 开头的

```bash
127.0.0.1:6379> keys *
(empty array)
127.0.0.1:6379> lpush list one   # 将一个或多个值放在list的头部
(integer) 1
127.0.0.1:6379> lpush list two
(integer) 2
127.0.0.1:6379> lpush list thress
(integer) 3
127.0.0.1:6379> lrange list 0 -1   # 获取list中的值！
1) "thress"
2) "two"
3) "one"
127.0.0.1:6379> lrange list 0 1   # 通过区间获取list的值
1) "thress"
2) "two"
127.0.0.1:6379> rpush list right   # 将一个或多个值放在list的尾部
(integer) 4
127.0.0.1:6379> lrange list 0 -1
1) "thress"
2) "two"
3) "one"
4) "right"
##################################################################
lpop
rpop

127.0.0.1:6379> lrange list 0 -1
1) "thress"
2) "two"
3) "one"
4) "right"
127.0.0.1:6379> lpop list               # 移除list 的第一个元素
"thress"
127.0.0.1:6379> rpop list                 # 移除list 的最后一个元素
"right"
127.0.0.1:6379> lrange list 0 -1
1) "two"
2) "one"
##################################################################
lindex  # 获取list对应下标的值

127.0.0.1:6379> lrange list 0 -1
1) "two"
2) "one"
127.0.0.1:6379> lindex list 1
"one"
127.0.0.1:6379> lindex list 0
"two"
127.0.0.1:6379> lindex list 3
(nil)
#################################################################
llen   # 获取list 的长度
127.0.0.1:6379> lrange list 0 -1
1) "two"
2) "one"
127.0.0.1:6379> llen list
(integer) 2
###############################################################
移除指定的值！

127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "three"
3) "two"
4) "one"
127.0.0.1:6379> lrem list 1 one                  #移除 list中指定的一个值
(integer) 1
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "three"
3) "two"
127.0.0.1:6379> lrem list 2 three                 # 移除两个指定的值
(integer) 2
127.0.0.1:6379> lrange list 0 -1
1) "two"
##################################################################
trim 修剪

127.0.0.1:6379> Rpush list hello hello1 hello2 hello3
(integer) 4
127.0.0.1:6379> lrange list 0 -1
1) "hello"
2) "hello1"
3) "hello2"
4) "hello3"
127.0.0.1:6379> ltrim list 1 2         # 通过下标截取指定的长度  list已经被截断了，只剩下了指定的长度的元素了
OK
127.0.0.1:6379> lrange list 0 -1
1) "hello1"
2) "hello2"
##################################################################
rpoplpush  # 移除列表的最后一个元素 并移动到新的列表中

127.0.0.1:6379> lpush list hello hello1 hello2
(integer) 3
127.0.0.1:6379> rpoplpush list other
"hello"
127.0.0.1:6379> lrange list 0 -1
1) "hello2"
2) "hello1"
127.0.0.1:6379> lrange other 0 -1
1) "hello"
##################################################################
lset  # 将列表中指定下标的值替换为另外的一个值  更新操作
127.0.0.1:6379> exists list
(integer) 0
127.0.0.1:6379> lset list 0 item               # 不存在此列表 为报错
(error) ERR no such key
127.0.0.1:6379> lpush list value1
(integer) 1
127.0.0.1:6379> lrange list 0 0
1) "value1"
127.0.0.1:6379> lset list 0 item             # 存在此下标的值  则改变值
OK
127.0.0.1:6379> lrange list 0 0
1) "item"
127.0.0.1:6379> lset list 2 o                   # 不存在此下标的值  失败
(error) ERR index out of range
##################################################################
linsert # 将某个具体的值插入到某个值的前面或者后面

127.0.0.1:6379> rpush mylist hello world
(integer) 2
127.0.0.1:6379> linsert mylist before world other
(integer) 3
127.0.0.1:6379> lrange mylist 0 -1
1) "hello"
2) "other"
3) "world"
127.0.0.1:6379> linsert mylist after world hi
(integer) 4
127.0.0.1:6379> lrange mylist 0 -1
1) "hello"
2) "other"
3) "world"
4) "hi"

```

> 小结

- 他实际上是一个链表， 在某个结点的前面或者后面插入， 或者从左边或右边 都可以插入值
- 如果key不存在，创建新的链表
- 如果key存在，新增内容
- 如果移除了所有值；空链表，也代表不存在！
- 在两边插入或者改动值，效率最高！中间元素，相对来说效率会更低一点

消息排队！ 消息队列 Lpush Rpop   栈  Lpush  Lpop

## Set（集合）

set中的值是不能重复的！

```bash
127.0.0.1:6379> sadd myset hello             #set集合中添加元素
(integer) 1
127.0.0.1:6379> sadd myset alan GodAlan
(integer) 2
127.0.0.1:6379> smembers myset                 # 查看set中的所有值
1) "alan"
2) "hello"
3) "GodAlan"
127.0.0.1:6379> sismember myset hello      # 判断某个值是不是在set中
(integer) 1
127.0.0.1:6379> sismember myset a
(integer) 0
#########################################
127.0.0.1:6379> scard myset             # 获取set集合中的数量
(integer) 3
##########################################
srem

127.0.0.1:6379> srem myset hello                    # 移除set集合中指定的元素
(integer) 1
127.0.0.1:6379> scard myset
(integer) 2
127.0.0.1:6379> smembers myset
1) "alan"
2) "GodAlan"
#############################################
set   无序不重复集合，抽随机！

127.0.0.1:6379> srandmember myset          # 随机抽出一个元素（最后面可以加数量）
"GodAlan"
127.0.0.1:6379> srandmember myset
"GodAlan"
127.0.0.1:6379> srandmember myset
"alan"
######################################################
删除指定的key  随机删除key！

127.0.0.1:6379> smembers myset
1) "alan"
2) "GodAlan"
127.0.0.1:6379> spop myset        # 随机删除集合中的元素
"alan"
127.0.0.1:6379> spop myset
"GodAlan"
127.0.0.1:6379> smembers myset
(empty array)
######################################################
将一个指定的元素  移动到另外一个set中

127.0.0.1:6379> sadd myset hello world alan
(integer) 3
127.0.0.1:6379> sadd myset2 set2
(integer) 1
127.0.0.1:6379> smove myset myset2 alan            #将myset中的alan 移动到myset2
(integer) 1
127.0.0.1:6379> smembers myset
1) "world"
2) "hello"
127.0.0.1:6379> smembers myset2
1) "alan"
2) "set2"
######################################################
微博，B站  共同关注！（并集）
数字集合类：
- 差集
- 交集
- 并集

127.0.0.1:6379> sadd key1 a b c            
(integer) 3
127.0.0.1:6379> sadd key2 b d e
(integer) 3
127.0.0.1:6379> sdiff key1 key2         # 差集
1) "a"
2) "c"
127.0.0.1:6379> sinter key1 key2           # 交集
1) "b"
127.0.0.1:6379> sunion key1 key2      # 并集
1) "a"
2) "c"
3) "d"
4) "b"
5) "e"
```

微博，A用户将所有关注的人都放在一个set集合中！将它的粉丝也放在一个集合中！

共同关注，共同爱好，推荐好友

## Hash（哈希）

Map集合，key-Map集合！ 和 key-value一样 只是value是map集合

```bash
127.0.0.1:6379> hset myhash field1 alan            # set一个哈希表 字段+值
(integer) 1
127.0.0.1:6379> hget myhash field1         # 获取一个字段
"alan"
127.0.0.1:6379> hmset myhash field1 hello field2 world  # set多个字段+值
OK
127.0.0.1:6379> hmget myhash field1 field2        # get多个字段值
1) "hello"
2) "world"
127.0.0.1:6379> hgetall myhash     # 获取整个哈希表中的 字段+值
1) "field1"
2) "hello"
3) "field2"
4) "world"
127.0.0.1:6379> hdel myhash field1      # 删除哈希中 指定的字段
(integer) 1
127.0.0.1:6379> hgetall myhash
1) "field2"
2) "world"

##########################################################
hlen

127.0.0.1:6379> hmset myhash field1 hello field2 world
OK
127.0.0.1:6379> hgetall myhash
1) "field2"
2) "world"
3) "field1"
4) "hello"
127.0.0.1:6379> hlen myhash      # 获取哈希的字段数量
(integer) 2

###########################################################
127.0.0.1:6379> hexists myhash field1      # 获取指定的字段是否存在
(integer) 1

############################################################
# 只获取所有的field
# 只获取所有的value
127.0.0.1:6379> hkeys myhash
1) "field2"
2) "field1"
127.0.0.1:6379> hvals myhash
1) "world"
2) "hello"
#############################################################

127.0.0.1:6379> hset myhash field3 5
(integer) 1
127.0.0.1:6379> hincrby myhash field3 1        # 指定增量
(integer) 6
127.0.0.1:6379> hincrby myhash field3 -1
(integer) 5
127.0.0.1:6379> hsetnx myhash field4 hello            # 如果不存在则可以设置
(integer) 1
127.0.0.1:6379> hsetnx myhash field4 world # 存在则没法设置
(integer) 0

```

hash变更的数据  user name age  用户信息的保存 ，经常变动的信息！hash更适合于对象的存储，String更适合字符串的存储！





## Zset（有序集合）

在set 的基础上增加了一个值

```bash
127.0.0.1:6379> zadd myset 1 one        # 增加一个值
(integer) 1
127.0.0.1:6379> zadd myset 2 two 3 three
(integer) 2
127.0.0.1:6379> zrange myset 0 -1
1) "one"
2) "two"
3) "three"
##########################################################

127.0.0.1:6379> zadd money 2500 xiaoming  # 添加三个用户
(integer) 1
127.0.0.1:6379> zadd money 5000 xiaohong
(integer) 1
127.0.0.1:6379> zadd money 100 alan
(integer) 1
127.0.0.1:6379> zrangebyscore money -inf +inf  # 按照 money 从小到大排序
1) "alan"
2) "xiaoming"
3) "xiaohong"
127.0.0.1:6379> zrevrange money 0 -1   # 从大到小进行排序
1) "xiaoming"
2) "alan"
127.0.0.1:6379> zrangebyscore money -inf +inf withscores   # 从小到大 并且带工资输出
1) "alan"
2) "100"
3) "xiaoming"
4) "2500"
5) "xiaohong"
6) "5000"
127.0.0.1:6379> zrangebyscore money -inf 2500  # 显示工资小于2500 的员工
1) "alan"
2) "xiaoming"

##################################################################

移除rem中的元素
127.0.0.1:6379> zrange money 0 -1
1) "alan"
2) "xiaoming"
3) "xiaohong"
127.0.0.1:6379> zrem money xiaohong   # 移除有序集合中的指定元素
(integer) 1
127.0.0.1:6379> zrange money 0 -1
1) "alan"
2) "xiaoming"

127.0.0.1:6379> zcard money          # 获取有序集合中的个数
(integer) 2
##################################################################

127.0.0.1:6379> zadd myset 1 hello 2 world 3 alan
(integer) 3
127.0.0.1:6379> zcount myset 1 3       # 获取指定区间的数量
(integer) 3
127.0.0.1:6379> zcount myset 1 2
(integer) 2

```

其他有需要的可以去查看官方文档

案例思路：  set 排序 存储班级成绩，工资表排序！

普通消息，1  重要消息 2   带权重进行判断

排行榜应用实现



# 三种特殊的数据类型

## geospatial 地理位置

朋友的定位，附近的人，打车距离计算？

Redis的Geo在Redis3.2版本就推出了！

在线查询http://www.jsons.cn/lngcode/

六个命令

![image-20200719092109915](https://gitee.com/lgaaip/img/raw/master/img/20200719092118.png)

> geoadd
>
> - 有效的经度从-180度到180度。
> - 有效的纬度从-85.05112878度到85.05112878度。
>
> 当坐标位置超出上述指定范围时，该命令将会返回一个错误。

```bash
# geoadd 添加地理位置
# 规则： 两级无法直接添加，我们一般会下载城市数据，直接通过java程序一次性导入！
# 参数 key  值（经度，纬度，名称）
127.0.0.1:6379> geoadd china:city 121.472 31.231 shanghai
(integer) 1
127.0.0.1:6379> geoadd china:city 116.405 39.904 beijin
(integer) 1

```

> geopos

获取一个定位

```bash
127.0.0.1:6379> geopos china:city beijin   # 获取指定城市的 经度 和纬度
1) 1) "116.40499860048294067"             
   2) "39.90399988166036138"
```

>geodist
>
>- **m** 表示单位为米。
>- **km** 表示单位为千米。
>- **mi** 表示单位为英里。
>- **ft** 表示单位为英尺。

两人之间的距离

```bash
127.0.0.1:6379> geodist china:city beijin shanghai  # 查看上海到北京的直线距离  单位
"1067557.6637"
127.0.0.1:6379> geodist china:city beijin shanghai km
"1067.5577"

```

> georadius

我附近的人？（获取所有附近的人的地址  定位！） 通过半径来查询！

获得指定数量的人

```bash

127.0.0.1:6379> georadius china:city 110 30 1000 km  # 以 110  30 为经纬度为中心，寻找方圆1000km内的城市
1) "shenzhen"
2) "guangzhou"
3) "wuhan"
127.0.0.1:6379> georadius china:city 110 30 500 km
1) "wuhan"
127.0.0.1:6379> georadius china:city 110 30 1000 km withdist  # 显示到中心距离的位置

1) 1) "shenzhen"
   2) "923.4514"
2) 1) "guangzhou"
   2) "831.2570"
3) 1) "wuhan"
   2) "417.8321"
127.0.0.1:6379> georadius china:city 110 30 1000 km withdist withcoord count 2 # 显示周围人的定位信息  count  指定的数量
1) 1) "wuhan"
   2) "417.8321"
   3) 1) "114.2980000376701355"
      2) "30.5840000050887042"
2) 1) "guangzhou"
   2) "831.2570"
   3) 1) "113.27999979257583618"
      2) "23.12500000786719312"
```

> georadiusbymember

```bash
# 找出以指定位置 附近的人
127.0.0.1:6379> georadiusbymember china:city beijin 1000 km
1) "beijin"
127.0.0.1:6379> georadiusbymember china:city shanghai 1000 km
1) "wuhan"
2) "shanghai"

```

> geohash

```bash
# 将二维的经纬度 转换为  一维的字符串
127.0.0.1:6379> geohash china:city beijin wuhan
1) "wx4g0b799h0"
2) "wt3mbztk8q0"

```

> geo 底层的实现原理其实就是Zset！ 我们可以使用Zset 的命令

```bash
127.0.0.1:6379> zrange china:city 0 -1  # 查看地图中全部的元素
1) "shenzhen"
2) "guangzhou"
3) "wuhan"
4) "shanghai"
5) "beijin"
127.0.0.1:6379> zrem china:city beijin  # 删除一个元素
(integer) 1
127.0.0.1:6379> zrange china:city 0 -1
1) "shenzhen"
2) "guangzhou"
3) "wuhan"
4) "shanghai"

```

## Hyperloglog

> 什么是基数？  基数（不重复的元素）

A｛1，3，5，7，8，7｝  B｛1，3，5，7，8｝   基数 = 5

> 简介

Redis2.8.9版本就更新了Hyperloglog数据结构！

Redis Hyperloglog基数统计的算法！

**优点：**占用的内存量是固定的，2^64不同元素的计数，只需要12KB的内存！如果要从内存角度来比较的话，首选Hyperloglog

**网页的UV（一个人访问一个网站多次，但是还是算作一个人）**

传统的方式，set保存用户的id，然后就可以统计set中的元素数量作为标准判断！

这个方式如果保存大量的用户id，就会比较麻烦！我们的目的是为了计数

0.81% 错误率是可以接受的！

> 测试使用

```bash
127.0.0.1:6379> pfadd mykey a b c d e f f g  # 创建第一组元素 mykey
(integer) 1
127.0.0.1:6379> pfcount mykey # 统计mykey中元素的基数 数量
(integer) 7
127.0.0.1:6379> pfadd mykey2 a s a s f g t # 创建第二组元素 mykey2
(integer) 1
127.0.0.1:6379> pfcount mykey2
(integer) 4
127.0.0.1:6379> pfmerge mykey3 mykey mykey2 # 合并mykey mykey2  到mykey3 并集
OK
127.0.0.1:6379> pfcount mykey3
(integer) 8

```



## Bitmap

> 位存储

统计用户信息，活跃，不活跃！ 登录，未登录！打卡，365打卡！**两个状态的都可以使用Bitmaps**！

Bitmap 位图，数据结构！都是操作二进制位来进行记录，就只有0和1两种状态！

> 测试

使用bitmap来记录 周一到周日的打卡

0-6  周一到周日  1为打卡 0为没打卡

![image-20200719110158939](https://gitee.com/lgaaip/img/raw/master/img/20200719110200.png)

查看某一天是否有打卡！

![image-20200719110307767](https://gitee.com/lgaaip/img/raw/master/img/20200719110308.png)

统计操作，统计打卡的天数

![image-20200719110351645](https://gitee.com/lgaaip/img/raw/master/img/20200719110353.png)



# 事务

Redis事务的本质：一组命令的集合！一个事务中的所有命令都会被序列化，在事务执行过程中，会按照顺序执行！

一次性，顺序行，排他性！  执行一系列的命令

```bash

```

`Redis事务没有隔离级别的概念`

所有命令在十五中，并没有直接被执行！ 只有发起执行命令才会被执行！Exec

`Redis单条命令是保存原子性的，但是事务不保证原子性！`

redis的事务：

- 开启事务（Multi）
- 命令入队（....）
- 执行事务（exec）

> 正常实现事务！

```bash
127.0.0.1:6379> multi      # 开启事务
OK
127.0.0.1:6379> set k1 v1  # 命令入队
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> get k2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> exec      # 执行事务
1) OK
2) OK
3) "v2"
4) OK

```

> 放弃事务！

```bash
127.0.0.1:6379> multi       # 开启事务
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> discard  # 取消事务
OK
 事务中你的命令都不会被执行
```

> 编译型异常（代码有问题！命令有错！）  事务中的所有命令都不会被执行

```bash
127.0.0.1:6379> multi
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED  
127.0.0.1:6379> getset k3       # 错误的命令
(error) ERR wrong number of arguments for 'getset' command
127.0.0.1:6379> set k4 v4
QUEUED
127.0.0.1:6379> set k5 v5
QUEUED
127.0.0.1:6379> exec  # 执行事务报错
(error) EXECABORT Transaction discarded because of previous errors.
127.0.0.1:6379> get k5  # 所有的命令都不会被执行
(nil)

```

> 运行时异常（ 1 / 0）  如果事务队列中存在语法错误，那么执行命令时候，其他命令是可以执行的，错误的命令抛出异常！

```bash
127.0.0.1:6379> multi
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> incr k1   # 命令没问题 是在执行的时候错了
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> get k3
QUEUED
127.0.0.1:6379> exec
1) OK
2) (error) ERR value is not an integer or out of range # 命令报错了 但是事务依旧执行成功了
3) OK
4) OK
5) "v3"
```

> 监控！ Watch

悲观锁：

- 很悲观，认为什么时候都会出问题，无论做什么都会加锁！



乐观锁：

- 很乐观：认为什么时候都不会出现问题，所以不会加锁！更新数据的时候去判断一下，在此期间是否有人去修改这个数据。
- 获取version
- 更新的时候比较version

> Redis测试  监听测试

正常执行成功！

```bash
127.0.0.1:6379> set money 100
OK
127.0.0.1:6379> set out 0
OK
127.0.0.1:6379> watch money      # 监视money 对象
OK
127.0.0.1:6379> multi # 事务正常结束，数据期间没有发生变动，这个时候正常执行成功！
OK
127.0.0.1:6379> decrby money 20
QUEUED
127.0.0.1:6379> incrby out 20
QUEUED
127.0.0.1:6379> exec
1) (integer) 80
2) (integer) 20

```

测试多线程修改值，使用watch可以当做redis 的乐观锁操作

```bash
127.0.0.1:6379> watch money   # 监视 money
OK
127.0.0.1:6379> multi
OK
127.0.0.1:6379> decrby money 10
QUEUED
127.0.0.1:6379> incrby out 10
QUEUED
127.0.0.1:6379> exec    # 执行之前另外一个线程修改了值  所以导致事务执行失败
(nil)

```

如果修改失败，获取最新的值就好

![image-20200719195639689](https://gitee.com/lgaaip/img/raw/master/img/20200719195642.png)

# Jedis

**使用java操作redis**

> 什么是jedis ，  是Redis官方推荐的java连接开发工具！使用java操作redis中间件！如果你要使用java操作redis，那么一定要对jedis十分熟悉！

> 测试

1. 导入对应的依赖

```xml
<!--导入jedis的包-->
<!-- https://mvnrepository.com/artifact/redis.clients/jedis -->
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>3.3.0</version>
</dependency>
<!--fastjson-->
<!-- https://mvnrepository.com/artifact/com.alibaba/fastjson -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.72</version>
</dependency>
```

2. 编码测试

- 连接数据库
- 操作命令
- 断开连接

```java
package com.alan;

import redis.clients.jedis.Jedis;

public class TestPing {

    public static void main(String[] args) {
        // 1. new Jedis 对象即可
        Jedis jedis = new Jedis("127.0.0.1",6379);
        // jedis 所有的命令就是我们之前学习的所有指令！  之前的指令很重要
        System.out.println(jedis.ping());
    }
}
```

输出：

![image-20200719204158073](https://gitee.com/lgaaip/img/raw/master/img/20200719204159.png)



## 常用的API

`String，List，Set，Hash，Zset  跟之前学的命令都是一样的，都是redis.方法()`

> 所有的API命令都一样，一个都没变化

> 事务

```java
package com.alan;

import com.alibaba.fastjson.JSONObject;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.Transaction;

public class TestTX {

    public static void main(String[] args) {
        Jedis jedis = new Jedis("127.0.0.1",6379);

        jedis.flushDB();

        JSONObject jsonObject = new JSONObject();
        jsonObject.put("hello","world");
        jsonObject.put("name","alan");

        // 开启事务
        Transaction multi = jedis.multi();
        String jsonString = jsonObject.toJSONString();

        try {
            multi.set("user1",jsonString);
            multi.set("user2",jsonString);
          //  int i = 1/0;   // 事务执行失败

            multi.exec();    // 提交事务
        } catch (Exception e) {
            multi.discard();   // 放弃事务
            e.printStackTrace();
        } finally {
            System.out.println(jedis.get("user1"));
            System.out.println(jedis.get("user2"));
            jedis.close();   // 关闭连接
        }
    }
}
```

# 整合SpringBoot

在springboot2.x之后，原来使用的jedis被替换成了lettuce

jedis：采用的是直连，多个线程操作的话是不安全的，如果想要避免不安全，使用redis pool 连接池！像BIO模式

lettuce：采用netty，实例可以在多个进程中共享，不存在线程不安全的情况！可以减少线程数据，像NIO模式

源码分析：

```java
@Bean
	@ConditionalOnMissingBean(name = "redisTemplate")  # 如果自己写模板类的话 就会覆盖掉这类
	public RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory)
			throws UnknownHostException {
        // 默认的RedisTemplate 没有过多的设置 redis对象都是需要序列化的
        //  两个泛型都是Object，Object的类型 我们要使用得强转转换<String,Object>
		RedisTemplate<Object, Object> template = new RedisTemplate<>();
		template.setConnectionFactory(redisConnectionFactory);
		return template;
	}

	@Bean 
	@ConditionalOnMissingBean  // 由于我们的string是redis中最常用的类型  所以说单独如出来一个bean
	public StringRedisTemplate stringRedisTemplate(RedisConnectionFactory redisConnectionFactory)
			throws UnknownHostException {
		StringRedisTemplate template = new StringRedisTemplate();
		template.setConnectionFactory(redisConnectionFactory);
		return template;
	}
```

> 整合测试一下

1. 导入依赖

```xml
<dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
```



2. 配置连接

```properties
#配置redis
spring.redis.host=127.0.0.1
spring.redis.port=6379
```

3. 测试类

```java
package com.alan.redis02springboot;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.redis.core.RedisTemplate;

@SpringBootTest
class Redis02SpringbootApplicationTests {

    @Autowired
    private RedisTemplate redisTemplate;

    @Test
    void contextLoads() {

        //redisTemplate
        // opsForValue 操作字符串 类似string
        // opsForHash
        // opsForList
        // opsForSet
        // opsForZSet
        // opsForGeo
        // opsForHyperLogLog

        //除了基本的操作 我们常用的方法都可以直接通过RedisTemplate操作 比如 事务

        /*获取redis的连接对象
        RedisConnection connection = redisTemplate.getConnectionFactory().getConnection();
        connection.flushDb();*/

        redisTemplate.opsForValue().set("name","艾伦");
        System.out.println(redisTemplate.opsForValue().get("name"));
    }

}

```

![image-20200720211337895](https://gitee.com/lgaaip/img/raw/master/img/20200720211346.png)

![image-20200720211429288](https://gitee.com/lgaaip/img/raw/master/img/20200720211430.png)

关于对象的保存

![image-20200720214158782](https://gitee.com/lgaaip/img/raw/master/img/20200720214201.png)

自定义RedisTemplate  可以直接使用

```java
package com.alan.redis02springboot.config;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.net.UnknownHostException;

@Configuration
public class Redisconfig {

    //编写我们自己的RedisTemplate
    @Configuration
    public class RedisConfig {
        @Bean
        
        public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
            RedisTemplate<String, Object> template = new RedisTemplate();
            template.setConnectionFactory(factory);

            //Json序列化配置
            Jackson2JsonRedisSerializer jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer(Object.class);
            ObjectMapper om = new ObjectMapper();
            om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
            om.enableDefaultTyping(ObjectMapper.DefaultTyping.NON_FINAL);
            jackson2JsonRedisSerializer.setObjectMapper(om);

            //String 序列化
            StringRedisSerializer stringRedisSerializer = new StringRedisSerializer();
            // key采用String的序列化方式
            template.setKeySerializer(stringRedisSerializer);
            // hash的key也采用String的序列化方式
            template.setHashKeySerializer(stringRedisSerializer);
            // value序列化方式采用jackson
            template.setValueSerializer(jackson2JsonRedisSerializer);
            // hash的value序列化方式采用jackson
            template.setHashValueSerializer(jackson2JsonRedisSerializer);
            template.afterPropertiesSet();
            return template;
        }
    }
}

```

> 一般都用一个自己封装的RedisUtils工具类  可以在网上找了直接用

# Redis.conf详解

启动的时候，通过配置文件启动

> 单位

![image-20200721091939030](https://gitee.com/lgaaip/img/raw/master/img/20200721091947.png)

配置文件 unit单位 对大小写不敏感

> 包含

![image-20200721092037940](https://gitee.com/lgaaip/img/raw/master/img/20200721092039.png)

好比我们学习spring，import，include

> 网络

```bash
bind 127.0.0.1  # 绑定的ip
protected-mode yes  # 保护模式
port 6379   # 端口设置
```

> 通用

```bash
daemonize yes     # 以守护进程的方式进行，默认是no   我们需要自己开启为yes

pidfile /var/run/redis_6379.pid # 如果以后台的方式运行 我们就需要指定一个pid文件

# 日志
# Specify the server verbosity level.
# This can be one of:
# debug (a lot of information, useful for development/testing)
# verbose (many rarely useful info, but not a mess like the debug level)
# notice (moderately verbose, what you want in production probably)
# warning (only very important / critical messages are logged)
loglevel notice
logfile ""  # 日志的文件位置名
databases 16  # 数据库的数量，默认是16个数据库
always-show-logo yes   # 是否总数显示logo
```

> 快照

持久化，在规定的时间内，执行了多少次操作，则会持久化到.rdb.aof

redis 是内存数据库，如果没有持久化，那么数据库断电即失

```bash
# 如果900s内，至少有一个key进行了修改，进行持久化
save 900 1
save 300 10
save 60 10000

# 我们之后学习持久化，会自己定义这个测试！



stop-writes-on-bgsave-error yes  # 持久化如果出错了 是否继续工作

rdbcompression yes  # 是否压缩rdb文件，需要消耗一些cpu资源

rdbchecksum yes  # 保存rdb文件的时候，进行一些错误的检查校验

dir ./  # rdb文件保存的目录
```

> REPLICATION 复制   后面主从复制会讲解





> SECURITY

可以在这里设置redis的密码，默认是没有密码！

```bash
127.0.0.1:6379> config get requirepass  # 获取redis的密码
1) "requirepass"
2) ""
127.0.0.1:6379> config set requirepass "123456"  # 设置redis的密码
OK
127.0.0.1:6379> ping       # 发现所有的命令都没有权限使用了
(error) NOAUTH Authentication required.
127.0.0.1:6379> auth 123456     # 使用密码进行登录
OK
127.0.0.1:6379> ping
PONG
127.0.0.1:6379> config get requirepass
1) "requirepass"
2) "123456"
```

> 限制  CLIENTS

```bash
maxclients 10000 # 设置能连接上 redis  最大客户端的数量
maxmemory <bytes>  # redis 配置最大的内存容量
maxmemory-policy noeviction # 内存到达上限之后的处理策略

1、volatile-lru：只对设置了过期时间的key进行LRU（默认值） 
2、allkeys-lru ： 删除lru算法的key   
3、volatile-random：随机删除即将过期key   
4、allkeys-random：随机删除   
5、volatile-ttl ： 删除即将过期的   
6、noeviction ： 永不过期，返回错误
```

> APPEND ONLY MODE 模式     aof配置

```bash
appendonly no   # 默认是不开启aof模式的，默认是使用rdb方式持久化的，在大部分所有情况下，rdb完全够用
appendfilename "appendonly.aof"  # 持久化配置的名字

# appendfsync always  # 每次修改都会同步  消耗性能
appendfsync everysec  # 每秒执行一次sync 可能会丢失这1s 的数据
# appendfsync no   # 不执行同步  这个时候操作系统自己同步数据 ，速度最快
```

# Redis持久化

面试和工作，持久化是重点！

Redis是内存数据库，如果不将内存中的数据库状态保存到磁盘，那么一旦服务器进程退出，服务器中的数据库状态也会消失。所以Redis提供了持久化的功能！



## RDB（Redis DataBase）

> 什么是RDB

![20200412142257515](https://gitee.com/lgaaip/img/raw/master/img/20200722084423.png)



**在指定的时间间隔内将内存中的数据集快照写入磁盘，也就是行话讲的Snapshot快照，它恢复时是将快照文件直接读到内存里。**

- Redis会单独创建（fork）一个子进程来进行持久化，会先将数据写到一个临时文件中，等待持久化过程都结束了，再用这个临时文件替换上次持久化好的文件。整个过程中，主进程是不进行任何IO操作的，这就确保了极高的性能。如果需要进行大规模数据的恢复，且对于数据恢复的完整性不是很敏感，那么RDB方式要比AOF方式更加的高效。RDB的缺点是最后一次持久化的数据，可能丢失。

`有时候在生产环境会将rdb文件进行备份`

- RDB保存的文件是==dump.rdb==，在配置文件中配置的。
  ![image-20200722085407582](https://gitee.com/lgaaip/img/raw/master/img/20200722085408.png)



![image-20200722090119436](https://gitee.com/lgaaip/img/raw/master/img/20200722090120.png)

> 触发机制

1. save的规则满足的情况下，会自动触发rdb规则
2. 执行flushall命令，也会触发我们的rdb规则！
3. 退出redis，也会产生rdb文件



![image-20200722091102011](https://gitee.com/lgaaip/img/raw/master/img/20200722091103.png)



> 如何恢复rdb文件！

1. 只需要把rdb文件放在我们redis启动目录就可以，redis启动的时候会自动检查dump.rdb恢复其中的数据！
2. 查看需要存在的配置

![image-20200722091701500](https://gitee.com/lgaaip/img/raw/master/img/20200722091702.png)



> 几乎就他自己的默认配置就够用了，但是我们还是需要去学习

优点：

1. 适合大规模的数据恢复！ dump.rdb
2. 如果对数据的完整性要求不高！

缺点：

1. 需要一定的时间间隔进行操作！如果redis意外宕机了，这个最后一次修改数据就没有的了！
2. fork进程的时候，会占用一定的内容空间！



## AOF（Append Only File）

将我们的所有命令都记录下来，history，恢复的时候就把这个文件全部在执行一遍！

> 什么的AOF

![2020041214230576](https://gitee.com/lgaaip/img/raw/master/img/20200722084507.png)



![6537954-dfba3c1c0ec33dee](https://gitee.com/lgaaip/img/raw/master/img/20200722112240.jpg)

- 以日志的形式来记录每个写操作，将Redis执行过的所有指令记录下来（读操作不记录），只许追加文件但不可以改写文件，redis启动之初会读取该文件重新构建数据，redis重启的话就根据日志文件的内容将写指令从前到后执行一次以完成数据的恢复工作。
- AOF保存的文件是appendonly.aof文件
- redis-check-aof --fix aof文件：用来修复这个aof文件

> append

![image-20200722112705423](https://gitee.com/lgaaip/img/raw/master/img/20200722112707.png)

默认是不开启的，我们需要手动配置！我们只需要将appendonly 改为yes就开启了 aof ！

如果这个 aof 文件有错误，这时候 redis 是启动不起来的，我们需要修复这个aof文件

redis 给我们提供了一个工具` redis-check-aof --fix`

![image-20200722130921352](https://gitee.com/lgaaip/img/raw/master/img/20200722130922.png)

> 重写规则说明

aof 默认就是文件的无限追加，文件会越来越大！

![image-20200722131611834](https://gitee.com/lgaaip/img/raw/master/img/20200722131612.png)

如果 aof 文件大于 64m，太大了！ fork一个新的进程来将我们的文件进行重写！

#### 优点和缺点！

#### 优点：

#### 1 、每一次修改都同步，文件的完整会更加好！

#### 2 、每秒同步一次，可能会丢失一秒的数据

#### 3 、从不同步，效率最高的！

#### 缺点：

1 、相对于数据文件来说，aof远远大于 rdb，修复的速度也比 rdb慢！

2 、Aof 运行效率也要比 rdb 慢，所以我们redis默认的配置就是rdb持久化！

#### 拓展

1、RDB持久化方式能够在指定的时间间隔内对你的数据进行快照储存
2、AOF持久化方式记录每次对服务器写的操作，当服务器重启的时候会重新执行这些命令来恢复原始的数据，AOF命令以Redis协议追加保存每次写的操作到文件末尾，Redis还能对AOF文件进行后台重写，使AOF文件体积不至于过大。
3、只做缓存，如果你只希望你的数据在服务器运行的时候存在，你也可以不使用任何持久化。
4、同时开启两种持久化方式

- 这种情况下，当redis重启的时候会优先载入AOF文件来恢复原始的数据，因为在通常情况下AOF文件保存的数据比RDB文件要完整。
  RDB的数据不实时，同时使用两者时服务器重启也只会找AOF文件，那要不要只使用AOF呢？建议不要，因为RDB更适合用于备份数据库（AOF在不断变化不好备份），快速重启，而且不会有AOF可能潜在的bug，留着作为一个万一的手段

5、性能建议

- 因为RDB文件只作为后备用途，建议只在Slave（从机）上持久化RDB文件，而且15分钟备份一次就够了，只保留save 900 1 这条规则。

# Redis的发布订阅

Redis 发布订阅（pub/sub）是一种消息通信模式：发送者（pub）发送消息，订阅者（sub）接收消息。
Redis 客户端可以订阅任意数量的频道。
订阅/发布消息图：

![20200720160019134](https://gitee.com/lgaaip/img/raw/master/img/20200722160931.png)

>  命令

这些命令被广泛用于构建即时通信应用，比如网络聊天室（chatroom）和 实时广播，实时提醒等。

![image-20200722161240225](https://gitee.com/lgaaip/img/raw/master/img/20200722161241.png)

>  测试

订阅端

```bash
127.0.0.1:6379> SUBSCRIBE alan #订阅一个频道 alan
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "alan"
3) (integer) 1
#等待读取推送的消息
1) "message" # 消息
2) "alan"	# 哪个频道的消息
3) "hello alan" # 消息内容
1) "message"
2) "alan"
3) "hello redis"
```


发送端

```bash
[root@localhost bin]# redis-cli -p 6379
127.0.0.1:6379> ping
PONG
127.0.0.1:6379> PUBLISH haiyang "hello alan" #发布者发布消息到频道
(integer) 1
127.0.0.1:6379> PUBLISH haiyang "hello redis" #发布者发布消息到频道
(integer) 1
127.0.0.1:6379> 
```

# Redis主从复制

### 概念

主从复制，是指将一台Redis服务器的数据，复制到其他的Redis服务器。前者称为主节点
 (master/leader)，后者称为从节点(slave/follower)；数据的复制是单向的，只能由主节点到从节点。
 Master以写为主，Slave 以读为主。

默认情况下，每台Redis服务器都是主节点；

且一个主节点可以有多个从节点(或没有从节点)，但一个从节点只能有一个主节点。（）

**主从复制的作用主要包括：**

1 、数据冗余：主从复制实现了数据的热备份，是持久化之外的一种数据冗余方式。

2 、故障恢复：当主节点出现问题时，可以由从节点提供服务，实现快速的故障恢复；实际上是一种服务
 的冗余。

3 、负载均衡：在主从复制的基础上，配合读写分离，可以由主节点提供写服务，由从节点提供读服务
 （即写Redis数据时应用连接主节点，读Redis数据时应用连接从节点），分担服务器负载；尤其是在写
 少读多的场景下，通过多个从节点分担读负载，可以大大提高Redis服务器的并发量。

4 、高可用（集群）基石：除了上述作用以外，主从复制还是哨兵和集群能够实施的基础，因此说主从复
 制是Redis高可用的基础。

一般来说，要将Redis运用于工程项目中，只使用一台Redis是万万不能的（宕机），原因如下：

1 、从结构上，单个Redis服务器会发生单点故障，并且一台服务器需要处理所有的请求负载，压力较
 大；

2 、从容量上，单个Redis服务器内存容量有限，就算一台Redis服务器内存容量为256G，也不能将所有
 内存用作Redis存储内存，一般来说，单台Redis最大使用内存不应该超过20G。

电商网站上的商品，一般都是一次上传，无数次浏览的，说专业点也就是"多读少写"。

### 环境配置

只需要配置从库，因为每一个原始都是主库！

> `info replication`  命令可以查看当前的信息  (得先连上reids再查看)

```bash
27.0.0.1:6379> info replication # 查看当前的信息
#Replication
role:master #角色 master
connected_slaves:0 # 没有从机
master_replid:0001a2d30c03aa104281f5d9aaeac6f908785dc7
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

- 复制3个redis.conf 文件，然后修改对应的信息

  1、端口
  2、pid名字
  3、log文件名字
  4、dump.rdb名字
  ==修改完毕之后，启动三个redis服务器==

  ![20200720171624686](https://gitee.com/lgaaip/img/raw/master/img/20200722203403.png)

### 一主二从

6379端口的作为主机  (6380, 6381 为从机)

**从机6380**

`SLAVEOF ip 端口`  这个命令用来绑定主机

```bash
127.0.0.1:6380> SLAVEOF 127.0.0.1 6379
OK
127.0.0.1:6380> info replication   # 查看信息
# Replication
role:slave       # 可看到 变为了从机
master_host:127.0.0.1        # 主机的ip
master_port:6379      # 主机的端口号
master_link_status:up
master_last_io_seconds_ago:3
master_sync_in_progress:0
slave_repl_offset:294
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:ba86452e653a55307933140b878d224cc5185fd5
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:294
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:281
repl_backlog_histlen:14
```

**从机6381**

```bash
127.0.0.1:6380> SLAVEOF 127.0.0.1 6379
OK
127.0.0.1:6381> info replication
# Replication
role:slave
master_host:127.0.0.1
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_repl_offset:98
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:ba86452e653a55307933140b878d224cc5185fd5
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:98
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:98
```

**主机6379**

```bash
127.0.0.1:6379> info replication   # 查看主机的信息
# Replication
role:master      # 为主机
connected_slaves:2      # 两个从机
slave0:ip=127.0.0.1,port=6381,state=online,offset=294,lag=0   # 从机的信息
slave1:ip=127.0.0.1,port=6380,state=online,offset=294,lag=0   # 从机的信息
master_replid:ba86452e653a55307933140b878d224cc5185fd5
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:308
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:308
```

> 上面的配置是用命令来配置的，断开连接关掉之后，就恢复了原来的配置
>
> `如果要永久配置，需要在配置文件中配置`

![image-20200722204215385](https://gitee.com/lgaaip/img/raw/master/img/20200722204216.png)

>  主从复制的 **一些细节**

主机才能写，从机只能读，不能进行写操作，主机的所有的信息都会自动保存到从机中！

**主机写**

![image-20200722204723656](https://gitee.com/lgaaip/img/raw/master/img/20200722204724.png)

**从机只能读**

![image-20200722204749847](https://gitee.com/lgaaip/img/raw/master/img/20200722204750.png)

> 注意：

如果主机断开连接，从机依旧还连着主机，那么当主机重新连接的时候，从机还是可以从主机中读到信息的！

反过来的话 就得看从机是怎么配置的！ 

如果是用命令配置的，那么从机重启后，自动又变为了主机。（得重新输入命令变为从机才能继续读取主机的信息）

如果是配置文件中永久配置的就重新连接也是可以从主机读取信息的！

#### 复制原理

Slave 启动成功连接到 master 后会发送一个sync同步命令Master 接到命令，启动后台的存盘进程，同时收集所有接收到的用于修改数据集命令，在后台进程执行完毕之后，master将传送整个数据文件到slave，并完成一次完全同步。

**全量复制**：而slave服务在接收到数据库文件数据后，将其存盘并加载到内存中。

**增量复制**：Master 继续将新的所有收集到的修改命令依次传给slave，完成同步

但是只要是重新连接master，一次完全同步（全量复制）将被自动执行！ 我们的数据一定可以在从机中看到！

> 层层链入

A主机  ---> B（从机，主机）---> C 从机

意思就是设置B为A的从机，C为B的从机，理论上B既是A的从机，又是C的主机，但是查看B服务器的信息，依旧还是从机

但是此时A中的信息，毋庸置疑B肯定可以读到，但是C读不读得到呢？**答案是： 可以读得到！！！**

> 谋朝篡位

如果主机断开了连接，我们可以使用 `SLAVEOF no one` 让自己变成主机！其他的节点就可以手动连
接到最新的这个主节点（手动）！如果这个时候老大修复了，那就重新连接！

# Redis之哨兵模式

### 哨兵模式

（自动选举老大的模式）

> 概述

- 主从切换技术的方法是：当主服务器宕机后，需要手动把一台从服务器切换为主服务器，这就需要人工干预，费事费力，还会造成一段时

  间内服务不可用。这不是一种推荐的方式，更多时候，我们优先考虑哨兵模式。Redis从2.8开始正式提供了Sentinel（哨兵）架构来解决这

  个问题。

- 谋权篡位的自动版，能够后台监控主机是否故障，如果故障了根据投票自动将从库转换为主库。

- 哨兵模式是一种特殊的模式，首先Redis提供了哨兵的命令，哨兵是一个独立的进程，作为进程，他会独立运行。其原理是哨兵**通过发送命**

  **令，等待Redis服务器响应，从而监控运行的多个Redis实例**


> 下面是单机哨兵的模型图

![image-20200723101944292](https://gitee.com/lgaaip/img/raw/master/img/20200723101952.png)

**这里的哨兵有两个作用**

- 通过发送命令，让Redis服务器返回监控其运行状态，包括主服务器和从服务器。

- 当哨兵监测到master宕机，会自动将slave切换成master，然后通过发布订阅通知其他的从服务器，修改配置文件，让它们切换主机。



然而一个哨兵进程对Redis服务器进行监控，可能会出现问题，为此，我们可以使用多个哨兵进行监控。各个哨兵之间还会进行监控，这样就形成了多哨兵模式。


![image-20200723102124879](https://gitee.com/lgaaip/img/raw/master/img/20200723102125.png)

假设主服务器宕机，哨兵1先检测到这个结果，系统不会马上进行failove[故障转移]过程，仅仅是哨兵1主观的认为主服务器不可用，这个现象称为**主观下线**。当后面的哨兵也检测到主服务器不可用，并且数量达到一定值时，那么哨兵之间就会进行一次投票，投票的结果有一个哨兵发起，**进行failover[故障转移]操作。切换成功后，就会通过发布订阅模式，让各个哨兵把自己监控的从服务器实现切换主服务器，这个过程称为客观下线。**

> 那么如何开启哨兵模式

在一主二从的基础上配置哨兵模式

1. 配置哨兵配置文件

```bash
#sentinel monitor 被监控的名称 host port 1
sentinel monitor myredis 127.0.0.1 6379 1
# 后面的 数字1，代表主机挂了，slave投票看让谁接替成为主机，票数最多的，就会成为主机！
```

2. 启动哨兵

```bash
[root@localhost bin]# redis-sentinel kconfig/sentinel.conf
61977:X 21 Jul 2020 11:24:13.143 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
61977:X 21 Jul 2020 11:24:13.143 # Redis version=6.0.5, bits=64, commit=00000000, modified=0, pid=61977, just started
61977:X 21 Jul 2020 11:24:13.143 # Configuration loaded
61977:X 21 Jul 2020 11:24:13.144 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 6.0.5 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in sentinel mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 26379
 |    `-._   `._    /     _.-'    |     PID: 61977
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

61977:X 21 Jul 2020 11:24:13.145 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
61977:X 21 Jul 2020 11:24:13.145 # Sentinel ID is fe885194af3527c0eb748c5cf26d8f9d90c3e315
61977:X 21 Jul 2020 11:24:13.145 # +monitor master myredis 127.0.0.1 6379 quorum 1
```

3. 测试

   我们把主机shutdown

```bash
127.0.0.1:6379> SHUTDOWN
not connected> exit
```

​		等一会儿会发现哨兵发现了，会做故障转移，并且随机选取

```bash
61977:X 21 Jul 2020 11:24:13.143 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
61977:X 21 Jul 2020 11:24:13.143 # Redis version=6.0.5, bits=64, commit=00000000, modified=0, pid=61977, just started
61977:X 21 Jul 2020 11:24:13.143 # Configuration loaded
61977:X 21 Jul 2020 11:24:13.144 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 6.0.5 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in sentinel mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 26379
 |    `-._   `._    /     _.-'    |     PID: 61977
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

61977:X 21 Jul 2020 11:24:13.145 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
61977:X 21 Jul 2020 11:24:13.145 # Sentinel ID is fe885194af3527c0eb748c5cf26d8f9d90c3e315
61977:X 21 Jul 2020 11:24:13.145 # +monitor master myredis 127.0.0.1 6379 quorum 1
61977:X 21 Jul 2020 11:26:57.206 # +sdown master myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.206 # +odown master myredis 127.0.0.1 6379 #quorum 1/1
61977:X 21 Jul 2020 11:26:57.206 # +new-epoch 1
61977:X 21 Jul 2020 11:26:57.206 # +try-failover master myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.208 # +vote-for-leader fe885194af3527c0eb748c5cf26d8f9d90c3e315 1
61977:X 21 Jul 2020 11:26:57.208 # +elected-leader master myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.208 # +failover-state-select-slave master myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.271 # +selected-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ myredis 127.0.0.1 6379
#这里开启故障转移
61977:X 21 Jul 2020 11:26:57.271 * +failover-state-send-slaveof-noone slave 127.0.0.1:6380 127.0.0.1 6380 @ myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.326 * +failover-state-wait-promotion slave 127.0.0.1:6380 127.0.0.1 6380 @ myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.428 # +promoted-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.428 # +failover-state-reconf-slaves master myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.478 * +slave-reconf-sent slave 127.0.0.1:6381 127.0.0.1 6381 @ myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:57.578 * +slave-reconf-inprog slave 127.0.0.1:6381 127.0.0.1 6381 @ myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:58.615 * +slave-reconf-done slave 127.0.0.1:6381 127.0.0.1 6381 @ myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:58.686 # +failover-end master myredis 127.0.0.1 6379
61977:X 21 Jul 2020 11:26:58.686 # +switch-master myredis 127.0.0.1 6379 127.0.0.1 6380
61977:X 21 Jul 2020 11:26:58.686 * +slave slave 127.0.0.1:6381 127.0.0.1 6381 @ myredis 127.0.0.1 6380
61977:X 21 Jul 2020 11:26:58.686 * +slave slave 127.0.0.1:6379 127.0.0.1 6379 @ myredis 127.0.0.1 6380
#+sdown slave 127.0.0.1:6379 挂了
61977:X 21 Jul 2020 11:27:28.758 # +sdown slave 127.0.0.1:6379 127.0.0.1 6379 @ myredis 127.0.0.1 6380
```

如果主机重连了，哨兵发现后，会把它归并到新的主机中，此时它就是从机了。这就是哨兵的规则！

> 哨兵模式的优缺点

`优点:`

1、哨兵集群，基于主从复杂模式，所有的主从配置优点，它全有
2、主从可以却换，故障可以转移，系统的可用性就会更好
3、哨兵模式就是主从复制的升级，手动到自动，更加健壮！

`缺点:`

1、Redis不好在线扩容的，集群容量一旦达到上限，在线扩容就十分麻烦！
2、实现哨兵模式的配置其实是很麻烦的，里面有很多的选择

> 哨兵的全部配置

![image-20200723122604629](https://gitee.com/lgaaip/img/raw/master/img/20200723122605.png)

![image-20200723122622521](https://gitee.com/lgaaip/img/raw/master/img/20200723122623.png)

![image-20200723122640470](https://gitee.com/lgaaip/img/raw/master/img/20200723122641.png)

# 缓存穿透和雪崩

### 缓存穿透

>  概念

缓存穿透的概念很简单，用户想要查询一个数据，发现redis内存数据库里没有，也就是缓存没有命中，于是向持久层数据库查询。发现也没有，于是本次查询失败。当用户很多时，缓存都没有命中，于是都去请求了持久层数据库，这会给 持久层数据库造成很大的压力，这时候就相当于出现了缓存击穿。

> 解决方案

#### 布隆过滤器

布隆过滤器是一种数据结构，对所有可能查询参数以hash形式存储，在控制层先进行校验，不符合则丢弃，从而避免了对底层储存系统的查询压力:

![image-20200723122924250](https://gitee.com/lgaaip/img/raw/master/img/20200723122925.png)

#### 缓存空对象

当存储层不命中后，即使返回空对象也将其缓存起来，同时会设置一个过期时间，之后再访问这个数据就会从缓存中获取，保护了后端数据源。

![image-20200723122956483](https://gitee.com/lgaaip/img/raw/master/img/20200723122957.png)

但是这种方法会存在两个问题：
1、如果空值可以被缓存起来，这就意味着缓存需要更多的空间储存更多的键，因为这当中可能会有很多空值的键；
2、即使对空值设置了过期时间，还是会存在缓存层和储存层的数据会有一段时间窗口不一致，这对于需要保持一致性的业务会有影响。



### 缓存击穿

> 概述

这里需要注意和缓存穿透的区别，缓存击穿，是指一个key非常热点，在不停的抗大并发，大并发集中对一个点进行访问，当这个key在失效的瞬间，持续的大并发就穿破缓存，直接请求数据库，就像在屏障上凿开了一个洞。

当某个key在过期的瞬间，有大量的请求并发访问，这类数据一般都是热点数据，由于缓存过期，会同时的访问数据库来查询最新数据，并且回写缓存，会导致数据库瞬间压力过大

> 解决方案

#### **设置热点数据永不过期**

​	从缓存层面来看，没有设置过期时间，所以不会出现热点key过期后产生的问题。

#### **加互斥锁**

​	分布式锁：使用分布式锁，保证对于每个key同时只有一个线程去查询后端服务，其他线程没有获得分布式锁的权限，因此只需要等待即可。	这种方式将高并发的压力转移到了分布式锁，因此对分布式锁的考验很大。

![image-20200723123237257](https://gitee.com/lgaaip/img/raw/master/img/20200723123239.png)

### 缓存雪崩

> 概念

缓存雪崩，是指在某一个时间段，缓存集中过期失效。

产生雪崩的原因之一，比如双11零点，很快会有一波抢购，这波商品时间比较集中的放入了缓存，假设缓存一个小时。那么到了凌晨一点的时候，这批商品的缓存就过期了。而对于这批商品的访问查询，都落到了数据库上，对于数据库而言，就会产生周期性的压力波峰。于是所有的请求都会到达存储层，存储层的调用量会暴增，造成储存层也会挂掉的情况。
![image-20200723123405643](https://gitee.com/lgaaip/img/raw/master/img/20200723123406.png)

其实集中过期，倒不是非常致命的，比较致命的缓存雪崩，是缓存服务器的某个节点宕机或断网。因为自然形成的缓存雪崩，一定是在某个时间段集中创建缓存，这个时候，数据库也是可以顶住压力的。无非就是对数据库产生周期性的压力而已。而缓存节点宕机，对数据库服务器造成的压力是不可预知的，很有可能瞬间把数据库压垮。

> 解决方案

#### redis高可用

这个思想的含义是，既然redis有可能挂掉，那我就多设几台redis,这样一台挂掉之后其他的还可以继续工作，其实就是搭建的集群。（异地多活）

#### 限流降级

这个解决方案的思想是，在缓存失效后，通过加锁或者列队来控制读数据库写缓存的线程数量。比如对某个key只允许一个线程查询数据和写缓存，其他线程等待。

#### 数据预热

数据加热的含义就是在正式部署之前，我先把可能的数据先预先访问一遍，这样部分可能大量访问的数据就会加载到缓存中。在即将发生大并发访问前手动触发加载缓存不同的key，设置不同的过期时间，让缓存失效的时间点尽量均匀。