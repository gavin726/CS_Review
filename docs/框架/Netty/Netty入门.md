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

### 4、缓冲区(Buffer)

#### ① 基本介绍 

缓冲区（Buffer）：缓冲区本质上是一个**可以读写数据的内存块**，可以理解成是一个**容器对象(含数组)**，该对 

象提供了一组方法，可以更轻松地使用内存块，，缓冲区对象内置了一些机制，能够跟踪和记录缓冲区的状态变化情况。Channel 提供从文件、网络读取数据的渠道，但是读取或写入的数据都必须经由 Buffer，

![image-20210627094719103](https://gitee.com/lgaaip/img/raw/master/image-20210627094719103.png)

#### ② Buffer 类及其子类

1) 在 NIO 中，Buffer 是一个顶层父类，它是一个抽象类, 类的层级关系图: 

![image-20210627095016154](https://gitee.com/lgaaip/img/raw/master/image-20210627095016154.png)

![image-20210627095054263](https://gitee.com/lgaaip/img/raw/master/image-20210627095054263.png)

2) Buffer 类定义了所有的缓冲区都具有的四个属性来提供关于其所包含的数据元素的信息:

![image-20210627095116963](https://gitee.com/lgaaip/img/raw/master/image-20210627095116963.png)

3) Buffer 类相关方法一览

![image-20210627095134107](https://gitee.com/lgaaip/img/raw/master/image-20210627095134107.png)

#### ③ ByteBuffer

从前面可以看出对于 Java 中的基本数据类型(boolean 除外)，都有一个 Buffer 类型与之相对应，最常用的自然是 ByteBuffer 类（二进制数据），该类的主要方法如下： 

![image-20210627095200718](https://gitee.com/lgaaip/img/raw/master/image-20210627095200718.png)

### 5、通道(Channel) 

#### ① 基本介绍 

1) NIO 的通道类似于流，但有些区别如下： 

-  通道可以同时进行读写，而流只能读或者只能写 

- 通道可以实现异步读写数据 

- 通道可以从缓冲读数据，也可以写数据到缓冲: 

2) BIO 中的 stream 是单向的，例如 FileInputStream 对象只能进行读取数据的操作，而 NIO 中的通道(Channel) 是双向的，可以读操作，也可以写操作。 

3) Channel 在 NIO 中是一个接口 public interface Channel extends Closeable{} 

4) 常 用 的 Channel 类 有 ： **FileChannel** 、 DatagramChannel 、 **ServerSocketChannel** 和 **SocketChannel** 【ServerSocketChanne 类似 ServerSocket , SocketChannel 类似 Socket】

5) FileChannel 用于文件的数据读写，DatagramChannel 用于 UDP 的数据读写，ServerSocketChannel 和 SocketChannel 用于 TCP 的数据读写。 

6) 图示：

![image-20210627095449849](https://gitee.com/lgaaip/img/raw/master/image-20210627095449849.png)

#### ② FileChannel 类 

FileChannel 主要用来对本地文件进行 IO 操作，常见的方法有 

- public int read(ByteBuffer dst) ，从通道读取数据并放到缓冲区中 

- public int write(ByteBuffer src) ，把缓冲区的数据写到通道中 

- public long transferFrom(ReadableByteChannel src, long position, long count)，从目标通道中复制数据到当前通道 

- public long transferTo(long position, long count, WritableByteChannel target)，把数据从当前通道复制给目标通道



#### ③ 应用实例 1-本地文件写数据

1) 使用前面学习后的 ByteBuffer(缓冲) 和 FileChannel(通道)， 将 "你好,netty!" 写入到 1.txt 中 

2) 文件不存在就创建 

3) 代码演示 

```java
public class NIOFileChannel01 {
    public static void main(String[] args) throws Exception{

        String str = "你好,netty!";
        // 创建一个输出流
        FileOutputStream fileOutputStream = new FileOutputStream("f:\\1.txt");
        // 获取channel
        FileChannel fileChannel = fileOutputStream.getChannel();

        // 创建缓冲区
        ByteBuffer buffer = ByteBuffer.allocate(1024);
        // 将字符串数据放进缓冲区中
        buffer.put(str.getBytes());
        // 反转
        buffer.flip();
        // 将缓冲区中的数据写进channel中
        fileChannel.write(buffer);
        // 关闭输出流
        fileOutputStream.close();


    }
}

```



#### ④ 应用实例 2-本地文件读数据

实例要求: 

1) 使用前面学习后的 ByteBuffer(缓冲) 和 FileChannel(通道)， 将 1.txt 中的数据读入到程序，并显示在控制台屏幕 

2) 假定文件已经存在 

3) 代码演示 

```java
public class NIOFileChannel02 {
    public static void main(String[] args) throws Exception{

        File file = new File("f:\\1.txt");

        FileInputStream fileInputStream = new FileInputStream(file);

        FileChannel fileChannel = fileInputStream.getChannel();

        // 创建缓冲区
        ByteBuffer buffer = ByteBuffer.allocate((int) file.length());
        // 读取channel中的数据
        fileChannel.read(buffer);

        System.out.println(new String(buffer.array()));


    }
}

```



#### ⑤ 应用实例 3-使用一个 Buffer 完成文件读取、写入

实例要求: 

1) 使用 FileChannel(通道) 和 方法 read , write，完成文件的拷贝 

2) 拷贝一个文本文件 1.txt , 放在项目下即可 

3) 代码演示 

```java
public class NIOFileChannel03 {
    public static void main(String[] args) throws Exception{

        File file = new File("f:\\1.txt");
        FileInputStream fileInputStream = new FileInputStream(file);
        FileChannel fileChannel1 = fileInputStream.getChannel();

        FileOutputStream fileOutputStream = new FileOutputStream("f:\\2.txt");
        FileChannel fileChannel2 = fileOutputStream.getChannel();

        ByteBuffer buffer = ByteBuffer.allocate(1024);

        while (true){

            // 这一步很重要，每次清空缓冲区，不然的话会一直死循环
            buffer.clear();
            /**
             * public final Buffer clear() {
             *         position = 0;
             *         limit = capacity;
             *         mark = -1;
             *         return this;
             *     }
             */

            // 将channel中的数据读到缓冲区中
            int read = fileChannel1.read(buffer);
            System.out.println(read);
            // 读完了就退出
            if (read == -1)
                break;
            // 写入，需要反转
            buffer.flip();
            // 将缓冲区中的数据写入channel中
            fileChannel2.write(buffer);
        }
        fileInputStream.close();
        fileOutputStream.close();
    }
}

```



#### ⑥ 应用实例 4-拷贝文件 transferFrom 方法

实例要求: 

1) 使用 FileChannel(通道) 和 方法 transferFrom ，完成文件的拷贝 

2) 拷贝一张图片 

3) 代码演示 

```java
public class NIOFileChannel04 {
    public static void main(String[] args) throws Exception{

        FileInputStream fileInputStream = new FileInputStream("f:\\a.jpg");
        FileOutputStream fileOutputStream = new FileOutputStream("f:\\a1.jpg");

        FileChannel channel1 = fileInputStream.getChannel();
        FileChannel channel2 = fileOutputStream.getChannel();

        // 将channel1 拷贝 给 channel2
        channel2.transferFrom(channel1,0,channel1.size());

        fileInputStream.close();
        fileOutputStream.close();
    }
}

```



#### ⑦ 关于 Buffer 和 Channel 的注意事项和细节 

1) ByteBuffer 支持类型化的 put 和 get, put 放入的是什么数据类型，get 就应该使用相应的数据类型来取出，否则可能有 `BufferUnderflowException` 异常。

```java
public class NIOByteBufferPutGet {
    public static void main(String[] args) {

        ByteBuffer byteBuffer = ByteBuffer.allocate(64);

        byteBuffer.putInt(11);
        byteBuffer.putShort((short) 11);
        byteBuffer.putLong(11);
        byteBuffer.putChar('A');

        byteBuffer.flip();

        System.out.println(byteBuffer.getInt());
        System.out.println(byteBuffer.getShort());
        System.out.println(byteBuffer.getLong());
        System.out.println(byteBuffer.getChar());

        //System.out.println(byteBuffer.getLong());
        // 当get获取的字节数大于put的字节数则会报错

    }
}

```

2) 可以将一个普通 Buffer 转成只读 Buffer ,put数据会报 `ReadOnlyBufferException` 异常

```java
public class ReadOnlyBuffer {
    public static void main(String[] args) {

        ByteBuffer buffer = ByteBuffer.allocate(64);

        for (int i = 0; i < 64; i++) {
            buffer.put((byte) i);
        }

        //读取
        buffer.flip();

        // 只读缓冲区
        ByteBuffer readOnlyBuffer = buffer.asReadOnlyBuffer();
        System.out.println(readOnlyBuffer.getClass());

        while (readOnlyBuffer.hasRemaining()){
            System.out.println(readOnlyBuffer.get());
        }

        readOnlyBuffer.put((byte)1);  //报错 ReadOnlyBufferException
    }
}
```

3) NIO 还提供了 **MappedByteBuffer**， 可以让文件直接在内存（堆外的内存）中进行修改， 而如何同步到文件 由 NIO 来完成.

```java
public class MappedByteBufferTest {
    public static void main(String[] args) throws Exception{

        RandomAccessFile randomAccessFile = new RandomAccessFile("f:\\1.txt","rw");
        // 获取通道
        FileChannel channel = randomAccessFile.getChannel();

        /**
         * 参数 1: FileChannel.MapMode.READ_WRITE 使用的读写模式
         * 参数 2： 0 ： 可以直接修改的起始位置
         * 参数 3:  5:  是映射到内存的大小(不是索引位置) ,即从起始位置起的多少个字节映射到内存
         * 可以直接修改的范围就是 [0-5)     实际类型 DirectByteBuffer
         */
        MappedByteBuffer mappedByteBuffer = channel.map(FileChannel.MapMode.READ_WRITE, 0, 5);

        mappedByteBuffer.put(0, (byte) 'A');
        mappedByteBuffer.put(4, (byte) 'N');
        // 超出了范围会报异常 ，但是前面的可以修改成功!
        mappedByteBuffer.put(5, (byte) 'Y'); //IndexOutOfBoundsException

        randomAccessFile.close();
        System.out.println("修改完成!");
    }
}
```

4) 前面我们讲的读写操作，都是通过一个 Buffer 完成的，NIO 还支持 通过多个 Buffer (即 Buffer 数组) 完成读 写操作，即 Scattering 和 Gathering :

从Channel中读数据到buffer数组的时候，会进行分散存储，然后从buffer数组中读数据到Channel中的时候，会进行聚合读取

```java
//Scattering：将数据写入到 buffer 时，可以采用 buffer 数组，依次写入 [分散]
//Gathering: 从 buffer 读取数据时，可以采用 buffer 数组，依次读
public class ScatteringAndGatheringTest {
    public static void main(String[] args) throws Exception{

        // 使用ServerSocketChannel和SocketChannel
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        InetSocketAddress inetSocketAddress = new InetSocketAddress(8888);

        // 绑定端口到socket，并启动
        serverSocketChannel.socket().bind(inetSocketAddress);

        //创建 buffer 数组
        ByteBuffer[] byteBuffers = new ByteBuffer[2];
        byteBuffers[0] = ByteBuffer.allocate(5);
        byteBuffers[1] = ByteBuffer.allocate(3);

        // 等待客户端的连接
        SocketChannel socketChannel = serverSocketChannel.accept();
        int msgLength = 8;  // 假设从客户端接收八个字节

        // 进行循环读取
        while (true){
            int byteRead = 0;
            while (byteRead<msgLength){
                long l = socketChannel.read(byteBuffers);
                byteRead+=l;  //累计读取的字节数
                System.out.println("byteRead=" + byteRead);

                //使用流打印, 看看当前的这个 buffer 的 position 和 limit
                Arrays.asList(byteBuffers).stream()
                        .map(buffer -> "position=" + buffer.position() + ", limit=" + buffer.limit())
                        .forEach(System.out::println);
            }


            //将所有的 buffer 进行 flip
            Arrays.asList(byteBuffers).forEach(buffer -> buffer.flip());

            //将数据读出显示到客户端
            long byteWirte = 0;
            while (byteWirte < msgLength) {
                long l = socketChannel.write(byteBuffers);
                byteWirte += l;
            }

            //将所有的 buffer 进行 clear
            Arrays.asList(byteBuffers).forEach(buffer-> { buffer.clear(); });

            System.out.println("byteRead:=" + byteRead + " byteWrite=" + byteWirte + ", messagelength" + msgLength);
        }
    }
}

```

### 6、Selector(选择器)

#### ① 基本介绍 

1) Java 的 NIO，用非阻塞的 IO 方式。可以用一个线程，处理多个的客户端连接，就会使用到 Selector(选择器) 

2) Selector 能够检测多个注册的通道上是否有事件发生(注意:多个 Channel 以事件的方式可以注册到同一个 Selector)，如果有事件发生，便获取事件然后针对每个事件进行相应的处理。这样就可以只用一个单线程去管理多个通道，也就是管理多个连接和请求。【示意图】 

3) **只有在 连接/通道 真正有读写事件发生时，才会进行读写，就大大地减少了系统开销，并且不必为每个连接都 创建一个线程，不用去维护多个线程** 

4) 避免了多线程之间的上下文切换导致的开销

#### ② Selector 示意图和特点说明

![image-20210627164312819](https://gitee.com/lgaaip/img/raw/master/image-20210627164312819.png)

1) Netty 的 IO 线程 NioEventLoop 聚合了 Selector(选择器，也叫多路复用器)，可以同时并发处理成百上千个客 户端连接。 

2) 当线程从某客户端 Socket 通道进行读写数据时，若没有数据可用时，该线程可以进行其他任务。 

3) 线程通常将非阻塞 IO 的空闲时间用于在其他通道上执行 IO 操作，所以单独的线程可以管理多个输入和输出 通道。 

4) 由于读写操作都是非阻塞的，这就可以充分提升 IO 线程的运行效率，避免由于频繁 I/O 阻塞导致的线程挂 起。 

5) 一个 I/O 线程可以并发处理 N 个客户端连接和读写操作，这从根本上解决了传统同步阻塞 I/O 一连接一线 程模型，架构的性能、弹性伸缩能力和可靠性都得到了极大的提升。

#### ③ Selector 类相关方法

Selector 类是一个抽象类, 常用方法和说明如下: 

![image-20210627165523027](https://gitee.com/lgaaip/img/raw/master/image-20210627165523027.png)

**注意事项**

1) NIO 中的 ServerSocketChannel 功能类似 ServerSocket，SocketChannel 功能类似 Socket

2) selector 相关方法说明 

​	selector.select()//阻塞 

​	selector.select(1000);//阻塞 1000 毫秒，在 1000 毫秒后返回 

​	selector.wakeup();//唤醒 selector 

​	selector.selectNow();//不阻塞，立马返还



### 7、 NIO 非阻塞 网络编程原理分析图

NIO 非阻塞 网络编程相关的(Selector、SelectionKey、ServerScoketChannel 和 SocketChannel) 关系梳理图

![image-20210627165626743](https://gitee.com/lgaaip/img/raw/master/image-20210627165626743.png)

对上图的说明: 

1) 当客户端连接时，会通过 ServerSocketChannel 得到 SocketChannel 

2) Selector 进行监听 select 方法, 返回有事件发生的通道的个数

3) 将 socketChannel 注册到 Selector 上, register(Selector sel, int ops), 一个 selector 上可以注册多个 SocketChannel 

4) 注册后返回一个 SelectionKey, 会和该 Selector 关联(集合) 

5) 进一步得到各个 SelectionKey (有事件发生) 

6) 在通过 SelectionKey 反向获取 SocketChannel , 方法 channel() 

7) 可以通过 得到的 channel , 完成业务处理 



### 8、 NIO 非阻塞 网络编程快速入门 

案例要求: 

1) 编写一个 NIO 入门案例，实现服务器端和客户端之间的数据简单通讯（非阻塞） 

2) 目的：理解 NIO 非阻塞网络编程机制 

**NIO服务端：**

```java
public class NIOServer {

    public static void main(String[] args) throws Exception{

        // 创建ServerSocketChannel -> ServerSocket
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

        // 得到一个Selector对象
        Selector selector = Selector.open();

        // 绑定一个端口6666，在服务端监听
        serverSocketChannel.socket().bind(new InetSocketAddress(6666));
        // 设置为非阻塞
        serverSocketChannel.configureBlocking(false);

        // 把serverSocketChannel注册到 selector 关心 事件为 OP_ACCEPT
        serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT);

        // 循环等待客户端连接
        while (true){
            // 这里等待1s，如果没有事件发生，返回
            if (selector.select(1000) == 0){
                System.out.println("服务器等待了1s，无连接~");
                continue;
            }

            // 如果返回的大于0,获取到相关的selection集合
            // 1、如果返回大于0，表示已经获取到关注的事件
            // 2、selector.selectedKeys() 返回关注事件的集合
            //   通过selectionKeys反向获取通道
            Set<SelectionKey> selectionKeys = selector.selectedKeys();
            // 使用迭代器遍历 selectionKeys
            Iterator<SelectionKey> keyIterator = selectionKeys.iterator();

            while (keyIterator.hasNext()){
                // 获取到selectionKey
                SelectionKey key = keyIterator.next();
                // 根据key对应的通道发生的事件做不同的处理
                if (key.isAcceptable()){  // 如果是 OP_ACCEPT，有新的客户端连接我
                    // 给该客户端生成一个SocketChannel
                    SocketChannel socketChannel = serverSocketChannel.accept();
                    // socketChannel设置为非阻塞
                    socketChannel.configureBlocking(false);
                    System.out.println("客户端连接成功 生成一个SocketChannel"+socketChannel.hashCode());
                    // 将socketChannel注册到selector,关注事件为 OP_READ
                    // 同时给 socketChannel 关联一个buffer
                    socketChannel.register(selector,SelectionKey.OP_READ, ByteBuffer.allocate(1024));

                }

                if (key.isReadable()){  // 发生读事件
                    // 通过key反向获取到对应的channel
                    SocketChannel channel = (SocketChannel) key.channel();
                    // 获取到该channel关联的buffer
                    ByteBuffer buffer = (ByteBuffer) key.attachment();
                    channel.read(buffer);
                    System.out.println("form 客户端"+new String(buffer.array()));
                }
                // 手动从集合中移除当前的selectionKey，防止重复操作
                keyIterator.remove();
            }
        }
    }
}

```

**NIO客户端**

```java
public class NIOClient {
    public static void main(String[] args) throws Exception{

        // 得到一个网络通道
        SocketChannel socketChannel = SocketChannel.open();
        // 设置非阻塞模式
        socketChannel.configureBlocking(false);
        // 提供服务器端的ip和端口
        InetSocketAddress inetSocketAddress = new InetSocketAddress("127.0.0.1", 6666);

        // 连接服务器
        if (!socketChannel.connect(inetSocketAddress)){
            while (!socketChannel.finishConnect()){
                System.out.println("因为连接需要事件,客户端不会阻塞,可以做其它工作..");
            }
        }

        // 如果连接成功,就发送数据
        String str = "hello,NIO";
        // 不需要指定大小，自动生成成字节数组长度一直的ByteBuffer
        ByteBuffer buffer = ByteBuffer.wrap(str.getBytes());

        // 发送数据，将buffer数据写入channel
        socketChannel.write(buffer);
        System.in.read();

    }
}

```

### 9、几个API

#### ① SelectionKey

1) SelectionKey，表示 **Selector** **和网络通道的注册关系**, 共四种: 

int OP_ACCEPT：有新的网络连接可以 accept，值为 16 

int OP_CONNECT：代表连接已经建立，值为 8 

int OP_READ：代表读操作，值为 1 

int OP_WRITE：代表写操作，值为 4 

源码中： 

```java
public static final int OP_READ = 1 << 0; 
public static final int OP_WRITE = 1 << 2; 
public static final int OP_CONNECT = 1 << 3; 
public static final int OP_ACCEPT = 1 << 4; 
```



2) SelectionKey 相关方法

![image-20210629094538967](https://gitee.com/lgaaip/img/raw/master/image-20210629094538967.png)

#### ② ServerSocketChannel

1) ServerSocketChannel 在服务器端监听新的客户端 Socket 连接 

2) 相关方法如下

![image-20210629094628812](https://gitee.com/lgaaip/img/raw/master/image-20210629094628812.png)

#### ③ SocketChannel

1) SocketChannel，网络 IO 通道，具体负责进行**读写操作**。NIO 把缓冲区的数据写入通道，或者把通道里的数 

据读到缓冲区。

2) 相关方法如下

![image-20210629094702304](https://gitee.com/lgaaip/img/raw/master/image-20210629094702304.png)



### 10、NIO 网络编程应用实例-群聊系统

实例要求: 

1) 编写一个 NIO 群聊系统，实现服务器端和客户端之间的数据简单通讯（非阻塞） 

2) 实现多人群聊 

3) 服务器端：可以监测用户上线，离线，并实现消息转发功能 

4) 客户端：通过 channel 可以无阻塞发送消息给其它所有用户，同时可以接受其它用户发送的消息(有服务器转发 

得到) 

5) 目的：进一步理解 NIO 非阻塞网络编程机制 

![image-20210629094853802](https://gitee.com/lgaaip/img/raw/master/image-20210629094853802.png)

#### Ⅰ、服务端代码

1、定义一些属性

```java
public class GroupChatServer {

    // 定义属性
    private Selector selector;
    private ServerSocketChannel listenChannel;
    private static final int PORT = 6667;
}
```

2、初始化工作，服务端监听6667端口

```java
	// 构造器
    // 初始化工作
    public GroupChatServer() {
        try {
            // 得到选择器
            selector = Selector.open();
            // ServerSocketChannel
            listenChannel = ServerSocketChannel.open();
            // 绑定端口
            listenChannel.socket().bind(new InetSocketAddress(PORT));
            // 设置非阻塞模式
            listenChannel.configureBlocking(false);
            // 将该channel注册到selector
            listenChannel.register(selector, SelectionKey.OP_ACCEPT);

        }catch (Exception e){
            e.printStackTrace();
        }
    }
```

3、监听端口的事件发生

```java
// 监听
    public void listen(){
        try {
            // 循环处理
            while (true){
                int count = selector.select();
                if (count > 0){ // 有事件处理

                    //遍历得到selectionKey集合
                    Iterator<SelectionKey> iterator = selector.selectedKeys().iterator();
                    while (iterator.hasNext()){
                        // 取出selectionKey
                        SelectionKey key = iterator.next();

                        // 监听到accept
                        if (key.isAcceptable()){
                            SocketChannel sc = listenChannel.accept();
                            // 设置非阻塞
                            sc.configureBlocking(false);
                            // 将sc注册到selector
                            sc.register(selector,SelectionKey.OP_READ);
                            // 提示
                            System.out.println(sc.getRemoteAddress()+"上线");
                        }
                        if (key.isReadable()){ // 通道发送读事件,通道可读状态
                            // 处理读
                            readData(key);
                        }

                        // 当前key删除，防止重复处理
                        iterator.remove();
                    }
                }else {
                    System.out.println("wait....");
                }
            }


        }catch (Exception e){
            e.printStackTrace();
        }finally {

        }
    }
```

4、读取客户端的数据

```java
private void readData(SelectionKey key){
        // 定义一个socketChannel
        SocketChannel channel = null;
        try {
            // 得到channel
           channel = (SocketChannel) key.channel();
           // 创建buffer
            ByteBuffer buffer = ByteBuffer.allocate(1024);
            int count = channel.read(buffer);
            // count大于0则读到消息
            if (count > 0){
                // 把缓冲区的数据转成字符串输出
                String msg = new String(buffer.array());
                // 输出该消息
                System.out.println("form 客户端:" +msg);

                // 向其它客户端转发消息(去掉自己)
                sendInfoToOtherClients(msg,channel);
            }
        }catch (IOException e){
            try {
                System.out.println(channel.getRemoteAddress()+"离线了...");
                // 取消注册
                key.cancel();
                //关闭通道
                channel.close();
            }catch (IOException exception){

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```

5、转发消息给其它客户端，排除自己

```java
// 转发消息给其它的客户(通道)
    private void sendInfoToOtherClients(String msg,SocketChannel self) throws Exception{

        System.out.println("服务器转发消息中...");
        // 遍历 所有注册到selector上的SocketChannel,并排除self
        for (SelectionKey key : selector.keys()) {
            // 通过key取到对应的channel
            Channel targetChannel = key.channel();
            // 排除自己
            if (targetChannel instanceof SocketChannel && targetChannel != self){
                // 转型
                SocketChannel dest = (SocketChannel) targetChannel;
                // 将msg存储到buffer
                ByteBuffer buffer = ByteBuffer.wrap(msg.getBytes());
                // 将buffer的数据写入到通道中
                dest.write(buffer);
            }
        }

    }
```



####  Ⅱ、客户端代码:

1、定义相关属性

```java
public class GroupChatClient {

    // 定义相关属性
    private final String HOST = "127.0.0.1"; // 服务器的ip
    private final int PORT = 6667;  // 服务器监听的端口
    private Selector selector;
    private SocketChannel socketChannel;
    private String username; // 自己的信息 
}
```

2、连接到服务器

```java
// 构造器 初始化工作
    public GroupChatClient() throws IOException {
        selector = Selector.open();
        // 连接服务器
        socketChannel = SocketChannel.open(new InetSocketAddress(HOST,PORT));
        // 设置非阻塞
        socketChannel.configureBlocking(false);
        // 将channel 注册到selector
        socketChannel.register(selector, SelectionKey.OP_READ);
        // 得到username
        username = socketChannel.getLocalAddress().toString().substring(1);
        System.out.println(username+" is ok!");
    }
```

3、向服务器发送消息

```java
// 向服务器发送消息
    public void sendInfo(String info){
        info = username+" 说: "+info;

        try {
            socketChannel.write(ByteBuffer.wrap(info.getBytes()));
        }catch (IOException e){
            e.printStackTrace();
        }
    }
```

4、读取从服务端回复的消息

```java
// 读取从服务端回复的
    public void readInfo(){
        try {
            int readChannel = selector.select();
            if (readChannel > 0){ // 有可以用的通道
                Iterator<SelectionKey> iterator = selector.selectedKeys().iterator();
                while (iterator.hasNext()){
                    SelectionKey key = iterator.next();
                    if (key.isReadable()){
                        // 得到相关的通道
                        SocketChannel channel = (SocketChannel) key.channel();
                        // 得到一个buffer
                        ByteBuffer buffer = ByteBuffer.allocate(1024);
                        // 读取
                        channel.read(buffer);
                        // 读到的数据转成字符串
                        String msg = new String(buffer.array());
                        System.out.println(msg.trim());
                    }
                }
                iterator.remove(); // 删除当前selectionKey 防止重复操作
            }else {
                //System.out.println("没有可用的通道...");
            }
        }catch (IOException e){
            e.printStackTrace();
        }
    }
```

#### Ⅲ、启动

**启动服务端**

```java
public static void main(String[] args) {
        // 创建一个服务器对象
        GroupChatServer chatServer = new GroupChatServer();
        chatServer.listen();
    }
```

**启动客户端** 可以启动多个进行测试

```java
public static void main(String[] args) throws Exception{
        // 启动客户端
        GroupChatClient chatClient = new GroupChatClient();
        // 启动一个线程 每隔3s 读取从服务器发送的数据
        new Thread(){
            @Override
            public void run() {
                while (true){
                    chatClient.readInfo();
                    try {
                        Thread.currentThread().sleep(3000);
                    }catch (InterruptedException e){
                        e.printStackTrace();
                    }
                }
            }
        }.start();

        // 发送数据给服务器
        Scanner sc = new Scanner(System.in);
        while (sc.hasNextLine()){
            String s = sc.nextLine();
            chatClient.sendInfo(s);

        }
    }
```

**测试结果展示**

![image-20210629100011666](https://gitee.com/lgaaip/img/raw/master/image-20210629100011666.png)

![image-20210629100047666](https://gitee.com/lgaaip/img/raw/master/image-20210629100047666.png)
