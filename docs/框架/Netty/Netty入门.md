## 一、Netty 概述

### 1、原生 NIO 存在的问题

1) NIO 的类库和 API 繁杂，使用麻烦：需要熟练掌握 Selector、ServerSocketChannel、SocketChannel、ByteBuffer 等。 

2) 需要具备其他的额外技能：要熟悉 Java 多线程编程，因为 NIO 编程涉及到 Reactor 模式，你必须对多线程 和网络编程非常熟悉，才能编写出高质量的 NIO 程序。 

3) 开发工作量和难度都非常大：例如客户端面临断连重连、网络闪断、半包读写、失败缓存、网络拥塞和异常流 的处理等等。 

4) JDK NIO 的 Bug：例如臭名昭著的 Epoll Bug，它会导致 Selector 空轮询，最终导致 CPU 100%。直到 JDK 1.7 版本该问题仍旧存在，没有被根本解决。 



### 2、Netty 官网说明

![image-20210630091154798](https://gitee.com/lgaaip/img/raw/master/image-20210630091154798.png)

### 3、Netty 的优点

Netty 对 JDK 自带的 NIO 的 API 进行了封装，解决了上述问题。 

1) 设计优雅：适用于各种传输类型的统一 API 阻塞和非阻塞 Socket；基于灵活且可扩展的事件模型，可以清晰 地分离关注点；高度可定制的线程模型 - 单线程，一个或多个线程池. 

2) 使用方便：详细记录的 Javadoc，用户指南和示例；没有其他依赖项，JDK 5（Netty 3.x）或 6（Netty 4.x）就 足够了。 

3) 高性能、吞吐量更高：延迟更低；减少资源消耗；最小化不必要的内存复制。 

4) 安全：完整的 SSL/TLS 和 StartTLS 支持。 

5) 社区活跃、不断更新：社区活跃，版本迭代周期短，发现的 Bug 可以被及时修复，同时，更多的新功能会被 加入 



## 二、Netty 高性能架构设计

### 1、线程模型基本介绍 

1) 目前存在的线程模型有： 

- 传统阻塞 I/O 服务模型 

- Reactor 模式 

2) 根据 Reactor 的数量和处理资源池线程的数量不同，有 3 种典型的实现 

- 单 Reactor 单线程； 

- 单 Reactor 多线程； 

- 主从 Reactor 多线程 

3) Netty 线程模式(Netty 主要基于主从 Reactor 多线程模型做了一定的改进，其中主从 Reactor 多线程模型有多 个 Reactor) 

### 2、传统阻塞 I/O 服务模型 

#### 工作原理图 

1) 黄色的框表示对象， 蓝色的框表示线程 

2) 白色的框表示方法(API) 

#### 模型特点 

1) 采用阻塞 IO 模式获取输入的数据 

2) 每个连接都需要独立的线程完成数据的输入，业务处理, 数据返回

#### 问题分析

1) 当并发数很大，就会创建大量的线程，占用很大系统资源 

2) 连接创建后，如果当前线程暂时没有数据可读，该线程 会阻塞在 read 操作，造成线程资源浪费 

![image-20210704004012513](https://gitee.com/lgaaip/img/raw/master/image-20210704004012513.png)

### 3、Reactor 模式 

#### 针对传统阻塞 I/O 服务模型的 2 个缺点，解决方案：

1) 基于 I/O 复用模型：多个连接共用一个阻塞对象，应用程序只需要在一个阻塞对象等待，无需阻塞等待所有连 接。当某个连接有新的数据可以处理时，操作系统通知应用程序，线程从阻塞状态返回，开始进行业务处理 Reactor 对应的叫法: 1. 反应器模式 2. 分发者模式(Dispatcher) 3. 通知者模式(notifier)

2) 基于线程池复用线程资源：不必再为每个连接创建线程，将连接完成后的业务处理任务分配给线程进行处理， 一个线程可以处理多个连接的业务。

#### I/O 复用结合线程池，就是 Reactor 模式基本设计思想，如图

![image-20210704004314801](https://gitee.com/lgaaip/img/raw/master/image-20210704004314801.png)

1) Reactor 模式，通过一个或多个输入同时传递给服务处理器的模式(基于事件驱动) 

2) 服务器端程序处理传入的多个请求,并将它们同步分派到相应的处理线程， 因此 Reactor 模式也叫 Dispatcher 模式 

3) Reactor 模式使用 IO 复用监听事件, 收到事件后，分发给某个线程(进程), 这点就是网络服务器高并发处理关键

#### **Reactor 模式中 核心组成**

1) Reactor：Reactor 在一个单独的线程中运行，负责监听和分发事件，分发给适当的处理程序来对 IO 事件做出 反应。 它就像公司的电话接线员，它接听来自客户的电话并将线路转移到适当的联系人； 

2) Handlers：处理程序执行 I/O 事件要完成的实际事件，类似于客户想要与之交谈的公司中的实际官员。Reactor 通过调度适当的处理程序来响应 I/O 事件，处理程序执行非阻塞操作。

#### Reactor 模式分类：

根据 Reactor 的数量和处理资源池线程的数量不同，有 3 种典型的实现 

1) 单 Reactor 单线程 

2) 单 Reactor 多线程 

3) 主从 Reactor 多线程

### 4、单 Reactor 单线程

![image-20210704004517331](https://gitee.com/lgaaip/img/raw/master/image-20210704004517331.png)

1) Select 是前面 I/O 复用模型介绍的标准网络编程 API，可以实现应用程序通过一个阻塞对象监听多路连接请求 

2) Reactor 对象通过 Select 监控客户端请求事件，收到事件后通过 Dispatch 进行分发 

3) 如果是建立连接请求事件，则由 Acceptor 通过 Accept 处理连接请求，然后创建一个 Handler 对象处理连接 完成后的后续业务处理 

4) 如果不是建立连接事件，则 Reactor 会分发调用连接对应的 Handler 来响应 

5) Handler 会完成 Read→业务处理→Send 的完整业务流程 

结合实例：服务器端用一个线程通过多路复用搞定所有的 IO 操作（包括连接，读、写等），编码简单，清晰明了， 

但是如果客户端连接数量较多，将无法支撑，前面的 NIO 案例就属于这种模型。

**方案优缺点分析**： 

1) 优点：模型简单，没有多线程、进程通信、竞争的问题，全部都在一个线程中完成 

2) 缺点：性能问题，只有一个线程，无法完全发挥多核 CPU 的性能。Handler 在处理某个连接上的业务时，整 

个进程无法处理其他连接事件，很容易导致性能瓶颈 

3) 缺点：可靠性问题，线程意外终止，或者进入死循环，会导致整个系统通信模块不可用，不能接收和处理外部 

消息，造成节点故障 

4) 使用场景：客户端的数量有限，业务处理非常快速，比如 Redis 在业务处理的时间复杂度 O(1) 的情况

### 5、单 Reactor 多线程

![image-20210704004544687](https://gitee.com/lgaaip/img/raw/master/image-20210704004544687.png)

1) Reactor 对象通过 select 监控客户端请求 事件, 收到事件后，通过 dispatch 进行分发 

2) 如果建立连接请求, 则由 Acceptor 通过 accept 处理连接请求, 然后创建一个 Handler 对象处理完成连接后的各种事件 

3) 如果不是连接请求，则由 reactor 分发调用连接对应的 handler 来处理

4) handler 只负责响应事件，不做具体的业务处理, 通过 read 读取数据后，会分发给后面的 worker 线程池的某个 线程处理业务 

5) worker 线程池会分配独立线程完成真正的业务，并将结果返回给 handler 

6) handler 收到响应后，通过 send 将结果返回给 client

**方案优缺点分析**： 

1) 优点：可以充分的利用多核 cpu 的处理能力 

2) 缺点：多线程数据共享和访问比较复杂， reactor 处理所有的事件的监听和响应，在单线程运行， 在高并发场 景容易出现性能瓶颈.



### 6、主从 Reactor 多线程 

![image-20210704004757080](https://gitee.com/lgaaip/img/raw/master/image-20210704004757080.png)

1) Reactor 主线程 MainReactor 对象通过 select 监听连接事件, 收到事件后，通过 Acceptor 处理连接事件 

2) 当 Acceptor 处理连接事件后，MainReactor 将连接分配给 SubReactor 

3) subreactor 将连接加入到连接队列进行监听,并创建 handler 进行各种事件处理 

4) 当有新事件发生时， subreactor 就会调用对应的 handler 处理 

5) handler 通过 read 读取数据，分发给后面的 worker 线程处理 

6) worker 线程池分配独立的 worker 线程进行业务处理，并返回结果

7) handler 收到响应的结果后，再通过 send 将结果返回给 client 

8) Reactor 主线程可以对应多个 Reactor 子线程, 即 MainRecator 可以关联多个 SubReactor

**方案优缺点说明**： 

1) 优点：父线程与子线程的数据交互简单职责明确，父线程只需要接收新连接，子线程完成后续的业务处理。 

2) 优点：父线程与子线程的数据交互简单，Reactor 主线程只需要把新连接传给子线程，子线程无需返回数据。 

3) 缺点：编程复杂度较高 

4) 结合实例：这种模型在许多项目中广泛使用，包括 Nginx 主从 Reactor 多进程模型，Memcached 主从多线程， Netty 主从多线程模型的支持 

### 7、Reactor 模式小结

 **3种模式用生活案例来理解**

1) 单 Reactor 单线程，前台接待员和服务员是同一个人，全程为顾客服 

2) 单 Reactor 多线程，1 个前台接待员，多个服务员，接待员只负责接待 

3) 主从 Reactor 多线程，多个前台接待员，多个服务生

**Reactor 模式具有如下的优点：** 

1) 响应快，不必为单个同步时间所阻塞，虽然 Reactor 本身依然是同步的 

2) 可以最大程度的避免复杂的多线程及同步问题，并且避免了多线程/进程的切换开销 

3) 扩展性好，可以方便的通过增加 Reactor 实例个数来充分利用 CPU 资源 

4) 复用性好，Reactor 模型本身与具体事件处理逻辑无关，具有很高的复用性 

## 三、Netty 模型

#### 1、工作原理-简单版

Netty 主要基于主从 Reactors 多线程模型（如图）做了一定的改进，其中主从 Reactor 多线程模型有多个 Reactor

![image-20210704005010712](https://gitee.com/lgaaip/img/raw/master/image-20210704005010712.png)

对上图说明 

1) BossGroup 线程维护 Selector , 只关注 Accecpt 

2) 当接收到 Accept 事件，获取到对应的 SocketChannel, 封装成 NIOScoketChannel 并注册到 Worker 线程(事件循 环), 并进行维护 

3) 当 Worker 线程监听到 selector 中通道发生自己感兴趣的事件后，就进行处理(就由 handler)， 注意 handler 已 经加入到通道 

#### 2、工作原理-进阶版

![image-20210704005111325](https://gitee.com/lgaaip/img/raw/master/image-20210704005111325.png)

#### 3、工作原理-详细版

![image-20210704005158179](https://gitee.com/lgaaip/img/raw/master/image-20210704005158179.png)

**对上图的说明小结** 

1) Netty 抽象出两组线程池 BossGroup 专门负责接收客户端的连接, WorkerGroup 专门负责网络的读写 

2) BossGroup 和 WorkerGroup 类型都是 NioEventLoopGroup 

3) NioEventLoopGroup 相当于一个事件循环组, 这个组中含有多个事件循环 ，每一个事件循环是 NioEventLoop 

4) NioEventLoop 表示一个不断循环的执行处理任务的线程， 每个 NioEventLoop 都有一个 selector , 用于监听绑定在其上的 socket 的      	网络通讯 

5) NioEventLoopGroup 可以有多个线程, 即可以含有多个 NioEventLoop 

6) 每个 Boss NioEventLoop 循环执行的步骤有 3 步

- 轮询 accept 事件 

- 处理 accept 事件 , 与 client 建立连接 , 生成 NioScocketChannel , 并将其注册到某个 worker NIOEventLoop 上 的 selector 

- 处理任务队列的任务 ， 即 runAllTasks 

7) 每个 Worker NIOEventLoop 循环执行的步骤 

- 轮询 read, write 事件 

- 处理 i/o 事件， 即 read , write 事件，在对应 NioScocketChannel 处理 

- 处理任务队列的任务 ， 即 runAllTasks 

8) 每个Worker NIOEventLoop 处理业务时，会使用pipeline(管道), pipeline 中包含了 channel , 即通过pipeline 可以获取到对应通道, 管道中维护了很多的 处理器 

#### 4、Netty 快速入门实例-TCP 服务

1) Netty 服务器在 6668 端口监听，客户端能发送消息给服务器 "hello, 服务器~" 

2) 服务器可以回复消息给客户端 "hello, 客户端~" 

3) 目的：对 Netty 线程模型 有一个初步认识, 便于理解 Netty 模型理论



**服务端**：

```java
public class NettyServer {
    public static void main(String[] args) throws Exception{

        // 创建BossGroup 和 WorkerGroup
        // bossGroup 处理连接请求
        // workerGroup 处理客户端的业务
        // 两者都是无线循环
        EventLoopGroup bossGroup = new NioEventLoopGroup();
        EventLoopGroup workerGroup = new NioEventLoopGroup();

        try {


            // 创建服务端的启动对象，配置参数
            ServerBootstrap bootstrap = new ServerBootstrap();

            // 使用链式编程进行设置
            bootstrap.group(bossGroup, workerGroup) // 设置两个线程组
                    .channel(NioServerSocketChannel.class) // 使用NioSocketChannel作为服务器的通过实现
                    .option(ChannelOption.SO_BACKLOG, 128) // 设置连接队列等待的连接个数
                    .childOption(ChannelOption.SO_KEEPALIVE, true) // 设置保持活动连接状态
                    .childHandler(new ChannelInitializer<SocketChannel>() { // 创建一个通道初始化对象
                        // 给pipeline设置处理器
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                            ch.pipeline().addLast(new NettyServerHandler());
                        }
                    }); //给我们的workerGroup的EventLoop对应的管道设置处理器

            System.out.println(".....服务器 is ready....");
            //绑定一个端口并且同步,生成一个ChannelFuture对象
            //启动服务器(并绑定端口)
            ChannelFuture cf = bootstrap.bind(6668).sync();

            //对关闭通道进行监听
            cf.channel().closeFuture().sync();
        }finally {
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
        }
    }
}

```

**服务端处理器:**

```java
public class NettyServerHandler extends ChannelInboundHandlerAdapter {

    // 读取数据(这里我们可以读取客户端发送的消息)
    /*
    1、ChannelHandlerContext ctx 上下文对象,含有管道(pipeline),通道channel,地址
    2、Object msg 就是客户端发送的数据 默认Object
     */
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        System.out.println("ctx = "+ctx);
        // 将msg转成一个ByteBuf
        // ByteBuf是Netty提供的,不是NIO的ByteBuffer
        ByteBuf buf = (ByteBuf) msg;
        System.out.println("客户端发送消息是:"+buf.toString(CharsetUtil.UTF_8));
        System.out.println("客户端地址:"+ctx.channel().remoteAddress());
    }

    // 数据读取完毕
    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
        // write + flush
        // 将数据写入到缓存,并刷新
        // 一般来说,我们对这个发送的数据进行编码
        ctx.writeAndFlush(Unpooled.copiedBuffer("Hello,客户端~",CharsetUtil.UTF_8));
    }

    // 处理异常,一般是需要关闭通道
    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        ctx.close();
    }
}

```



**客户端:**

```java
public class NettyClient {
    public static void main(String[] args) throws InterruptedException {

        //客户端需要一个事件循环组
        EventLoopGroup group = new NioEventLoopGroup();
        try {


            //创建客户端启动对象
            //注意客户端不是ServerBootstrap 而是 Bootstrap
            Bootstrap bootstrap = new Bootstrap();

            //设置相关参数
            bootstrap.group(group)//设置线程组
                    .channel(NioSocketChannel.class)
                    .handler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel ch) throws Exception {
                            ch.pipeline().addLast(new NettyClientHandler()); //加入自己的处理器
                        }
                    });
            System.out.println("客户端Ok");

            // 启动客户端去连接服务器端
            ChannelFuture channelFuture = bootstrap.connect("127.0.0.1", 6668).sync();
            // 给关闭通道进行监听 关闭事件发生后才关闭
            channelFuture.channel().closeFuture().sync();
        }finally {
            group.shutdownGracefully();
        }
    }
}

```

**客户端处理器:**

```java
public class NettyClientHandler extends ChannelInboundHandlerAdapter {

    //当通道就绪就会触发
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        System.out.println("client ctx="+ctx);
        ctx.writeAndFlush(Unpooled.copiedBuffer("hello Server", CharsetUtil.UTF_8));
    }

    //当通道有读取事件时触发
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        ByteBuf buf = (ByteBuf) msg;
        System.out.println("服务器回复的消息:"+buf.toString(CharsetUtil.UTF_8));
        System.out.println("服务器的地址:"+ctx.channel().remoteAddress());
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        ctx.close();
    }
}

```

