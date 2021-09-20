# <font color='#667ee9'>线程基础知识</font>

## 1. 进程和线程的区别

现代操作系统调度的最小单元是线程，也叫轻量级进程，在一个进程里可以创建很多是线程，这些线程都有自己的计数器，堆栈和局部变量等属性，并且能够访问共享的内存变量。

之所以我们感觉不到有很多个线程在切换，是因为处理器的高速切换，使得我们觉得就好像是全部线程在一起执行。

**根本区别：**进程是操作系统资源分配的基本单位，而线程是处理器任务调度和执行的基本单位

**资源开销：**每个进程都有独立的代码和数据空间（程序上下文），程序之间的切换会有较大的开销；线程可以看做轻量级的进程，同一类线程共享代码和数据空间，每个线程都有自己独立的运行栈和程序计数器（PC），线程之间切换的开销小。

**内存分配：**同一进程的线程共享本进程的地址空间和资源，而进程之间的地址空间和资源是相互独立的

**影响关系：**一个进程崩溃后，在保护模式下不会对其他进程产生影响，但是一个线程崩溃整个进程都死掉。所以多进程要比多线程健壮。

**执行过程：**每个独立的进程有程序运行的入口. 顺序执行序列和程序出口。但是线程不能独立执行，必须依存在应用程序中，由应用程序提供多个线程执行控制，两者均可并发执行。

## 2.创建线程的几种方式

### 继承Thread类

通过继承Thread类来创建并启动线程的步骤如下：

​	1. 定义Thread类的子类，并重写该类的run()方法，该run()方法将作为线程执行体。

2. 创建Thread子类的实例，即创建了线程对象。

3. 调用线程对象的start()方法来启动该线程。

```java
public class ExtendsThread {
    public static void main(String[] args) {
        Thread.currentThread().setName("主线程");
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果!");
        //创建一个新线程
        Demo1 demo1 = new Demo1();
        //设置名称
        demo1.setName("demo1");
        //开启线程
        demo1.start();
    }
}


class Demo1 extends Thread{

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果!");
        super.run();
    }
}
```

### 实现Runnable接口

1. 定义Runnable接口的实现类，并实现该接口的run()方法，该run()方法将作为线程执行体。

2. 创建Runnable实现类的实例，并将其作为Thread的target来创建Thread对象，Thread对象为线程对象。

3. 调用线程对象的start()方法来启动该线程。

```java
public class Thread2 {
     
    public static void main(String[] args) {
        Thread.currentThread().setName("主线程");
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
        //创建一个新线程
        Thread thread2 = new Thread(new ThreadDemo2());
        //为线程设置名称
        thread2.setName("线程二");
        //开启线程
        thread2.start();
    }
     
}
 
class ThreadDemo2 implements Runnable {
 
    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
    }
     
}
```

### 实现Callable接口

1. 创建Callable接口的实现类，并实现call()方法，该call()方法将作为线程执行体，且该call()方法有返回值。然后再创建Callable实现类的实例。

2. 使用FutureTask类来包装Callable对象，该FutureTask对象封装了该Callable对象的call()方法的返回值。

3. 使用FutureTask对象作为Thread对象的target创建并启动新线程。

4. 调用FutureTask对象的get()方法来获得子线程执行结束后的返回值。

```java
public class Thread3 {
     
    public static void main(String[] args) throws Exception {
        Thread.currentThread().setName("主线程");
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
        //创建FutureTask的对象

        FutureTask<String> task = new FutureTask<String>((Callable<String>) new ThreadDemo3());
        //创建Thread类的对象
        Thread thread3 = new Thread(task);
        thread3.setName("线程三");
        //开启线程
        thread3.start();
        //获取call()方法的返回值，即线程运行结束后的返回值
        String result = task.get();
        System.out.println(result);
    }
}
 
class ThreadDemo3 implements Callable<String> {
 
    @Override
    public String call() throws Exception {
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
        return Thread.currentThread().getName()+":"+"返回的结果";
    }
}
```

通过继承Thread类、实现Runnable接口、实现Callable接口都可以实现多线程，不过实现Runnable接口与实现Callable接口的方式基本相同，只是Callable接口里定义的方法有返回值，可以声明抛出异常而已。因此可以将实现Runnable接口和实现Callable接口归为一种方式。

采用实现`Runnable、Callable`接口的方式创建多线程的**优缺点**：

- 线程类只是实现了Runnable接口或Callable接口，还可以继承其他类。
- 在这种方式下，多个线程可以共享同一个target对象，所以非常适合多个相同线程来处理同一份资源的情况，从而可以将CPU、代码和数据分开，形成清晰的模型，较好地体现了面向对象的思想。
- 劣势是，编程稍稍复杂，如果需要访问当前线程，则必须使用Thread.currentThread()方法。

采用继承`Thread`类的方式创建多线程的**优缺点**：

- 劣势是，因为线程类已经继承了Thread类，所以不能再继承其他父类。
- 优势是，编写简单，如果需要访问当前线程，则无须使用Thread.currentThread()方法，直接使用this即可获得当前线程。鉴于上面分析，因此一般推荐采用实现Runnable接口、Callable接口的方式来创建多线程。

### 使用线程池创建

   使用线程池创建线程的步骤：

  （1）使用Executors类中的newFixedThreadPool(int num)方法创建一个线程数量为num的线程池

  （2）调用线程池中的execute()方法执行由实现Runnable接口创建的线程；调用submit()方法执行由实现Callable接口创建的线程

  （3）调用线程池中的shutdown()方法关闭线程池

```java
public class Thread4 {
     
    public static void main(String[] args) throws Exception {
         
        Thread.currentThread().setName("主线程");
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
        //通过线程池工厂创建线程数量为2的线程池
        ExecutorService service = Executors.newFixedThreadPool(2);
        //执行线程,execute()适用于实现Runnable接口创建的线程
        service.execute(new ThreadDemo4());
        service.execute(new ThreadDemo6());
        service.execute(new ThreadDemo7());
        //submit()适用于实现Callable接口创建的线程
        Future<String> task = service.submit(new ThreadDemo5());
        //获取call()方法的返回值
        String result = task.get();
        System.out.println(result);
        //关闭线程池
        service.shutdown();
    }
}
//实现Runnable接口
class ThreadDemo4 implements Runnable{
     
    @Override
    public void run() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
    }
     
}
//实现Callable接口
class ThreadDemo5 implements Callable<String> {
 
    @Override
    public String call() throws Exception {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
        return Thread.currentThread().getName()+":"+"返回的结果";
    }
 
}
//实现Runnable接口
class ThreadDemo6 implements Runnable{
     
    @Override
    public void run() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
    }
     
}
//实现Runnable接口
class ThreadDemo7 implements Runnable{
     
    @Override
    public void run() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName()+":"+"输出的结果");
    }
     
}
```

## 3. 为什么要使用多线程？

1. **开销：**线程切换的开销远远低于进程的切换。并且在多核CPU的情况下，意味着可以有多个线程同时执行，这减少了线程的上下文切换所带来的开销。
2. **背景：**多线程并发编程是开发高并发系统的基础。

**从计算机底层来说：**

`单核时代:`  在单核时代多线程主要是为了提高 **CPU** 和 **IO** 设备的综合利用率。举个例子：当只有一个线程的时候会导致 CPU 计算时，IO 设备空闲；进行 IO 操作时，CPU 空闲。我们可以简单地说这两者的利用率目前都是 50%左右。但是当有两个线程的时候就不一样了，当一个线程执行CPU 计算时，另外一个线程可以进行 IO 操作，这样两个的利用率就可以在理想情况下达到 100%了。

`多核时代:` 多核时代多线程主要是为了提高 **CPU** 利用率。举个例子：假如我们要计算一个复杂的任务，我们只用一个线程的话，CPU 只会一个 CPU 核心被利用到，而创建多个线程就可以让多个CPU 核心被利用到，这样就提高了 CPU 的利用率。



## 4. 线程的五种状态

![image-20210919213957322](https://gitee.com/lgaaip/img/raw/master/thread5tai.png)

**Java**线程具有五中基本状态 

**1**）新建状态（**New**）：当线程对象对创建后，即进入了新建状态，如：Thread t = new MyThread();

**2**）就绪状态（**Runnable**）：当调用线程对象的start()方法（t.start();），线程即进入就绪状态。处于就绪状态的线程，只是说明此线程已经做好了准备，随时等待CPU调度执行，并不是说执行了t.start()此线程立即就会执行；

**3**）运行状态（**Running**）：当CPU开始调度处于就绪状态的线程时，此时线程才得以真正执行，即进入到运行状态。注：就绪状态是进入到运行状态的唯一入口，也就是说，线程要想进入运行状态执行，首先必须处于就绪状态中；

**4**）阻塞状态（**Blocked**）：处于运行状态中的线程由于某种原因，暂时放弃对CPU的使用权，停止执行，此时进入阻塞状态，直到其进入到就绪状态，才 有机会再次被CPU调用以进入到运行状态。根据阻塞产生的原因不同，阻塞状态又可以分为三种：

​	1.等待阻塞：运行状态中的线程执行wait()方法，使本线程进入到等待阻塞状态；

​	2.同步阻塞 ：线程在获取synchronized同步锁失败(因为锁被其它线程所占用)，它会进入同步阻塞状态；

​	3.其他阻塞 ： 通过调用线程的sleep()或join()或发出了I/O请求时，线程会进入到阻塞状态。当sleep()状态超时. join()等待线程终止或者		超时. 或者I/O处理完毕时，线程重新转入就绪状态。

**5**）死亡状态（**Dead**）：线程执行完了或者因异常退出了run()方法，该线程结束生命周期。

## 5. 死锁

要记住死锁是多个线程之间抢多份资源造成的。

多个线程同时被阻塞，它们中的一个或者全部都在等待某个资源被释放。由于线程被无限期地阻塞，因此程序不可能正常终止。

![image-20210919215037579](https://gitee.com/lgaaip/img/raw/master/20210919215038.png)

**死锁必须具备以下四个条件：**

互斥条件：该资源任意一个时刻只由一个线程占用。

请求与保持条件：一个进程因请求资源而阻塞时，对已获得的资源保持不放。

不剥夺条件:线程已获得的资源在末使用完之前不能被其他线程强行剥夺，只有自己使用完毕后才释放资源。

循环等待条件:若干进程之间形成一种头尾相接的循环等待资源关系。

### 如何避免线程死锁?

只要破坏产生死锁的四个条件中的其中一个就可以了

**破坏互斥条件**这个条件我们没有办法破坏，因为我们用锁本来就是想让他们互斥的（临界资源需要互斥访问）破坏请求与保持条件一次性申请所有的资源。

**破坏不剥夺条件**占用部分资源的线程进一步申请其他资源时，如果申请不到，可以主动释放它占有的资源。破坏循环等待条件靠按序申请资源来预防。按某一顺序申请资源，释放资源则反序释放。破坏循环等待条件。

**锁排序法：（必须回答出来的点）**指定获取锁的顺序，比如某个线程只有获得A锁和B锁，才能对某资源进行操作，在多线程条件下，如何避免死锁？通过指定锁的获取顺序，比如规定，只有获得A锁的线程才有资格获取B锁，按顺序获取锁就可以避免死锁。这通常被认为是解决死锁很好的一种方法。

**加锁** 使用显式锁中的ReentrantLock.try(long,TimeUnit)来申请锁

## 6. 对比

​	**Runnable VS Callable**

- Callable 接口可以返回结果或抛出检查异常

- Runnable 接口不会返回结果或抛出检查异常，如果任务不需要返回结果或抛出异常推荐使用 Runnable接口，这样代码看起来会更加简洁

- 工具类 Executors 可以实现 Runnable 对象和 Callable 对象之间的相互转换。



​	**shutdown() VS shutdownNow()**

- shutdown（） :关闭线程池，线程池的状态变为 SHUTDOWN。线程池不再接受新任务了，但是队列里的任务得执行完毕。

- shutdownNow（） :关闭线程池，线程的状态变为 STOP。线程池会终止当前正在运行的任务，并停止处理排队的任务并返回正在等待执行的 List。

- shutdownNow的原理是遍历线程池中的工作线程，然后逐个调用线程的interrupt方法来中断线程，所以无法响应中断的任务可能永远无法终止



​	**isTerminated() VS isShutdown()**

- isShutDown 当调用 shutdown() 方法后返回为 true。
- isTerminated 当调用 shutdown() 方法后，并且所有提交的任务完成后返回为 true



​	**synchronized VS ReentrantLock**

1. synchronized是Java关键字，在JVM层面实现加锁和解锁；Lock是一个接口，在代码层面实现加锁和解锁。
2. synchronized可以用在代码块上、方法上；Lock只能写在代码里。
3. synchronized在代码执行完或出现异常时自动释放锁；Lock不会自动释放锁，需要在finally中显示释放锁。
4. synchronized会导致线程拿不到锁一直等待；Lock可以设置获取锁失败的超时时间。
5. synchronized无法得知是否获取锁成功；Lock则可以通过tryLock得知加锁是否成功。
6. synchronized锁可重入、不可中断、非公平；Lock锁可重入、可中断、可公平/不公平，并可以细分读写锁以提高效率。



​	**volatile VS synchronized**

​	synchronized 关键字和 volatile 关键字是两个互补的存在，⽽不是对⽴的存在！

1. **volatile** 关键字是线程同步的轻量级实现，所以 **volatile** 性能肯定⽐ **synchronized** 关键字要好。但是 **volatile** 关键字只能⽤于变量⽽ **synchronized** 关键字可以修饰⽅法以及代码块。
2. **volatile** 关键字能保证数据的可⻅性，但不能保证数据的原⼦性。 **synchronized** 关键字两者都能保证。
3. **volatile** 关键字主要⽤于解决变量在多个线程之间的可⻅性，⽽ **synchronized** 关键字解决的是多个线程之间访问资源的同步性。



## 7.  **sleep()** 和 **wait()** 

- sleep方法：是Thread类的静态方法，当前线程将睡眠n毫秒，线程进入阻塞状态。当睡眠时间到了，会解除阻塞，进入可运行状态，等待CPU的到来。**睡眠不释放锁（如果有的话）**。

- wait方法：是Object的方法，必须与synchronized关键字一起使用，线程进入阻塞状态，当notify或者notifyall被调用后，会解除阻塞。但是，只有重新占用互斥锁之后才会进入可运行状态。**睡眠时，会释放互斥锁**。

- sleep 方法没有释放锁，而 wait 方法释放了锁 。

- sleep 通常被用于暂停执行Wait 通常被用于线程间交互/通信

- sleep() 方法执行完成后，线程会自动苏醒。或者可以使用 wait(long timeout)超时后线程会自动苏醒。wait() 方法被调用后，线程不会自动苏醒，需要别的线程调用同一个对象上的 notify() 或者notifyAll() 方法。



## 8. yield() 方法

Yield方法可以暂停当前正在执行的线程对象，让其它有相同优先级的线程执行。它是一个静态方法而且只保证当前线程放弃CPU占用而不能保证使其它线程一定能占用CPU，执行yield()的线程有可能在进入到暂停状态后马上又被执行。



## 9. 守护线程

守护线程是运行在后台的一种特殊进程。它独立于控制终端并且周期性地执行某种任务或等待处理某些发生的事件。在 Java 中垃圾回收线程就是特殊的守护线程。









# <font color='#667ee9'>线程之间的同步和通信</font>

## 1. Java中如何实现线程同步

1. **同步方法** synchronized

   即有synchronized关键字修饰的方法，由于java的每个对象都有一个内置锁，当用此关键字修饰方法时， 内置锁会保护整个方法。在调用该方法前，需要获得内置锁，否则就处于阻塞状态。需要注意， synchronized关键字也可以修饰静态方法，此时如果调用该静态方法，将会锁住整个类。

2. **同步代码块** synchronized

   即有synchronized关键字修饰的语句块，被该关键字修饰的语句块会自动被加上内置锁，从而实现同步。需值得注意的是，同步是一种高开销的操作，因此应该尽量减少同步的内容。通常没有必要同步整个方法，使用synchronized代码块同步关键代码即可。

3. **ReentrantLock**

   Java 5新增了一个java.util.concurrent包来支持同步，其中ReentrantLock类是可重入、互斥、实现了Lock接口的锁，它与使用synchronized方法和快具有相同的基本行为和语义，并且扩展了其能力。需要注意的是，ReentrantLock还有一个可以创建公平锁的构造方法，但由于能大幅度降低程序运行效率，因此不推荐使用。

4. **volatile**

   volatile关键字为域变量的访问提供了一种免锁机制，使用volatile修饰域相当于告诉虚拟机该域可能会被其他线程更新，因此每次使用该域就要重新计算，而不是使用寄存器中的值。需要注意的是，volatile不会提供任何原子操作，它也不能用来修饰final类型的变量。

5. **原子变量**

   在java的util.concurrent.atomic包中提供了创建了原子类型变量的工具类，使用该类可以简化线程同步。例如AtomicInteger 表可以用原子方式更新int的值，可用在应用程序中（如以原子方式增加的计数器），但不能用于替换Integer。可扩展Number，允许那些处理机遇数字类的工具和实用工具进行统一访问。



## 2. Java多线程之间的通信方式

1. wait()、notify()、notifyAll()

   如果线程之间采用synchronized来保证线程安全，则可以利用wait()、notify()、notifyAll()来实现线程通信。这三个方法是Object类中的方法，并且都被final修饰所以无法被重写。

   调用wait()方法后，会释放锁，使得线程进入阻塞队列，调用notify()后，会使得对应的线程进入就绪队列。

   > 就绪队列存放的是将竞争锁的线程，阻塞队列存放了被阻塞的线程。

   wait的底层，当拥有monitor的所有权的线程执行wait方法时，会将当前线程封装成waiter对象放进到waitset中，然后释放monitor的所有权，最后使用park挂起当前线程。

   notify的底层，如果waitset为空，直接返回，否则则回去waitset中随机拿出一个节点放进entryset中，这个方法不会释放monitor的所有权，得等到monitorexit指令执行才会释放锁，然后entryset中的线程则回去竞争锁。

   

2. await()、signal()、signalAll()

   如果线程之间采用Lock来保证线程安全，则可以利用await()、signal()、signalAll()来实现线程通信。这三个方法都是Condition接口中的方法，该接口是在Java 1.5中出现的，它用来替代传统的wait+notify实现线程间的协作，它的使用依赖于 Lock。

   三个方法对应wait()、notify()、notifyAll()。

3. BlockingQueue

   BlockingQueue具有一个特征：当生产者线程试图向BlockingQueue中放入元素时，如果该队列已满，则该线程被阻塞；当消费者线程试图从BlockingQueue中取出元素时，如果该队列已空，则该线程被阻塞。

   程序的两个线程通过交替向BlockingQueue中放入元素、取出元素，即可很好地控制线程的通信。线程之间需要通信，最经典的场景就是生产者与消费者模型，而BlockingQueue就是针对该模型提供的解决方案。

## 3. volatile

当一个变量被定义成volatile之后，它将具备两项特性：

1. **保证可见性**

   当写一个volatile变量时，JMM会把该线程本地内存中的变量强制刷新到主内存中去，这个写会操作会导致其他线程中的volatile变量缓存无效。

2. **禁止指令重排**

   使用volatile关键字修饰共享变量可以禁止指令重排序，volatile禁止指令重排序有一些规则：

   - 当程序执行到volatile变量的读操作或者写操作时，在其前面的操作的更改肯定全部已经进行，且结果已经对后面的操作可见，在其后面的操作肯定还没有进行；
   - 在进行指令优化时，不能将对volatile变量访问的语句放在其后面执行，也不能把volatile变量后面的语句放到其前面执行。

   即执行到volatile变量时，其前面的所有语句都执行完，后面所有语句都未执行。且前面语句的结果对volatile变量及其后面语句见。

   

**volatile的实现原理：**

volatile可以保证线程可见性且提供了一定的有序性，但是无法保证原子性。在JVM底层volatile是采用“内存屏障”来实现的。观察加入volatile关键字和没有加入volatile关键字时所生成的汇编代码发现，加入volatile关键字时，会多出一个lock前缀指令，lock前缀指令实际上相当于一个内存屏障，内存屏障会提供3个功能：

1. 它确保指令重排序时不会把其后面的指令排到内存屏障之前的位置，也不会把前面的指令排到内存屏障的后面；即在执行到内存屏障这句指令时，在它前面的操作已经全部完成；
2. 它会强制将对缓存的修改操作立即写入主存；
3. 如果是写操作，它会导致其他CPU中对应的缓存行无效。



# <font color='#667ee9'>Java中的锁</font>

## 1. Synchronized

### 使用方法：

- 对于普通同步方法，锁是当前实例对象。
- 对于静态同步方法，锁是当前类的Class对象。
- 对于同步方法块，锁是synchronized括号里配置的对象。

### 底层原理：

① 先以下面代码为例: synchronized修饰同步代码块

```java
public class SynchronizedDemo3 {
    public void method() {
        synchronized (this) {
            System.out.println("SynchronizedDemo3");
        }
    }
}
```

反编译上面编译后的class文件

![image-20210920200449217](https://gitee.com/lgaaip/img/raw/master/20210920201138.png)

可见，`synchronized`作用在代码块时，它的底层是**通过monitorenter、monitorexit指令来实现的**。

- `monitorenter：`

  每个对象都是一个监视器锁（monitor），当`monitor`被占用时就会处于锁定状态，线程执行`monitorenter`指令时尝试获取`monitor`的所有权，过程如下：

  如果`monitor`的进入数为0，则该线程进入`monitor`，然后将进入数设置为1，该线程即为`monitor`的所有者。如果线程已经占有该`monitor`，只是重新进入，则进入`monitor`的进入数加1。如果其他线程已经占用了`monitor`，则该线程进入阻塞状态，直到`monitor`的进入数为0，再重新尝试获取`monitor`的所有权。

- `monitorexit：`

  执行`monitorexit`的线程必须是`objectref`所对应的`monitor`持有者。指令执行时，`monitor`的进入数减1，如果减1后进入数为0，那线程退出`monitor`，不再是这个monitor的所有者。其他被这个`monitor`阻塞的线程可以尝试去获取这个`monitor`的所有权。

  `monitorexit`指令出现了两次，第1次为同步正常退出释放锁，第2次为发生异步退出释放锁。



② 以下列代码为例，说明同步方法的底层实现原理：

```java
public class SynchronizedMethod { 
    public synchronized void method() { 
        System.out.println("Hello World!"); 
    } 
}CopyErrorOK!
```

查看反编译后结果，如下图：

![image-20210305193403819](https://gitee.com/lgaaip/img/raw/master/20210920201608.png)

从反编译的结果来看，方法的同步并没有通过 `monitorenter` 和 `monitorexit` 指令来完成，不过相对于普通方法，其常量池中多了 `ACC_SYNCHRONIZED` 标示符。JVM就是根据该标示符来实现方法的同步的：

当方法调用时，调用指令将会检查方法的 `ACC_SYNCHRONIZED` 访问标志是否被设置，如果设置了，执行线程将先获取`monitor`，获取成功之后才能执行方法体，方法执行完后再释放`monitor`。在方法执行期间，其他任何线程都无法再获得同一个`monitor`对象。

**总结：**

两种同步方式本质上没有区别，只是方法的同步是一种隐式的方式来实现，无需通过字节码来完成。两个指令的执行是`JVM通过调用操作系统的互斥原语mutex来实现`，被阻塞的线程会被挂起、等待重新调度，会导致**“用户态和内核态”**两个态之间来回切换，对性能有较大影响。



### 作用：

1. **原子性：**确保线程互斥的访问同步代码；

2. **可见性：**保证共享变量的修改能够及时可见，其实是通过Java内存模型中的 “对一个变量**unlock**操作之前，必须要同步到主内存中；如果对一个变量进行**lock**操作，则将会清空工作内存中 此变量的值，在执行引擎使用此变量前，需要重新从主内存中**load**操作或**assign**操作初始化 变量值” 来保证的；

3. **有序性：**有效解决重排序问题，即 “一个unlock操作先行发生(happen-before)于后面对同一个锁的lock操作”。



### 锁升级  

> 无锁 -> 偏向锁 -> 轻量级锁 -> 重量级锁

首先当一个线程去修饰同步块并获取锁的时候，此时会在锁对象的对象头和栈帧记录当前线程的id，然后接下来线程再次去请求获取锁的时候，只需要取检测锁对象头中是否有该线程的一个线程ID，如果有的话直接获取，没有的话就去查看当前的偏向锁的标识为是不是1，如果是的话，则采用CAS尝试将对象头的线程ID改成自己的，如果不是的话，则将自己的线程ID放到对象头中去。

当有多个线程进行竞争偏向锁的时候，偏向锁会触发锁的撤销，即会去判断对象头中的markword中的线程id是否还存活，如果不存活则将偏向锁的标识为设置为0，否则则将锁记录设置为00，此时升级为轻量级锁。

此时JVM会在当前线程的栈帧中创建用来存储锁记录的一个空间，然后将对象头中的markword复制到这个空间里面，然后使用CAS尝试将对象头中的markword替换为指向自己的一个指针，如果替换成功就获取到了锁，如果替换失败，则表示当前锁还有其他线程在竞争，此时会进行自旋来获取锁。

当自旋次数超过一定次数的时候（默认10次）此时会升级为重量级锁。



### Mark Word

那么，synchronized 具体是存在对象头哪里呢？答案是：存在锁对象的对象头的Mark Word中，那么MarkWord在对象头中到底长什么样，它到底存储了什么呢？

在64位的虚拟机中：

![image-20210305204140728](https://gitee.com/lgaaip/img/raw/master/20210920205523.png)

在32位的虚拟机中：

![image-20210305204855638](https://gitee.com/lgaaip/img/raw/master/20210920205505.png)



### 为什么要引入偏向锁和轻量级锁

重量级锁底层依赖于系统的同步函数来实现，在 linux 中使用 pthread_mutex_t（互斥锁）来实现。这些底层的同步函数操作会涉及到：操作系统用户态和内核态的切换、进程的上下文切换，而这些操作都是比较耗时的，因此重量级锁操作的开销比较大。而在很多情况下，可能获取锁时只有一个线程，或者是多个线程交替获取锁，在这种情况下，使用重量级锁就不划算了，因此引入了偏向锁和轻量级锁来降低没有并发竞争时的锁开销。



### JVM对synchronized的优化有哪些？

**① 锁膨胀**：无锁 -> 偏向锁 -> 轻量级锁 -> 重量级锁

**② 锁消除**：会进行上下文扫描去除不可能存在竞争的锁

![image-20210920210159987](https://gitee.com/lgaaip/img/raw/master/20210920210201.png)

**③ 锁粗化**：会扩大锁的范围，避免反复加锁解锁带来的开销

![image-20210920210443414](https://gitee.com/lgaaip/img/raw/master/20210920210444.png)

**④ 自旋锁和自适应自旋锁**

**自旋锁**：让线程执行循环等待锁的释放，不让出CPU。如果得到锁，就顺利进入临界区。如果还不能获得锁，那就会将线程在操作系统层面挂起，这就是自旋锁的优化方式。但是它也存在缺点：如果锁被其他线程长时间占用，一直不释放CPU，会带来许多的性能开销。

**自适应自旋锁**：根据上次的自旋次数，设定本次自旋次数。



## 2. Lock

Lock是一个接口，它定义了锁获取和释放的基本操作。

### ReentrantLock

ReetrantLock是一个可重入的独占锁，主要有两个特性，一个是支持公平锁和非公平锁，一个是可重入。

ReetrantLock实现依赖于AQS队列同步器(AbstractQueuedSynchronizer)。

### 公平锁

> lock底层实现
>
> 首先会调用acquire方法，然后调用tryacquire方法进行判断当前资源是否被占用了，如果没被占用则CAS去获取它，如果被占用了则检查是否可重入（比较当前线程和获取资源的那个线程是否一样），如果重复失败则addWaiter加进阻塞的双向队列，接着调用acquireQueued方法，获取节点的前一个节点，如果是head则重新调用tryacquire去进行判断，如果还是失败则会调用shouldParkAfterFailedAcquire判断是否被挂起，调用parkAndCheckInterrupt方法，park当前线程。
>
> unlock实现
>
> 调用release方法，tryRelease方法去释放锁，将计数器-1，减到0则完全释放锁。然后去取消挂起被挂起的线程。线程重新调用tryAcquire方法进行获取锁。

### 非公平锁

> lock底层实现
>
> 跟公平锁不同的是，刚开始lock的时候，非公平锁直接进程CAS看能不能拿到锁，拿不到再调用acquire，后面就一样了。
>
> unlock实现
>
> 调用release方法，tryRelease方法去释放锁，将计数器-1，减到0则完全释放锁。然后去取消挂起被挂起的线程。线程重新调用tryAcquire方法进行获取锁。





## 3. 乐观锁和悲观锁

### 悲观锁

总是假设最坏的情况，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会阻塞直到它拿到锁（**共享资源每次只给一个线程使用，其它线程阻塞，用完后再把资源转让给其它线程**）。传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。Java中`synchronized`和`ReentrantLock`等独占锁就是悲观锁思想的实现。

### 乐观锁

总是假设最好的情况，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用版本号机制和CAS算法实现。**乐观锁适用于多读的应用类型，这样可以提高吞吐量**，像数据库提供的类似于**write_condition机制**，其实都是提供的乐观锁。Java中`java.util.concurrent.atomic`包下面的原子变量类就是使用了乐观锁的一种实现方式**CAS**实现的。

> 乐观锁适用于 读大于写的业务场景； 悲观锁适用于 写大于读的业务场景

### 常见的两种实现方式

> 一般采用 版本号控制机制 或者 CAS算法实现	

#### 1、版本号机制

一般是在数据表中加上一个数据版本号version字段，表示数据被修改的次数，当数据被修改时，version值会加一。当线程A要更新数据值时，在读取数据的同时也会读取version值，在提交更新时，若刚才读取到的version值为当前数据库中的version值相等时才更新，否则重试更新操作，直到更新成功。

**举一个简单的例子：** 假设数据库中帐户信息表中有一个 version 字段，当前值为 1 ；而当前帐户余额字段（ balance ）为 $100 。

1. 操作员 A 此时将其读出（ version=1 ），并从其帐户余额中扣除 $50（ $100-$50 ）。
2. 在操作员 A 操作的过程中，操作员B 也读入此用户信息（ version=1 ），并从其帐户余额中扣除 $20 （ $100-$20 ）。
3. 操作员 A 完成了修改工作，将数据版本号（ version=1 ），连同帐户扣除后余额（ balance=$50 ），提交至数据库更新，此时由于提交数据版本等于数据库记录当前版本，数据被更新，数据库记录 version 更新为 2 。
4. 操作员 B 完成了操作，也将版本号（ version=1 ）试图向数据库提交数据（ balance=$80 ），但此时比对数据库记录版本时发现，操作员 B 提交的数据版本号为 1 ，数据库记录当前版本也为 2 ，不满足 “ 提交版本必须等于当前版本才能执行更新 “ 的乐观锁策略，因此，操作员 B 的提交被驳回。

这样，就避免了操作员 B 用基于 version=1 的旧数据修改的结果覆盖操作员A 的操作结果的可能。



#### <font color='cornflowerblue'>2、CAS算法</font>

即**compare and swap（比较与交换）**，是一种有名的**无锁算法**。无锁编程，即不使用锁的情况下实现多线程之间的变量同步，也就是在没有线程被阻塞的情况下实现变量的同步，所以也叫非阻塞同步（Non-blocking Synchronization）。**CAS算法**涉及到三个操作数

- 需要读写的内存值 V
- 进行比较的值 A
- 拟写入的新值 B

当且仅当 V 的值等于 A时，CAS通过原子方式用新值B来更新V的值，否则不会执行任何操作（比较和替换是一个原子操作）。一般情况下是一个**自旋操作**，即**不断的重试**。

> 什么是自旋锁？简单来说，当锁被其它线程占用它会无线循环等待，一直判断直到被成功获取。

先从一个测试用例开始

```java
public class CASDemo {
    public static void main(String[] args) {
        AtomicInteger atomicInteger = new AtomicInteger(2020);
		//public final boolean compareAndSet(int expect, int update)
        //expect 为期望的值  update为更新的值
        //函数的作用为当这个原子整型变量为2020时，就更改为2021
        System.out.println(atomicInteger.compareAndSet(2020, 2021));
        System.out.println(atomicInteger.get());

        atomicInteger.getAndIncrement(); // 加1
        System.out.println(atomicInteger.compareAndSet(2020, 2021));
        System.out.println(atomicInteger.get());
    }
}

//结果
true
2021
false
2022
```

> 从上面结果我们可以知道，我们创建的一个原子整型变量的值为2020
>
> 第一次`CAS`操作，旧值为2020，更新值为2021，很明显一开始值为2020，所以更新成功返回true
>
> 第二次`CAS`操作，旧值为2022(因为执行了`getAndIncrement`)，此时发现2020 != 2022，所以更新失败返回false

下面看看`getAndIncrement`的底层实现

![image-20210125155333940](https://gitee.com/lgaaip/img/raw/master/20210920224917.png)

![image-20210125155531975](https://gitee.com/lgaaip/img/raw/master/20210920224917.png)

> 上面的 `compareAndSwapInt`函数主要的为了比较当前工作内存中的值和主内存中的值是否相等，如果相等则执行操作，不然则一直自旋。

那么问题来了？一直这么自旋下去真的好吗？

<font color='red'>自旋锁存在的问题：</font>

1、如果某个线程持有锁的时间过长，就导致了其他等待获取的线程一直循环等待，此时会消耗CPU。

2、自旋锁是不公平的，无法满足等待时间最长的线程优先获取锁，即拿到即自旋，会造成“线程饥饿”。

<font color='red'>自旋锁的优点</font>

**自旋锁不会使线程状态发生切换，一直处于用户态，即线程一直都是alive的；不会使线程进入阻塞状态，减少了不必要的上下文切换。**



### 乐观锁的缺点

> ABA是最常见的问题，也是面试热门考点

**1、ABA问题**

如果一个变量V初次读取的时候是A值，并且在准备赋值的时候检查到它仍然是A值，那我们就能说明它的值没有被其他线程修改过了吗？很明显是不能的，因为在这段时间它的值可能被改为其他值，然后又改回A，那CAS操作就会误认为它从来没有被修改过。这个问题被称为CAS操作的 **"ABA"问题。**

部分乐观锁的实现是通过`版本号（version）`的方式来解决 ABA 问题，乐观锁每次在执行数据的修改操作时，都会带上一个版本号，一旦版本号和数据的版本号一致就可以执行修改操作并对版本号执行+1 操作，否则就执行失败。因为每次操作的版本号都会随之增加，所以不会出现 ABA 问题，因为版本号只会增加不会减少。

JDK 1.5 以后的 `AtomicStampedReference 类`就提供了此种能力，其中的 `compareAndSet 方法`就是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

**2、循环时间长开销大**

自旋CAS（也就是不成功就一直循环执行直到成功）如果长时间不成功，会给CPU带来非常大的执行开销。

**3、只能保证一个共享变量的原子操作**

CAS 只对单个共享变量有效，当操作涉及跨多个共享变量时 CAS 无效。但是从 JDK 1.5开始，提供了`AtomicReference类`来保证引用对象之间的原子性，你可以把多个变量放在一个对象里来进行 CAS 操作.所以我们可以使用锁或者利用`AtomicReference类`把多个共享变量合并成一个共享变量来操作。



### 原子引用

Atomic 是指一个操作是不可中断的。即使是在多个线程一起执行的时候，一个操作一旦开始，就不会被其他线程干扰。

所以，所谓原子类说简单点就是具有原子 / 原子操作特征的类。

> 为了解决问题，引入了原子引用

```java
public class AtomicReferenceDemo {
    static AtomicStampedReference<Integer> atomicReference = new AtomicStampedReference<>(1,1);

    public static void main(String[] args) {
        new Thread(()->{
            int stamp = atomicReference.getStamp();
            System.out.println("a1版本号=>"+stamp);

            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            
            atomicReference.compareAndSet(1,2,atomicReference.getStamp(),atomicReference.getStamp()+1);
            System.out.println("a2版本号=>"+atomicReference.getStamp());
            
            atomicReference.compareAndSet(2,1,atomicReference.getStamp(),atomicReference.getStamp()+1);
            System.out.println("a3版本号=>"+atomicReference.getStamp());


        },"a").start();

        new Thread(()->{
            int stamp = atomicReference.getStamp();
            System.out.println("b1版本号=>"+stamp);

            try {
                TimeUnit.SECONDS.sleep(2);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
			// 针对下面的运行结果，
            System.out.println(atomicReference.compareAndSet(1, 6, stamp, stamp + 1));
            System.out.println("b2版本号=>"+atomicReference.getStamp());


        },"b").start();



    }
}
//运行结果
a1版本号=>1
b1版本号=>1
a2版本号=>2
a3版本号=>3
false
b2版本号=>3
```



# <font color='#667ee9'>线程池</font>

## 1. 为什么要用线程池？

使用线程池的好处：

- **降低资源消耗。** 通过重复利用已创建的线程降低线程创建和销毁造成的消耗。

- **提高响应速度。** 当任务到达时，任务可以不需要的等到线程创建就能立即执行。

- **提高线程的可管理性。** 线程是稀缺资源，如果无限制的创建，不仅会消耗系统资源，还会降低系统的稳定性，使用线程池可以进行统一的分配，调优和监控。

## 2. execute()方法和submit()

- execute() 方法用于提交不需要返回值的任务，所以无法判断任务是否被线程池执行成功与否；

- **submit()**方法用于提交需要返回值的任务。线程池会返回一个**future**类型的对象，通过这个**future**对象可以判断任务是否执行成功，并且可以通过future的get()方法来获取返回值，get()方法会阻塞当前线程直到任务完成，而使用 get（long timeout，TimeUnit unit） 方法则会阻塞当前线程一段时间后立即返回，这时候有可能任务没有执行完。



## 3. 参数

```java
public ThreadPoolExecutor(int corePoolSize,  //核心线程大小
                          int maximumPoolSize,  //线程池的最大线程数
                          long keepAliveTime,  //当线程数大于核心线程数时，多余的空闲线程存活的最长时间
                          TimeUnit unit, //时间单位
                          BlockingQueue<Runnable> workQueue,  //任务队列，用来储存等待执行任务的队列
                          ThreadFactory threadFactory,//线程工厂，用来创建线程，一般默认即可
                          RejectedExecutionHandler handler) //拒绝策略，当提交的任务过多而不能及时处理时，我们可以定制策略来处理任务
```

### 四种拒绝策略

defaultHandler ：饱和策略。ThreadPoolExecutor类中一共有4种饱和策略。通过实现**RejectedExecutionHandler**接口。

- AbortPolicy ： 抛出`RejectedExecutionException`异常来拒绝任务。默认饱和策略。

- DiscardPolicy ： 线程任务直接丢弃不报错。

- DiscardOldestPolicy ： 将workQueue队首任务丢弃，将最新线程任务重新加入队列执行。

- CallerRunsPolicy ：由提交任务的线程去执行。

## 4. 线程池的工作原理



![image-20210305214417769](https://gitee.com/lgaaip/img/raw/master/20210920231905.png)

1. 判断核心线程池是否已满，没满则创建一个新的工作线程来执行任务。
2. 判断任务队列是否已满，没满则将新提交的任务添加在工作队列。
3. 判断整个线程池是否已满，没满则创建一个新的工作线程来执行任务，已满则执行饱和（拒绝）策略。



## 5. 常见的线程池

### 1、newCachedThreadPool

创建一个可缓存线程池，如果线程池长度超过处理需要，可灵活回收空闲线程，若无可回收，则新建线程。

这种类型的线程池特点是：

工作线程的创建数量几乎没有限制(其实也有限制的,数目为Interger. MAX_VALUE), 这样可灵活的往线程池中添加线程。

如果长时间没有往线程池中提交任务，即如果工作线程空闲了指定的时间(默认为1分钟)，则该工作线程将自动终止。终止后，如果你又提交了新的任务，则线程池重新创建一个工作线程。在使用CachedThreadPool时，一定要注意控制任务的数量，否则，由于大量线程同时运行，很有会造成系统OOM。 

### 2、newFixedThreadPool

创建一个指定工作线程数量的线程池。每当提交一个任务就创建一个工作线程，如果工作线程数量达到线程池初始的最大数，则将提交的任务存入到池队列中。

FixedThreadPool是一个典型且优秀的线程池，它具有线程池提高程序效率和节省创建线程时所耗的开销的优点。但是，在线程池空闲时，即线程池中没有可运行任务时，它不会释放工作线程，还会占用一定的系统资源。

### 3、newSingleThreadExecutor

创建一个单线程化的Executor，即只创建唯一的工作者线程来执行任务，它只会用唯一的工作线程来执行任务，保证所有任务按照指定顺序(FIFO, LIFO, 优先级)执行。如果这个线程异常结束，会有另一个取代它，保证顺序执行。

**单工作线程最大的特点是可保证顺序地执行各个任务，并且在任意给定的时间不会有多个线程是活动的。**

### 4、newScheduleThreadPool

创建一个定长的线程池，而且支持定时的以及周期性的任务执行，支持定时及周期性任务执行。



## 6. 如何设置线程池

### CPU密集型任务

尽量使用较小的线程池，一般为CPU核心数+1。 因为CPU密集型任务使得CPU使用率很高，若开过多的线程数，会造成CPU过度切换。

### IO密集型任务

可以使用稍大的线程池，一般为2*CPU核心数。 IO密集型任务CPU使用率并不高，因此可以让CPU在等待IO的时候有其他线程去处理别的任务，充分利用CPU时间。

### 混合型任务

可以将任务分成IO密集型和CPU密集型任务，然后分别用不同的线程池去处理。 只要分完之后两个任务的执行时间相差不大，那么就会比串行执行来的高效。因为如果划分之后两个任务执行时间有数据级的差距，那么拆分没有意义。因为先执行完的任务就要等后执行完的任务，最终的时间仍然取决于后执行完的任务，而且还要加上任务拆分与合并的开销，得不偿失。





# <font color='#667ee9'>ThreadLocal</font>

## 1. 简介

通常情况下，我们创建的变量是可以被任何⼀个线程访问并修改的。如果想实现每⼀个线程都有⾃⼰的专属本地变量该如何解决呢？ JDK 中提供的 ThreadLocal 类正是为了解决这样的问题。

**ThreadLocal** 类主要解决的就是让每个线程绑定⾃⼰的值，可以将 **ThreadLocal** 类形象的⽐喻成存放数据的盒⼦，盒⼦中可以存储每个线程的私有数据。

如果你创建了⼀个 **ThreadLocal** 变量，那么访问这个变量的每个线程都会有这个变量的本地副本，这也是 **ThreadLocal** 变量名的由来。他们可以使⽤ **get**和 **set**⽅法来获取默认值或将其值更改为当前线程所存的副本的值，从⽽避免了线程安全问题。

再举个简单的例⼦：

⽐如有两个⼈去宝屋收集宝物，这两个共⽤⼀个袋⼦的话肯定会产⽣争执，但是给他们两个⼈每个⼈分配⼀个袋⼦的话就不会出现这样的问题。如果把这两个⼈⽐作线程的话，那么ThreadLocal 就是⽤来避免这两个线程竞争的。

> 总结：
>
> 1. 线程并发: 在多线程并发的场景下
> 2. 传递数据: 我们可以通过ThreadLocal在同一线程，不同组件中传递公共变量
> 3. 线程隔离: 每个线程的变量都是独立的，不会互相影响

## 2. 基本使用

**`几个常用的方法`**

| 方法声明                  | 描述                       |
| ------------------------- | -------------------------- |
| ThreadLocal()             | 创建ThreadLocal对象        |
| public void set( T value) | 设置当前线程绑定的局部变量 |
| public T get()            | 获取当前线程绑定的局部变量 |
| public void remove()      | 移除当前线程绑定的局部变量 |

**测试**

`先来一个Demo测试一下`

不使用ThreadLocal的情况下

```java
public class Demo01 {
    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public static void main(String[] args) {
        Demo01 demo01 = new Demo01();
        for (int i = 0; i < 10; i++) {
            new Thread(()->{
                demo01.setContent(Thread.currentThread().getName()+"的数据");
                System.out.println("------------------------------");
                System.out.println(Thread.currentThread().getName()+"--->"+demo01.getContent());

            },"线程"+i).start();
        }
    }
}
```

![image-20210126135639091](https://gitee.com/lgaaip/img/raw/master/img/20210126135648.png)

> 我们可以清楚的看到运行结果，取到的数据在并发的情况下是不正确的。

**`那么我们来一个使用ThreadLocal的版本`**

```java
public class Demo02 {
	// 区别
    ThreadLocal<String> t1 = new ThreadLocal<>();
    
    public String getContent() {
        return t1.get();   // 使用get获取
    }

    public void setContent(String content) {
        t1.set(content);  // 将content放进去
    }

    public static void main(String[] args) {
        Demo02 demo01 = new Demo02();
        for (int i = 0; i < 10; i++) {
            new Thread(()->{
                demo01.setContent(Thread.currentThread().getName()+"的数据");
                System.out.println("------------------------------");
                System.out.println(Thread.currentThread().getName()+"--->"+demo01.getContent());

            },"线程"+i).start();
        }
    }
}

```

> 这样不管程序运行多少次，都不会出现获取到错误数据的情况下，这样就<font color='red'>解决了线程之间数据隔离</font>的问题。

## 3. 对比synchronized

**测试**

`我们使用synchronized对当前类加锁`

```java
public class Demo03 {
    private String content;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public static void main(String[] args) {
        Demo03 demo01 = new Demo03();
        for (int i = 0; i < 10; i++) {
            new Thread(()->{
                synchronized (Demo03.class) {
                    demo01.setContent(Thread.currentThread().getName() + "的数据");
                    System.out.println("------------------------------");
                    System.out.println(Thread.currentThread().getName() + "--->" + demo01.getContent());
                }
            },"线程"+i).start();
        }
    }
}
```

> 运行结果也不会出现数据错乱
>
> 但是与ThreadLocal不一样的是，在这里我们是想强调每个线程之间的隔离性，而不是数据的共享性，所以当我们在强调线程隔离性的场景下，synchronized是不适用的。

### 区别

虽然ThreadLocal模式与synchronized关键字都用于处理多线程并发访问变量的问题, 不过<font color='orange'>两者处理问题的角度和思路</font>不同。

|        | synchronized                                                 | ThreadLocal                                                  |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 原理   | 同步机制采用’以时间换空间’的方式, 只提供了一份变量,让不同的线程排队访问 | ThreadLocal采用’以空间换时间’的方式, 为每一个线程都提供了一份变量的副本,从而实现同时访问而相不干扰 |
| 侧重点 | 多个线程之间访问资源的同步                                   | 多线程中让每个线程之间的数据相互隔离                         |

> 总结：
> 在刚刚的案例中，虽然使用ThreadLocal和synchronized都能解决问题,但是使用ThreadLocal更为合适,因为这样可以使程序拥有更高的并发性。

## 4. 运用案例

> 数据库的事务操作中连接对象可能会导致不一致
>
> 为了保证所有的操作在一个事务中,使用的连接必须是同一个: service层开启事务的connection需要跟dao层访问数据库的connection保持一致
>
> <font color='red'>线程并发情况下, 每个线程只能操作各自的 connection</font>

解决方案：

> 常规
>
> - 从service层将connection对象向dao层传递
> - 加锁
> - **`弊端`**
>   - 直接从service层传递connection到dao层, 造成代码耦合度提高
>   - 加锁会造成线程失去并发性，程序性能降低
>
> 使用ThreadLoacl，绑定connection

## 5. ThreadLocal方案的好处

从上述的案例中我们可以看到， 在一些特定场景下，ThreadLocal方案有两个突出的优势：

1. **<font color='cornflowerblue'>传递数据 ：</font>** 保存每个线程绑定的数据，在需要的地方可以直接获取, 避免参数直接传递带来的代码耦合问题
2. **<font color='cornflowerblue'>线程隔离 ：</font>** 各线程之间的数据相互隔离却又具备并发性，避免同步方式带来的性能损失

### ThreadLocal的内部结构

#### 常见的误解

 如果我们不去看源代码的话，可能会猜测`ThreadLocal`是这样子设计的：每个`ThreadLocal`都创建一个`Map`，然后用线程作为`Map`的`key`，要存储的局部变量作为`Map`的`value`，这样就能达到各个线程的局部变量隔离的效果。这是最简单的设计方法，JDK最早期的`ThreadLocal` 确实是这样设计的，但现在早已不是了。
![在这里插入图片描述](https://gitee.com/lgaaip/img/raw/master/img/20210127172920.png)

#### 现在的设计

 但是，JDK后面优化了设计方案，在JDK8中 `ThreadLocal`的设计是：每个`Thread`维护一个`ThreadLocalMap`，这个Map的`key`是`ThreadLocal`实例本身，`value`才是真正要存储的值`Object`。

具体的过程是这样的：

- 每个Thread线程内部都有一个Map (ThreadLocalMap)
- Map里面存储ThreadLocal对象（key）和线程的变量副本（value）
- Thread内部的Map是由ThreadLocal维护的，由ThreadLocal负责向map获取和设置线程的变量值。
- 对于不同的线程，每次获取副本值时，别的线程并不能获取到当前线程的副本值，形成了副本的隔离，互不干扰。
  ![在这里插入图片描述](https://gitee.com/lgaaip/img/raw/master/img/20210127172922.png)

####  这样设计的好处

 这个设计与我们一开始说的设计刚好相反，这样设计有如下两个优势：

- 这样设计之后每个`Map`存储的`Entry`数量就会变少。因为之前的存储数量由`Thread`的数量决定，现在是由`ThreadLocal`的数量决定。在实际运用当中，往往ThreadLocal的数量要少于Thread的数量。
- 当`Thread`销毁之后，对应的`ThreadLocalMap`也会随之销毁，能减少内存的使用。

> 自画理解图

![image-20210127125727846](https://gitee.com/lgaaip/img/raw/master/img/20210127125728.png)

### ThreadLocal的核心方法源码

 基于ThreadLocal的内部结构，我们继续分析它的核心方法源码，更深入的了解其操作原理。

除了构造方法之外， ThreadLocal对外暴露的方法有以下4个：

| 方法声明                   | 描述                         |
| -------------------------- | ---------------------------- |
| protected T initialValue() | 返回当前线程局部变量的初始值 |
| public void set( T value)  | 设置当前线程绑定的局部变量   |
| public T get()             | 获取当前线程绑定的局部变量   |
| public void remove()       | 移除当前线程绑定的局部变量   |

 以下是这4个方法的详细源码分析

#### set方法

**（1 ) 源码和对应的中文注释**

```java
  /**
     * 设置当前线程对应的ThreadLocal的值
     *
     * @param value 将要保存在当前线程对应的ThreadLocal的值
     */
    public void set(T value) {
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取此线程对象中维护的ThreadLocalMap对象
        ThreadLocalMap map = getMap(t);
        // 判断map是否存在
        if (map != null)
            // 存在则调用map.set设置此实体entry
            map.set(this, value);
        else
            // 1）当前线程Thread 不存在ThreadLocalMap对象
            // 2）则调用createMap进行ThreadLocalMap对象的初始化
            // 3）并将 t(当前线程)和value(t对应的值)作为第一个entry存放至ThreadLocalMap中
            createMap(t, value);
    }

 /**
     * 获取当前线程Thread对应维护的ThreadLocalMap 
     * 
     * @param  t the current thread 当前线程
     * @return the map 对应维护的ThreadLocalMap 
     */
    ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }
	/**
     *创建当前线程Thread对应维护的ThreadLocalMap 
     *
     * @param t 当前线程
     * @param firstValue 存放到map中第一个entry的值
     */
	void createMap(Thread t, T firstValue) {
        //这里的this是调用此方法的threadLocal
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

**（2 ) 代码执行流程**

 A. 首先获取当前线程，并根据当前线程获取一个Map

 B. 如果获取的Map不为空，则将参数设置到Map中（当前ThreadLocal的引用作为key）

 C. 如果Map为空，则给该线程创建 Map，并设置初始值

#### get方法

**（1 ) 源码和对应的中文注释**

```java
    /**
     * 返回当前线程中保存ThreadLocal的值
     * 如果当前线程没有此ThreadLocal变量，
     * 则它会通过调用{@link #initialValue} 方法进行初始化值
     *
     * @return 返回当前线程对应此ThreadLocal的值
     */
    public T get() {
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取此线程对象中维护的ThreadLocalMap对象
        ThreadLocalMap map = getMap(t);
        // 如果此map存在
        if (map != null) {
            // 以当前的ThreadLocal 为 key，调用getEntry获取对应的存储实体e
            ThreadLocalMap.Entry e = map.getEntry(this);
            // 对e进行判空 
            if (e != null) {
                @SuppressWarnings("unchecked")
                // 获取存储实体 e 对应的 value值
                // 即为我们想要的当前线程对应此ThreadLocal的值
                T result = (T)e.value;
                return result;
            }
        }
        /*
        	初始化 : 有两种情况有执行当前代码
        	第一种情况: map不存在，表示此线程没有维护的ThreadLocalMap对象
        	第二种情况: map存在, 但是没有与当前ThreadLocal关联的entry
         */
        return setInitialValue();
    }

    /**
     * 初始化
     *
     * @return the initial value 初始化后的值
     */
    private T setInitialValue() {
        // 调用initialValue获取初始化的值
        // 此方法可以被子类重写, 如果不重写默认返回null
        T value = initialValue();
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取此线程对象中维护的ThreadLocalMap对象
        ThreadLocalMap map = getMap(t);
        // 判断map是否存在
        if (map != null)
            // 存在则调用map.set设置此实体entry
            map.set(this, value);
        else
            // 1）当前线程Thread 不存在ThreadLocalMap对象
            // 2）则调用createMap进行ThreadLocalMap对象的初始化
            // 3）并将 t(当前线程)和value(t对应的值)作为第一个entry存放至ThreadLocalMap中
            createMap(t, value);
        // 返回设置的值value
        return value;
    }
```

**（2 ) 代码执行流程**

 A. 首先获取当前线程, 根据当前线程获取一个Map

 B. 如果获取的Map不为空，则在Map中以ThreadLocal的引用作为key来在Map中获取对应的Entry e，否则转到D

 C. 如果e不为null，则返回e.value，否则转到D

 D. Map为空或者e为空，则通过initialValue函数获取初始值value，然后用ThreadLocal的引用和value作为firstKey和firstValue创建一个新的Map

总结: **先获取当前线程的 ThreadLocalMap 变量，如果存在则返回值，不存在则创建并返回初始值。**

#### remove方法

**（1 ) 源码和对应的中文注释**

```java
 /**
     * 删除当前线程中保存的ThreadLocal对应的实体entry
     */
     public void remove() {
        // 获取当前线程对象中维护的ThreadLocalMap对象
         ThreadLocalMap m = getMap(Thread.currentThread());
        // 如果此map存在
         if (m != null)
            // 存在则调用map.remove
            // 以当前ThreadLocal为key删除对应的实体entry
             m.remove(this);
     }
```

**（2 ) 代码执行流程**

 A. 首先获取当前线程，并根据当前线程获取一个Map

 B. 如果获取的Map不为空，则移除当前ThreadLocal对象对应的entry

#### initialValue方法

```java
/**
  * 返回当前线程对应的ThreadLocal的初始值
  
  * 此方法的第一次调用发生在，当线程通过get方法访问此线程的ThreadLocal值时
  * 除非线程先调用了set方法，在这种情况下，initialValue 才不会被这个线程调用。
  * 通常情况下，每个线程最多调用一次这个方法。
  *
  * <p>这个方法仅仅简单的返回null {@code null};
  * 如果程序员想ThreadLocal线程局部变量有一个除null以外的初始值，
  * 必须通过子类继承{@code ThreadLocal} 的方式去重写此方法
  * 通常, 可以通过匿名内部类的方式实现
  *
  * @return 当前ThreadLocal的初始值
  */
protected T initialValue() {
    return null;
}
```

 此方法的作用是 返回该线程局部变量的初始值。

（1） 这个方法是一个延迟调用方法，从上面的代码我们得知，在set方法还未调用而先调用了get方法时才执行，并且仅执行1次。

（2）这个方法缺省实现直接返回一个`null`。

（3）如果想要一个除null之外的初始值，可以重写此方法。（备注： 该方法是一个`protected`的方法，显然是为了让子类覆盖而设计的）

## 6. 弱引用和内存泄漏

 有些程序员在使用ThreadLocal的过程中会发现有内存泄漏的情况发生，就猜测这个内存泄漏跟Entry中使用了弱引用的key有关系。这个理解其实是不对的。

 我们先来回顾这个问题中涉及的几个名词概念，再来分析问题。

**（1） 内存泄漏相关概念**

- Memory overflow:内存溢出，没有足够的内存提供申请者使用。
- Memory leak: 内存泄漏是指程序中已动态分配的堆内存由于某种原因程序未释放或无法释放，造成系统内存的浪费，导致程序运行速度减慢甚至系统崩溃等严重后果。内存泄漏的堆积终将导致内存溢出。

**（2） 弱引用相关概念**

 Java中的引用有4种类型： 强、软、弱、虚。当前这个问题主要涉及到强引用和弱引用：

 **强引用（“Strong” Reference）**，就是我们最常见的普通对象引用，只要还有强引用指向一个对象，就能表明对象还“活着”，垃圾回收器就不会回收这种对象。

 **弱引用（WeakReference）**，垃圾回收器一旦发现了只具有弱引用的对象，不管当前内存空间足够与否，都会回收它的内存。

**（3） 如果key使用强引用**

 假设ThreadLocalMap中的key使用了强引用，那么会出现内存泄漏吗？

 此时ThreadLocal的内存图（实线表示强引用）如下：
![在这里插入图片描述](https://gitee.com/lgaaip/img/raw/master/img/20210127172939.png)
 假设在业务代码中使用完ThreadLocal ，thread Local Ref被回收了。

 但是因为threadLocalMap的Entry强引用了thread Local，造成threadLocal无法被回收。

 在没有手动删除这个Entry以及CurrentThread依然运行的前提下，始终有强引用链 threadRef->currentThread->threadLocalMap->entry，Entry就不会被回收（Entry中包括了ThreadLocal实例和value），导致Entry内存泄漏。

 也就是说，ThreadLocalMap中的key使用了强引用， 是无法完全避免内存泄漏的。

**（5）如果key使用弱引用**

 那么ThreadLocalMap中的key使用了弱引用，会出现内存泄漏吗？

 此时ThreadLocal的内存图（实线表示强引用，虚线表示弱引用）如下：
![在这里插入图片描述](https://gitee.com/lgaaip/img/raw/master/img/20210127172942.png)
​ 同样假设在业务代码中使用完ThreadLocal ，thread Local Ref被回收了。

 由于ThreadLocalMap只持有ThreadLocal的弱引用，没有任何强引用指向threadlocal实例, 所以threadlocal就可以顺利被gc回收，此时Entry中的key=null。

 但是在没有手动删除这个Entry以及CurrentThread依然运行的前提下，**<font color='red'>也存在有强引用链 threadRef->currentThread->threadLocalMap->entry -> value ，value不会被回收</font>**， 而这块value永远不会被访问到了，导致value内存泄漏。

 也就是说，ThreadLocalMap中的key使用了弱引用， 也有可能内存泄漏。

**（6）出现内存泄漏的真实原因**

 比较以上两种情况，我们就会发现，**`内存泄漏的发生跟ThreadLocalMap中的key是否使用弱引用是没有关系的`**。那么内存泄漏的的真正原因是什么呢？

 细心的同学会发现，在以上两种内存泄漏的情况中，都有两个前提：

> 1. 没有手动删除这个Entry
> 2. CurrentThread依然运行

 第一点很好理解，只要在使用完ThreadLocal，调用其remove方法删除对应的Entry，就能避免内存泄漏。

 第二点稍微复杂一点， 由于ThreadLocalMap是Thread的一个属性，被当前线程所引用，所以它的生命周期跟Thread一样长。那么在使用完ThreadLocal之后，如果当前Thread也随之执行结束，ThreadLocalMap自然也会被gc回收，从根源上避免了内存泄漏。

 综上，**ThreadLocal内存泄漏的根源是**：由于ThreadLocalMap的生命周期跟Thread一样长，如果没有手动删除对应key就会导致内存泄漏。

**（7） 为什么使用弱引用**

 根据刚才的分析, 我们知道了： 无论ThreadLocalMap中的key使用哪种类型引用都无法完全避免内存泄漏，跟使用弱引用没有关系。

 要避免内存泄漏有两种方式：

1. 使用完ThreadLocal，调用其remove方法删除对应的Entry
2. 使用完ThreadLocal，当前Thread也随之运行结束

> 相对第一种方式，第二种方式显然更不好控制，特别是使用线程池的时候，线程结束是不会销毁的。

 也就是说，只要记得在使用完ThreadLocal及时的调用remove，无论key是强引用还是弱引用都不会有问题。那么为什么key要用弱引用呢？

 事实上，在ThreadLocalMap中的set/getEntry方法中，会对key为null（也即是ThreadLocal为null）进行判断，如果为null的话，那么是会对value置为null的。

 这就意味着使用完ThreadLocal，CurrentThread依然运行的前提下，就算忘记调用remove方法，**弱引用比强引用可以多一层保障**：弱引用的ThreadLocal会被回收，对应的value在下一次ThreadLocalMap调用set,get,remove中的任一方法的时候会被清除，从而避免内存泄漏。

