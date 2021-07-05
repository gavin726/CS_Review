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



### 例子1：

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

