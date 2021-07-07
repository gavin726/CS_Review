# Docker入门

## 一、Docker的常用命令

### ① 帮助命令

```shell
[root@wosalan /]# docker version 显示docker的版本信息
[root@wosalan /]# docker info  显示docker的系统信息,包括镜像和容器数量
```

如果忘记了命令,可以输入

```shell
docker 命令 --help #查看帮助命令
```

或者查看docker帮助文档 https://docs.docker.com/reference/



### ② 镜像命令

#### docker images

`docker images` 查看所有本地主机上的镜像

![image-20210705144748311](https://gitee.com/lgaaip/img/raw/master/image-20210705144748311.png)

`docker images -aq `显示所有镜像的id

![image-20210705145302390](https://gitee.com/lgaaip/img/raw/master/image-20210705145302390.png)

#### docker search

`docker search` 搜索镜像,也可以在docker hub上面直接查找

![image-20210705145004920](https://gitee.com/lgaaip/img/raw/master/image-20210705145004920.png)

![image-20210705145037360](https://gitee.com/lgaaip/img/raw/master/image-20210705145037360.png)

`docker search mysql --filter=STARS=4000`搜索显示star数大于等于4000的mysql镜像

![image-20210705145422801](https://gitee.com/lgaaip/img/raw/master/image-20210705145422801.png)



#### docker pull

`docker pull tomcat:版本`下载mysql镜像(不指定版本则默认为最新的)

```java
两者是等价的
docker pull tomcat 
docker pull docker.io/library/tomcat:latest
```

![image-20210705145927222](https://gitee.com/lgaaip/img/raw/master/image-20210705145927222.png)

`docker rmi`删除镜像

```shell
docker rmi -f 镜像id #删除指定镜像id 的镜像（镜像id可以指定多个）
docker rmi -f $(docker images -aq) # 删除所有镜像 
# $(docker images -aq) 递归查找了全部镜像的id
```

![image-20210705152301778](https://gitee.com/lgaaip/img/raw/master/image-20210705152301778.png)



### ③ 容器命令

```shell
docker run #镜像id 新建容器并启动
docker ps #列出所有运行的容器 docker container list
docker rm #容器id 删除指定容器
docker start 容器id #启动容器
docker restart 容器id #重启容器
docker stop 容器id #停止当前正在运行的容器
docker kill 容器id #强制停止当前容器
```

先下载一个镜像,`docker pull centos`

#### docker run

启动进去容器 `docker run -it centos /bin/bash`

我们可以看到,此时我们已经进入centos这个镜像了

![image-20210705152700487](https://gitee.com/lgaaip/img/raw/master/image-20210705152700487.png)

输入`exit`能够停止容器并退出，按`ctrl+P+Q`则可以不停止容器退出



#### docker ps

使用`docker ps`列出所有运行的容器

![image-20210705153917545](https://gitee.com/lgaaip/img/raw/master/image-20210705153917545.png)

```shell
[root@wosalan /]# docker ps --help #其它的命令

Usage:  docker ps [OPTIONS]

List containers

Options:
  -a, --all             Show all containers (default shows just running)
  -f, --filter filter   Filter output based on conditions provided
      --format string   Pretty-print containers using a Go template
  -n, --last int        Show n last created containers (includes all states) (default -1)
  -l, --latest          Show the latest created container (includes all states)
      --no-trunc        Don't truncate output
  -q, --quiet           Only display container IDs
  -s, --size            Display total file sizes
```

#### docker rm

`docker rm 容器id`  删除不了正在运行的容器，如果要强制删除使用  `rm -rf`

![image-20210705154547920](https://gitee.com/lgaaip/img/raw/master/image-20210705154547920.png)

```shell
docker rm -f $(docker ps -aq)  #删除指定的容器

docker ps -a -q|xargs docker rm  #删除所有的容器
```

![image-20210705154700678](https://gitee.com/lgaaip/img/raw/master/image-20210705154700678.png)

#### 启动和停止容器的命令

```shell
docker start 容器id	#启动容器
docker restart 容器id	#重启容器
docker stop 容器id	#停止当前正在运行的容器
docker kill 容器id	#强制停止当前容器
```



### ④ 常用其他命令

#### 后台启动命令

`docker run -d 镜像名`

![image-20210705155007347](https://gitee.com/lgaaip/img/raw/master/image-20210705155007347.png)

启动之后，发现执行`docker ps`后看不到容器，则可以说明centos启动之后被关闭了。

> 原因：
>
> 常见的坑，docker容器使用后台运行，就必须要有要一个前台进程，docker发现没有应用，就会自动停止
> eg ：nginx，容器启动后，发现自己没有提供服务，就会立刻停止，就是没有程序了

#### 查看日志

先使用`docker run -d centos /bin/sh -c "while true;do echo 6666;sleep 1;done"`模拟日志

`docker logs -t --tail 10 镜像id`：表示打印出 10 条日志 -t为时间戳 -tail为输出信息 

![image-20210705155423197](https://gitee.com/lgaaip/img/raw/master/image-20210705155423197.png)

#### 查看容器中进程信息

`docker top 容器id`可以查看进程信息

![image-20210705155648789](https://gitee.com/lgaaip/img/raw/master/image-20210705155648789.png)

`docker inspect 容器id`可以查看容器的元数据

![image-20210705155756749](https://gitee.com/lgaaip/img/raw/master/image-20210705155756749.png)



#### 进入正在运行的容器

`docker exec -it 容器id /bin/bash`

或者 `docker attach 容器id`

![image-20210705160143783](https://gitee.com/lgaaip/img/raw/master/image-20210705160143783.png)

![image-20210705160311705](https://gitee.com/lgaaip/img/raw/master/image-20210705160311705.png)

#### 从容器内拷贝到主机上

`docker cp 容器id:/1.java /`  第一个/为容器的目录，1.java为文件名，第二个/目标目录

![image-20210705160646323](https://gitee.com/lgaaip/img/raw/master/image-20210705160646323.png)



#### ⑤ 命令小结

![docker](https://gitee.com/lgaaip/img/raw/master/1.png)

```shell
attach      Attach local standard input, output, and error streams to a running container
  #当前shell下 attach连接指定运行的镜像
  build       Build an image from a Dockerfile # 通过Dockerfile定制镜像
  commit      Create a new image from a container's changes #提交当前容器为新的镜像
  cp          Copy files/folders between a container and the local filesystem #拷贝文件
  create      Create a new container #创建一个新的容器
  diff        Inspect changes to files or directories on a container's filesystem #查看docker容器的变化
  events      Get real time events from the server # 从服务获取容器实时时间
  exec        Run a command in a running container # 在运行中的容器上运行命令
  export      Export a container's filesystem as a tar archive #导出容器文件系统作为一个tar归档文件[对应import]
  history     Show the history of an image # 展示一个镜像形成历史
  images      List images #列出系统当前的镜像
  import      Import the contents from a tarball to create a filesystem image #从tar包中导入内容创建一个文件系统镜像
  info        Display system-wide information # 显示全系统信息
  inspect     Return low-level information on Docker objects #查看容器详细信息
  kill        Kill one or more running containers # kill指定docker容器
  load        Load an image from a tar archive or STDIN #从一个tar包或标准输入中加载一个镜像[对应save]
  login       Log in to a Docker registry #
  logout      Log out from a Docker registry
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  ps          List containers
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  run         Run a command in a new container
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  version     Show the Docker version information
  wait        Block until one or more containers stop, then print their exit codes
```



### 1️⃣ 例子1：下载nginx

下载nginx

```shell
#1. 搜索镜像 search 建议大家去docker搜索，可以看到帮助文档
#2. 拉取镜像 pull
#3、运行测试
# -d 后台运行
# --name 给容器命名
# -p 宿主机端口：容器内部端口
```

`docker run -d --name nginx01 -p 3344:80 nginx`

测试访问

![image-20210705164329718](https://gitee.com/lgaaip/img/raw/master/image-20210705164329718.png)

在阿里云安全组暴露 3344 端口，然后在浏览器访问 

![image-20210705164402991](https://gitee.com/lgaaip/img/raw/master/image-20210705164402991.png)

> 说明：
>
> 3344为服务器的端口，80为容器的端口
>
> -p 3344:80 此命令做了 将服务器的3344端口与容器的80端口做了映射，使得我们可以在公网访问3344时，能访问到容器的内容



### 2️⃣ 例子2：下载Tomcat

官方的这种操作一般都是用来测试的，用完就删除掉

![image-20210705185235425](https://gitee.com/lgaaip/img/raw/master/image-20210705185235425.png)

我们还是用普通的方法来下载

![image-20210705185333059](https://gitee.com/lgaaip/img/raw/master/image-20210705185333059.png)

`docker run -d -p 8080:8080 --name tomcat01 tomcat`启动tomcat

![image-20210705185455083](https://gitee.com/lgaaip/img/raw/master/image-20210705185455083.png)

浏览器访问

![image-20210705185636920](https://gitee.com/lgaaip/img/raw/master/image-20210705185636920.png)

我们进入到tomcat的webapps目录下，发现文件夹下面为空的！

发现问题，我们从阿里云镜像官方下载下来的都是阉割版的，都是最小环境启动！

![image-20210705185928580](https://gitee.com/lgaaip/img/raw/master/image-20210705185928580.png)

**思考问题：**我们以后要部署项目，如果每次都要进入容器是不是十分麻烦？要是可以在容器外部提供一个映射路径，webapps，我们在外部放置项目，就自动同步内部就好了！

### 3️⃣ 例子：下载es

还是同样使用 `docker pull `去下载

**慎重启动！！！**

```java
运行的时候要限制占用的内存大小不然cpu直接被挤爆
docker run -d --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx512m" elasticsearch:7.6.2
```

可以使用 `docker stats`查看docker容器使用的内存情况

![image-20210705191050070](https://gitee.com/lgaaip/img/raw/master/image-20210705191050070.png)

### ⑤ 可视化

#### portainer

Docker图形化界面管理工具！提供一个后台面板供我们操作！

```shell
docker run -d -p 8080:9000 \
--restart=always -v /var/run/docker.sock:/var/run/docker.sock --privileged=true portainer/portainer
```

访问 8080 ：

自己设置密码

![image-20210705191904420](https://gitee.com/lgaaip/img/raw/master/image-20210705191904420.png)

后台面板：

![image-20210705192102954](https://gitee.com/lgaaip/img/raw/master/image-20210705192102954.png)



## 二、Docker镜像讲解

### 镜像是什么

镜像是一种轻量级、可执行的独立软件保，用来打包软件运行环境和基于运行环境开发的软件，他包含运行某个软件所需的所有内容，包括代码、运行时库、环境变量和配置文件

### Docker镜像加载原理

#### UnionFs （联合文件系统）

UnionFs（联合文件系统）：Union文件系统（UnionFs）是一种分层、轻量级并且高性能的文件系统，他支持对文件系统的修改作为一次提交来一层层的叠加，同时可以将不同目录挂载到同一个虚拟文件系统下（ unite several directories into a single virtual filesystem)。Union文件系统是 Docker镜像的基础。镜像可以通过分层来进行继承，基于基础镜像（没有父镜像），可以制作各种具体的应用镜像
特性：一次同时加载多个文件系统，但从外面看起来，只能看到一个文件系统，联合加载会把各层文件系统叠加起来，这样最终的文件系统会包含所有底层的文件和目录

#### Docker镜像加载原理

docker的镜像实际上由一层一层的文件系统组成，这种层级的文件系统UnionFS。
boots(boot file system）主要包含 bootloader和 Kernel, bootloader主要是引导加 kernel, Linux刚启动时会加bootfs文件系统，在 Docker镜像的最底层是 boots。这一层与我们典型的Linux/Unix系统是一样的，包含boot加载器和内核。当boot加载完成之后整个内核就都在内存中了，此时内存的使用权已由 bootfs转交给内核，此时系统也会卸载bootfs。
rootfs（root file system),在 bootfs之上。包含的就是典型 Linux系统中的/dev,/proc,/bin,/etc等标准目录和文件。 rootfs就是各种不同的操作系统发行版，比如 Ubuntu, Centos等等。

![img](https://gitee.com/lgaaip/img/raw/master/20210706121819.png)

平时我们安装进虚拟机的CentOS都是好几个G，为什么Docker这里才200M？

![image-20210706133023021](https://gitee.com/lgaaip/img/raw/master/20210706133023.png)

对于个精简的OS,rootfs可以很小，只需要包合最基本的命令，工具和程序库就可以了，因为底层直接用Host的kernel，自己只需要提供rootfs就可以了。由此可见对于不同的Linux发行版， boots基本是一致的， rootfs会有差別，因此不同的发行版可以公用bootfs.

虚拟机是分钟级别，容器是秒级！



#### 分层理解

我们在下载镜像的时候，可以看到都是分层进行下载的

![image-20210706133253171](https://gitee.com/lgaaip/img/raw/master/20210706133253.png)

**思考：为什么Docker镜像要采用这种分层的结构呢？**

最大的好处，我觉得莫过于`资源共享`了！比如有多个镜像都从相同的Base镜像构建而来，那么宿主机只需在磁盘上保留一份base镜像，同时内存中也只需要加载一份base镜像，这样就可以为所有的容器服务了，而且镜像的每一层都可以被共享。

查看镜像分层的方式可以通过`docker image inspect` 命令

```shell
[root@wosalan ~]# docker image inspect centos
[
    {
        "Id": "sha256:300e315adb2f96afe5f0b2780b87f28ae95231fe3bdd1e16b9ba606307728f55",
        "RepoTags": [
            "centos:latest"
        ],
        "RepoDigests": [
            "centos@sha256:5528e8b1b1719d34604c87e11dcd1c0a20bedf46e83b5632cdeac91b8c04efc1"
        ],
        "Parent": "",
        "Comment": "",
        "Created": "2020-12-08T00:22:53.076477777Z",
        "Container": "395e0bfa7301f73bc994efe15099ea56b8836c608dd32614ac5ae279976d33e4",
        "ContainerConfig": {
            "Hostname": "395e0bfa7301",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/sh",
                "-c",
                "#(nop) ",
                "CMD [\"/bin/bash\"]"
            ],
            "Image": "sha256:6de05bdfbf9a9d403458d10de9e088b6d93d971dd5d48d18b4b6758f4554f451",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.label-schema.build-date": "20201204",
                "org.label-schema.license": "GPLv2",
                "org.label-schema.name": "CentOS Base Image",
                "org.label-schema.schema-version": "1.0",
                "org.label-schema.vendor": "CentOS"
            }
        },
        "DockerVersion": "19.03.12",
        "Author": "",
        "Config": {
            "Hostname": "",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/bash"
            ],
            "Image": "sha256:6de05bdfbf9a9d403458d10de9e088b6d93d971dd5d48d18b4b6758f4554f451",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.label-schema.build-date": "20201204",
                "org.label-schema.license": "GPLv2",
                "org.label-schema.name": "CentOS Base Image",
                "org.label-schema.schema-version": "1.0",
                "org.label-schema.vendor": "CentOS"
            }
        },
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 209348104,
        "VirtualSize": 209348104,
        "GraphDriver": {
            "Data": {
                "MergedDir": "/var/lib/docker/overlay2/97814b820aef4e0b982b668badb83ca45a1edaadd8f4b7d851601c880e5bd389/merged",
                "UpperDir": "/var/lib/docker/overlay2/97814b820aef4e0b982b668badb83ca45a1edaadd8f4b7d851601c880e5bd389/diff",
                "WorkDir": "/var/lib/docker/overlay2/97814b820aef4e0b982b668badb83ca45a1edaadd8f4b7d851601c880e5bd389/work"
            },
            "Name": "overlay2"
        },
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:2653d992f4ef2bfd27f94db643815aa567240c37732cae1405ad1c1309ee9859"
            ]
        },
        "Metadata": {
            "LastTagTime": "0001-01-01T00:00:00Z"
        }
    }
]

```

**理解：**

所有的 Docker镜像都起始于一个基础镜像层，当进行修改或培加新的内容时，就会在当前镜像层之上，创建新的镜像层。

举一个简单的例子，假如基于 Ubuntu Linux16.04创建一个新的镜像，这就是新镜像的第一层；如果在该镜像中添加 Python包，
就会在基础镜像层之上创建第二个镜像层；如果继续添加一个安全补丁，就会创健第三个镜像层该像当前已经包含3个镜像层，如下图所示（这只是一个用于演示的很简单的例子）。

![image-20200515165234274](https://gitee.com/lgaaip/img/raw/master/20210706133535.png)


在添加额外的镜像层的同时，镜像始终保持是当前所有镜像的组合，理解这一点非常重要。下图中举了一个简单的例子，每个镜像层包含3个文件，而镜像包含了来自两个镜像层的6个文件。

![image-20200515164958932](https://gitee.com/lgaaip/img/raw/master/20210706133544.png)

上图中的镜像层跟之前图中的略有区別，主要目的是便于展示文件
下图中展示了一个稍微复杂的三层镜像，在外部看来整个镜像只有6个文件，这是因为最上层中的文件7是文件5的一个更新版

![image-20200515165148002](https://gitee.com/lgaaip/img/raw/master/20210706133551.png)

文种情況下，上层镜像层中的文件覆盖了底层镜像层中的文件。这样就使得文件的更新版本作为一个新镜像层添加到镜像当中

Docker通过存储引擎（新版本采用快照机制）的方式来实现镜像层堆栈，并保证多镜像层对外展示为统一的文件系统

Linux上可用的存储引撃有AUFS、 Overlay2、 Device Mapper、Btrfs以及ZFS。顾名思义，每种存储引擎都基于 Linux中对应的
件系统或者块设备技术，井且每种存储引擎都有其独有的性能特点。

Docker在 Windows上仅支持 windowsfilter 一种存储引擎，该引擎基于NTFS文件系统之上实现了分层和CoW [1]。

下图展示了与系统显示相同的三层镜像。所有镜像层堆并合井，对外提供统一的视图

![image-20200515165557807](https://gitee.com/lgaaip/img/raw/master/20210706133604.png)

`特点`

Docker 镜像都是只读的，当容器启动时，一个新的可写层加载到镜像的顶部！

这一层就是我们通常说的容器层，容器之下的都叫镜像层.

### commit镜像

我们可以通过commit命令去自己制作提交一个镜像

`docker commit -m="描述信息" -a="作者" 容器id 目标镜像名:[TAG]`

**测试：**

我们在前面知道从docker hub上面下载的tomcat跟我们之前的不一样，webapps目录下是空的，此时我们可以将webapps下的文件还原了，然后再打成一个镜像，这个镜像就是我们自定义的。

1、`docker run -d -p 8080:8080 --name tomcat02 tomcat`启动tomcat

![image-20210706133911664](https://gitee.com/lgaaip/img/raw/master/20210706133912.png)

2、`docker exec -it 容器id` 进入容器

![image-20210706133924227](https://gitee.com/lgaaip/img/raw/master/20210706133924.png)

3、`cp -r webapps.dist/* webapps`

将webapps.dist中的文件全部拷贝到webapps（因为webapps.dist中的文件就是原来tomcat默认的文件）

![image-20210706134005769](https://gitee.com/lgaaip/img/raw/master/20210706134006.png)

4、`ctrl+P+Q`退出镜像

5、`docker commit -a="Alan" -m="add webapps app" e81a4048d79f tomcat01:1.0`将我们刚刚修改后的容器打包成镜像发布

![image-20210706134231595](https://gitee.com/lgaaip/img/raw/master/20210706134232.png)

6、此时我们使用 `docker images`查看此时我们机上的镜像，就有了我们刚刚打的那个镜像了。

![image-20210706134300812](https://gitee.com/lgaaip/img/raw/master/20210706134301.png)



### 📕 Reference

[【狂神说Java】Docker最新超详细版教程通俗易懂](https://www.bilibili.com/video/BV1og4y1q7M4?p=20)

