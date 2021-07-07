# Docker进阶

## 容器数据卷

### 什么是容器数据卷

当我们在使用docker容器的时候，会产生一系列的数据文件，这些数据文件在我们关闭docker容器时是会消失的，但是其中产生的部分内容我们是希望能够把它给保存起来另作用途的，Docker将应用与运行环境打包成容器发布，我们希望在运行过程钟产生的部分数据是可以持久化的，而且容器之间我们希望能够实现数据共享。

通俗地来说，docker容器数据卷可以看成使我们生活中常用的u盘，它存在于一个或多个的容器中，由docker挂载到容器，但不属于联合文件系统，Docker不会在容器删除时删除其挂载的数据卷。

**特点：**

1：数据卷可以在容器之间共享或重用数据

2：数据卷中的更改可以直接生效

3：数据卷中的更改不会包含在镜像的更新中

4：数据卷的生命周期一直持续到没有容器使用它为止

**添加数据卷的方式有两种，第一种是直接通过命令行挂载，第二种是通过dockerFile添加**

### 使用命令行挂载

首先来说第一种通过命令行挂载的方式，命令如下：

`docker run -it -v  /宿主机绝对路径目录:  /容器内目录  镜像名`

这个命令会在宿主机和容器内分别建立两个目录，两个目录是对接的，里面的数据可以共享。如果我们不知道数据卷是否挂载成功时，我们可以通过以下方式来检查数据卷的挂载结果。

![image-20210706192628373](https://gitee.com/lgaaip/img/raw/master/20210706192629.png)

使用 `docker inspect  容器id`可以查看挂载情况

![image-20210706194136355](https://gitee.com/lgaaip/img/raw/master/20210706194137.png)

上面的命令可以查看容器的详细情况，命令返回的是JSON格式的字符串，运行命令之后我们在返回的JSON字符串中找到Volumes属性，假如挂载成功的话，Volumes里面显示的绑定结果应该是你在挂载时输入的命令参数 （/宿主机绝对路径目录:  /容器内目录 ），如果与你们之前输入的一致的话，证明挂载成功。

PS: Volumes里面显示的绑定结果可能有多个，但是只要找到目标结果就可以。挂载之后，当容器停止运行的时候，宿主机上对数据卷做的内容修改是会同步到容器内的。

我们再挂载的时候还可以给数据卷加上权限，假如我们要宿主机只能读取容器的数据卷内容不能修改，我们可以添加只读权限

`docker run -it -v /宿主机绝对路径目录 ： /容器内目录  ：ro 镜像名`

至于只写的话我们一般不会用到，要么就是读写，要么就是只读，而且我们可以通过docker inspect 来查看容器的volumesRW来查看容器内数据卷的读写权限。

```shell
# 通过 -v 容器内路径： ro rw 改变读写权限
ro #readonly 只读
rw #readwrite 可读可写
docker run -d -P --name nginx05 -v juming:/etc/nginx:ro nginx
docker run -d -P --name nginx05 -v juming:/etc/nginx:rw nginx

# ro 只要看到ro就说明这个路径只能通过宿主机来操作，容器内部是无法操作！

```

### 具名和匿名挂载

具名挂载和匿名挂载的区别就是在挂载的时候有无命名，如果没有则会自动生成。

**具名挂载**

`docker run -d -P --name nginx02 -v juming-nginx:/etc/nginx nginx`

所有的docker容器内的卷，没有指定宿主机的目录的情况下都是在`/var/lib/docker/volumes/xxxx/_data`下

![image-20210706195700938](https://gitee.com/lgaaip/img/raw/master/20210706195701.png)

如果指定了目录，docker volume ls 是查看不到的。



### 初始 Dockerfile

dockerFile对于docker镜像而言就如同java中某个类的.class文件对应上该类的.java文件。

编写的dockerfile1文件如下

```shell
FROM  镜像名

VOLUME ["/生成的目录路径"]  

CMD echo "success build"

CMD /bin/bash
```

相当于命令行： `docker run -it -v /宿主机目录路径 :  /生成的目录路径`

然后我们通过命令行docker build执行我们写好的dockerFile文件

（docker build和docker commit两个命令都可以建立docker镜像，**docker commit 需要在容器内进行，docker build 不需要**）

`docker build -f  dockerfile1 -t  命名空间/镜像名:版本号 .`

![image-20210706201807056](https://gitee.com/lgaaip/img/raw/master/20210706201807.png)

查看我们的镜像，可以看到我们的镜像生成了！！！

![image-20210706201834931](https://gitee.com/lgaaip/img/raw/master/20210706201836.png)

### 数据卷容器

```shell
# 启动mysql 并将宿主机的目录/home/mysql/conf 和/home/mysql/data 挂载到 /etc/mysql/conf.d 和 /var/lib/mysql
docker run -d -p 3310:3306 -v /home/mysql/conf:/etc/mysql/conf.d -v /home/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 --name mysql01 mysql:5.7
# 再启动一个mysql 将这个容器挂载到mysql01这个容器上
docker run -d -p 3311:3306 -e MYSQL_ROOT_PASSWORD=123456 --name mysql02 --volumes-from mysql01  mysql:5.7
```

## Dockerfile

dockerfile相当于docker中的一个脚本文件，我们可以在里面写命令然后去制作出一个镜像，每一条命令都是一层镜像，然后一层层的镜像一起堆积，最后组成一个大的镜像！！！

```shell
FROM				# 基础镜像，一切从这里开始构建
MAINTAINER			# 镜像是谁写的， 姓名+邮箱
RUN					# 镜像构建的时候需要运行的命令
ADD					# 步骤，tomcat镜像，这个tomcat压缩包！添加内容 添加同目录
WORKDIR				# 镜像的工作目录
VOLUME				# 挂载的目录
EXPOSE				# 保留端口配置
CMD					# 指定这个容器启动的时候要运行的命令，只有最后一个会生效，可被替代。
ENTRYPOINT			# 指定这个容器启动的时候要运行的命令，可以追加命令
ONBUILD				# 当构建一个被继承 DockerFile 这个时候就会运行ONBUILD的指令，触发指令。
COPY				# 类似ADD，将我们文件拷贝到镜像中
ENV					# 构建的时候设置环境变量！
```



