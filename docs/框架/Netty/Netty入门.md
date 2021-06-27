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

