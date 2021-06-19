## 一、Netty 的介绍 

1) Netty 是由 JBOSS 提供的一个 **Java** **开源框架**，现为 **Github** **上的独立项目**。 

2) Netty 是一个**异步**的、**基于事件驱动**的网络应用框架，用以快速开发高性能、高可靠性的网络 IO 程序。

3) Netty 主要针对在 TCP 协议下，面向 Clients 端的高并发应用，或者 Peer-to-Peer 场景下的大量数据持续传输的应用。 

4) Netty 本质是一个 NIO 框架，适用于服务器通讯相关的多种应用场景。

5) 要透彻理解 Netty ， 需要先学习 NIO ， 这样我们才能阅读 Netty 的源码。



## 二、Java BIO编程

### 1、I/O 模型 

####  I/O 模型基本说明 

1) I/O 模型简单的理解：就是用什么样的通道进行数据的发送和接收，很大程度上决定了程序通信的性能 

2) Java 共支持 3 种网络编程模型/IO 模式：BIO、NIO、AIO 

3) Java BIO ： 同步并阻塞(传统阻塞型)，服务器实现模式为一个连接一个线程，即客户端有连接请求时服务器端就需要启动一个线程进行处理，如果这个连接不做任何事情会造成不必要的线程开销 

![image-20210619001841895](https://gitee.com/lgaaip/img/raw/master/image-20210619001841895.png)

4) Java NIO ： 同步非阻塞，服务器实现模式为一个线程处理多个请求(连接)，即客户端发送的连接请求都会注 册到多路复用器上，多路复用器轮询到连接有 I/O 请求就进行处理 

![image-20210619001922321](https://gitee.com/lgaaip/img/raw/master/image-20210619001922321.png)

5) Java AIO(NIO.2) ： 异步非阻塞，AIO 引入异步通道的概念，采用了 Proactor 模式，简化了程序编写，有效 的请求才启动线程，它的特点是先由操作系统完成后才通知服务端程序启动线程去处理，一般适用于连接数较 多且连接时间较长的应用

### 2、BIO、NIO、AIO 适用场景分析 

1) BIO 方式适用于连接数目比较小且固定的架构，这种方式对服务器资源要求比较高，并发局限于应用中，JDK1.4 以前的唯一选择，但程序简单易理解。 

2) NIO 方式适用于连接数目多且连接比较短（轻操作）的架构，比如聊天服务器，弹幕系统，服务器间通讯等。 编程比较复杂，JDK1.4 开始支持。

3) AIO 方式使用于连接数目多且连接比较长（重操作）的架构，比如相册服务器，充分调用 OS 参与并发操作， 编程比较复杂，JDK7 开始支持。 



### 3、Java BIO 基本介绍 

1) Java **BIO** 就是传统的 **java io** **编程**，其相关的类和接口在 java.io 

2) BIO(**blocking I/O**) ： 同步阻塞，服务器实现模式为一个连接一个线程，即客户端有连接请求时服务器端就需 要启动一个线程进行处理，如果这个连接不做任何事情会造成不必要的线程开销，可以通过线程池机制改善(实 现多个客户连接服务器)。 

3) BIO 方式适用于连接数目比较小且固定的架构，这种方式对服务器资源要求比较高，并发局限于应用中，JDK1.4 以前的唯一选择，程序简单易理解 



### 4、Java BIO 工作机制

**对** **BIO** **编程流程的梳理** 

1) 服务器端启动一个 ServerSocket 

2) 客户端启动 Socket 对服务器进行通信，默认情况下服务器端需要对每个客户 建立一个线程与之通讯尚硅谷 Netty 核心技术及源码剖析 

3) 客户端发出请求后, 先咨询服务器是否有线程响应，如果没有则会等待，或者被拒绝 

4) 如果有响应，客户端线程会等待请求结束后，在继续执行



### 5、Java BIO 应用实例

实例说明： 

1) 使用 BIO 模型编写一个服务器端，监听 6666 端口，当有客户端连接时，就启动一个线程与之通讯。 

2) 要求使用线程池机制改善，可以连接多个客户端. 

3) 服务器端可以接收客户端发送的数据(telnet 方式即可)。

```java
package com.alan.bio;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @Author Alan
 * @Date 2021/6/19 19:38
 * @Description
 * @Version 1.0
 */
public class BIOServer {
    private final static Logger logger = LoggerFactory.getLogger(BIOServer.class);

    public static void main(String[] args) throws IOException {

        // 线程池
        ExecutorService newCachedThreadPool = Executors.newCachedThreadPool();
        // 创建 ServerSocket
        ServerSocket serverSocket = new ServerSocket(6666);
        logger.info("服务器启动....");
        while(true){
            logger.warn("等待客户端连接....");
            final Socket socket = serverSocket.accept();
            logger.warn("连接到一个客户端....");
            newCachedThreadPool.execute(new Runnable() {
                @Override
                public void run() {
                    handler(socket);
                }
            });
        }
    }

    private static void handler(Socket socket) {
        try {
            byte[] bytes = new byte[1024];
            InputStream inputStream = socket.getInputStream();

            // 循环读取客户端的消息
            while(true){
                int read = inputStream.read(bytes);
                if (read != -1){
                    logger.info(new String(bytes,0,read));
                }else{
                    break;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }finally {
            try {
                logger.warn("关闭客户端连接....");
                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }
}

```

使用 `telnet` 连接到服务端

![image-20210619195415399](https://gitee.com/lgaaip/img/raw/master/image-20210619195415399.png)

使用 `send` 发送消息

![image-20210619195457842](https://gitee.com/lgaaip/img/raw/master/image-20210619195457842.png)

### 6、Java BIO 问题分析

1) 每个请求都需要创建独立的线程，与对应的客户端进行数据 Read，业务处理，数据 Write 。

2) 当并发数较大时，需要创建大量线程来处理连接，系统资源占用较大。 

3) 连接建立后，如果当前线程暂时没有数据可读，则线程就阻塞在 Read 操作上，造成线程资源浪费

## 三、Java NIO编程