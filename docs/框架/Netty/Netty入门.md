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

### 1、Java NIO 基本介绍 

1) Java NIO 全称 **java non-blocking IO**，是指 JDK 提供的新 API。从 JDK1.4 开始，Java 提供了一系列改进的 输入/输出的新特性，被统称为 NIO(即 New IO)，是同步非阻塞的 

2) NIO 相关类都被放在 **java.nio** 包及子包下，并且对原 java.io 包中的很多类进行改写。

3) NIO 有三大核心部分：**Channel(通道)**，**Buffer(缓冲区), Selector(选择器) **

4) **NIO** **是 面向缓冲区** ，**或者面向 块 编程的**。数据读取到一个它稍后处理的缓冲区，需要时可在缓冲区中前后 移动，这就增加了处理过程中的灵活性，使用它可以提供非阻塞式的高伸缩性网络 

5) Java NIO 的非阻塞模式，使一个线程从某通道发送请求或者读取数据，但是它仅能得到目前可用的数据，如果 目前没有数据可用时，就什么都不会获取，而不是保持线程阻塞，所以直至数据变的可以读取之前，该线程可 以继续做其他的事情。 非阻塞写也是如此，一个线程请求写入一些数据到某通道，但不需要等待它完全写入， 这个线程同时可以去做别的事情。【后面有案例说明】 

6) 通俗理解：NIO 是可以做到用一个线程来处理多个操作的。假设有 10000 个请求过来,根据实际情况，可以分配50 或者 100 个线程来处理。不像之前的阻塞 IO 那样，非得分配 10000 个。 

7) HTTP2.0 使用了多路复用的技术，做到同一个连接并发处理多个请求，而且并发请求的数量比 HTTP1.1 大了好 几个数量级 

8）小案例

```java
public class BasicBuffer {
    public static void main(String[] args) {

        IntBuffer intBuffer = IntBuffer.allocate(5);

        for (int i = 0; i < intBuffer.capacity(); i++) {
            intBuffer.put(i*2);
        }
        // 切换为读模式
        intBuffer.flip();

        while (intBuffer.hasRemaining()){
            System.out.println(intBuffer.get());
        }
    }
}
```

### 2、NIO和BIO的比较

1) BIO 以流的方式处理数据,而 NIO 以块的方式处理数据,块 I/O 的效率比流 I/O 高很多 

2) BIO 是阻塞的，NIO 则是非阻塞的 

3) BIO 基于字节流和字符流进行操作，而 NIO 基于 Channel(通道)和 Buffer(缓冲区)进行操作，数据总是从通道读取到缓冲区中，或者从缓冲区写入到通道中。Selector(选择器)用于监听多个通道的事件（比如：连接请求， 数据到达等），因此使用单个线程就可以监听多个客户端通道

### 3、NIO 三大核心原理示意图 

1) 每个 `channel `都会对应一个 `Buffer` 

2) `Selector` 对应一个线程， 一个线程对应多个 `channel`(连接) 

3) 该图反应了有三个 `channel` 注册到 该 `selector`   

4) 程序切换到哪个 channel 是由事件决定的, Event 就是一个重要的概念 

5) **Selector 会根据不同的事件，在各个通道上切换** 

6) `Buffer 就是一个内存块 ， 底层是有一个数组` 

7) NIO中数据的读取与写入都是通过Buffer去实现的，这一点跟BIO并不一样，BIO中要么是输入流要么是输出流，一个流都是单向的，不能双向，而NIO能够通过`flip`方法切换读写模式，使得**Buffer是双向的**。 channel 也是双向的, 可以返回底层操作系统的情况, 比如 Linux ， 底层的操作系统 通道就是双向的。

![image-20210619225756055](https://gitee.com/lgaaip/img/raw/master/image-20210619225756055.png)

