# Synchronized和ReentrantLock

## 说一说synchronized与Lock的区别

1. synchronized是Java关键字，在JVM层面实现加锁和解锁；Lock是一个接口，在代码层面实现加锁和解锁。

2. synchronized可以用在代码块上、方法上；Lock只能写在代码里。

3. synchronized在代码执行完或出现异常时自动释放锁；Lock不会自动释放锁，需要在finally中显示释放锁。

4. synchronized会导致线程拿不到锁一直等待；Lock可以设置获取锁失败的超时时间。

5. synchronized无法得知是否获取锁成功；Lock则可以通过tryLock得知加锁是否成功。

6. synchronized锁可重入、不可中断、非公平；Lock锁可重入、可中断、可公平/不公平，并可以细分读写锁以提高效率。



## synchronized底层原理实现

**一、以下列代码为例，说明同步代码块的底层实现原理：**

```java
public class SynchronizedDemo { 
    public void method() { 
        synchronized (this) { 
            System.out.println("Method 1 start"); 
        } 
    } 
}
```

查看反编译后结果，如下图：

![image-20210305193200508](https://gitee.com/lgaaip/img/raw/master/20210305193201.png)

可见，`synchronized`作用在代码块时，它的底层是**通过monitorenter、monitorexit指令来实现的**。

- `monitorenter：`

  每个对象都是一个监视器锁（monitor），当`monitor`被占用时就会处于锁定状态，线程执行`monitorenter`指令时尝试获取`monitor`的所有权，过程如下：

  如果`monitor`的进入数为0，则该线程进入`monitor`，然后将进入数设置为1，该线程即为`monitor`的所有者。如果线程已经占有该`monitor`，只是重新进入，则进入`monitor`的进入数加1。如果其他线程已经占用了`monitor`，则该线程进入阻塞状态，直到`monitor`的进入数为0，再重新尝试获取`monitor`的所有权。

- `monitorexit：`

  执行`monitorexit`的线程必须是`objectref`所对应的`monitor`持有者。指令执行时，`monitor`的进入数减1，如果减1后进入数为0，那线程退出`monitor`，不再是这个monitor的所有者。其他被这个`monitor`阻塞的线程可以尝试去获取这个`monitor`的所有权。

  `monitorexit`指令出现了两次，第1次为同步正常退出释放锁，第2次为发生异步退出释放锁。



**二、以下列代码为例，说明同步方法的底层实现原理：**

```java
public class SynchronizedMethod { 
    public synchronized void method() { 
        System.out.println("Hello World!"); 
    } 
}
```



查看反编译后结果，如下图：

![image-20210305193403819](https://gitee.com/lgaaip/img/raw/master/20210305193405.png)

从反编译的结果来看，方法的同步并没有通过 `monitorenter` 和 `monitorexit` 指令来完成，不过相对于普通方法，其常量池中多了 `ACC_SYNCHRONIZED` 标示符。JVM就是根据该标示符来实现方法的同步的：

当方法调用时，调用指令将会检查方法的 `ACC_SYNCHRONIZED` 访问标志是否被设置，如果设置了，执行线程将先获取`monitor`，获取成功之后才能执行方法体，方法执行完后再释放`monitor`。在方法执行期间，其他任何线程都无法再获得同一个`monitor`对象。

**三、总结**

两种同步方式本质上没有区别，只是方法的同步是一种隐式的方式来实现，无需通过字节码来完成。两个指令的执行是`JVM通过调用操作系统的互斥原语mutex来实现`，被阻塞的线程会被挂起、等待重新调度，会导致**“用户态和内核态”**两个态之间来回切换，对性能有较大影响。

## 谈谈ReentrantLock的实现原理

`ReentrantLock` 是基于 `AQS` 实现的， `AQS` 即 `AbstractQueuedSynchronizer` 的缩写，这个是个内部实现了两个队列的抽象类，分别是同步队列和条件队列。其中同步队列是一个双向链表，里面储存的是处于等待状态的线程，正在排队等待唤醒去获取锁，而条件队列是一个单向链表，里面储存的也是处于等待状态的线程，只不过这些线程唤醒的结果是加入到了同步队列的队尾， AQS 所做的就是管理这两个队列里面线程之间的等待状态-唤醒的工作。

在同步队列中，还存在两种模式，分别是独占模式和共享模式，这两种模式的区别就在于 AQS 在唤醒线程节点的时候是不是传递唤醒，这两种模式分别对应独占锁和共享锁。

* **Exclusive（独占）**：只有一个线程能执行，如ReentrantLock。又可分为公平锁和非公平锁。
  * **公平锁**：按照线程在队列中的排队顺序，先到者先拿到锁。
  * **非公平锁**：一来就抢锁，无视队列顺序，抢不到才乖乖排队。
* **Share（共享）**：多个线程可同时执行，如Semaphore、CountDownLatch、CyclicBarrier、ReadWriteLock的Read锁。

`AQS` 是一个抽象类，所以不能直接实例化，当我们需要实现一个自定义锁的时候可以去继承 AQS 然后重写获取锁的方式和释放锁的方式还有管理`state`，而 `ReentrantLock` 就是通过重写了 `AQS` 的 `tryAcquire` 和 `tryRelease` 方法实现的 `lock` 和 `unlock` 。 

`ReentrantLock` 结构如下图所示：

![image-20210305193829131](https://gitee.com/lgaaip/img/raw/master/20210305193830.png)

首先 `ReentrantLock` 实现了 Lock 接口，然后有 3 个内部类，其中 Sync 内部类继承自 AQS ，另外的两个内部类继承自 Sync ，这两个类分别是用来公平锁和非公平锁的。通过 Sync 重写的方法`tryAcquire`、 `tryRelease` 可以知道， `ReentrantLock` 实现的是 AQS 的独占模式，也就是独占锁，这个锁是悲观锁。



## 如果不使用synchronized和Lock，如何保证线程安全？

1. volatile

   volatile关键字为域变量的访问提供了一种免锁机制，使用volatile修饰域相当于告诉虚拟机该域可能会被其他线程更新，因此每次使用该域就要重新计算，而不是使用寄存器中的值。需要注意的是，volatile不会提供任何原子操作，它也不能用来修饰final类型的变量。

2. 原子变量

   在java的util.concurrent.atomic包中提供了创建了原子类型变量的工具类，使用该类可以简化线程同步。例如AtomicInteger 表可以用原子方式更新int的值，可用在应用程序中（如以原子方式增加的计数器），但不能用于替换Integer。可扩展Number，允许那些处理机遇数字类的工具和实用工具进行统一访问。

3. 本地存储

   可以通过ThreadLocal类来实现线程本地存储的功能。每一个线程的Thread对象中都有一个ThreadLocalMap对象，这个对象存储了一组以ThreadLocal.threadLocalHashCode为键，以本地线程变量为值的K-V值对，ThreadLocal对象就是当前线程的ThreadLocalMap的访问入口，每

   一个ThreadLocal对象都包含了一个独一无二的threadLocalHashCode值，使用这个值就可以在线程K-V值对中找回对应的本地线程变量。

4. 不可变的

   只要一个不可变的对象被正确地构建出来，那其外部的可见状态永远都不会改变，永远都不会看到它在多个线程之中处于不一致的状态，“不可变”带来的安全性是最直接、最纯粹的。Java语言中，如果多线程共享的数据是一个基本数据类型，那么只要在定义时使用final关键字修饰它就可以保证它是不可变的。如果共享数据是一个对象，由于Java语言目前暂时还没有提供值类型的支持，那就需要对象自行保证其行为不会对其状态产生任何影响才行。String类是一个典型的不可变类，可以参考它设计一个不可变类。

