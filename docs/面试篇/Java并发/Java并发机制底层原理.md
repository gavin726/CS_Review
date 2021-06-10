# Java并发机制的底层实现原理

## synchronize的实现原理

![image-20210305193200508](https://gitee.com/lgaaip/img/raw/master/20210317201654.png)

从JVM规范中可以看到Synchonized在JVM里的实现原理，JVM基于进入和退出`Monitor`对象来实现方法同步和代码块同步，但两者的实现细节不一样。

代码块同步是使用`monitorenter` 和`monitorexit`指令实现的，而方法同步是使用另外一种方式实现的，细节在JVM规范里并没有 详细说明。但是，方法的同步同样可以使用这两个指令来实现。 

`monitorenter`指令是在编译后插入到同步代码块的开始位置，而`monitorexit`是插入到方法结束处和异常处，JVM要保证每个`monitorenter`必须有对应的`monitorexit`与之配对。任何对象都有 一个`monitor`与之关联，当且一个`monitor`被持有后，它将处于锁定状态。线程执行到`monitorenter` 指令时，将会尝试获取对象所对应的`monitor`的所有权，即尝试获得对象的锁。

> 可见，`synchronized`作用在代码块时，它的底层是**通过monitorenter、monitorexit指令来实现的**。
>
> - `monitorenter：`
>
>   每个对象都是一个监视器锁（monitor），当`monitor`被占用时就会处于锁定状态，线程执行`monitorenter`指令时尝试获取`monitor`的所有权，过程如下：
>
>   如果`monitor`的进入数为0，则该线程进入`monitor`，然后将进入数设置为1，该线程即为`monitor`的所有者。如果线程已经占有该`monitor`，只是重新进入，则进入`monitor`的进入数加1。如果其他线程已经占用了`monitor`，则该线程进入阻塞状态，直到`monitor`的进入数为0，再重新尝试获取`monitor`的所有权。
>
> - `monitorexit：`
>
>   执行`monitorexit`的线程必须是`objectref`所对应的`monitor`持有者。指令执行时，`monitor`的进入数减1，如果减1后进入数为0，那线程退出`monitor`，不再是这个monitor的所有者。其他被这个`monitor`阻塞的线程可以尝试去获取这个`monitor`的所有权。
>
>   `monitorexit`指令出现了两次，第1次为同步正常退出释放锁，第2次为发生异常退出释放锁。

### 锁升级和对比

1. **偏向锁**

   > 为什么引入偏向锁？

   因为HotSpot作者发现，很多情况下，锁并不存在多线程竞争，然后每次都是由一个锁获得，此时如果一直加锁解锁，那么必然造成资源的浪费，所以为了让线程获取锁的代价降低，引入了偏向锁。

   

   当一个线程访问同步代码块去获取锁的时候，会在<font color='red'>对象头</font>和<font color='red'>栈帧</font>中的所记录记录存储锁偏向的线程ID，然后以后要是该线程进入或退出的时候则不需要进行`CAS`操作加锁和解锁，只需要检查一下对象头中的Mark Word里面是否存储着指向当前线程的偏向锁。如果存在，则该线程直接获得锁。如果不存在，则看一下Mark Word中偏向锁的标识是否为1（1表示可偏向）：如果不是的话，则CAS去竞争锁；如果是1的话，则尝试使用CAS将对象头的偏向锁指向当前线程。

   （1）偏向锁的撤销

   ​	偏向锁使用了<font color='orange'>一种等到竞争出现才释放锁</font>的机制，所以当其他线程尝试竞争偏向锁时， 持有偏向锁的线程才会释放锁。偏向锁的撤销，需要等待<font color='red'>全局安全点</font>（在这个时间点上没有正 在执行的字节码）。它会首先暂停拥有偏向锁的线程，然后检查持有偏向锁的线程是否活着， 如果线程不处于活动状态，则将对象头设置成无锁状态；如果线程仍然活着，拥有偏向锁的栈 会被执行，遍历偏向对象的锁记录，栈中的锁记录和对象头的Mark Word要么重新偏向于其他 线程，要么恢复到无锁或者标记对象不适合作为偏向锁，最后唤醒暂停的线程。

   

   （2）关闭偏向锁

   偏向锁在Java 6和Java 7里是默认启用的，但是它在应用程序启动几秒钟之后才激活，如 有必要可以使用JVM参数来关闭延迟：`-XX:BiasedLockingStartupDelay=0`。如果你确定应用程 序里所有的锁通常情况下处于竞争状态，可以通过JVM参数关闭偏向锁：`-XX:- UseBiasedLocking=false`，那么程序默认会进入轻量级锁状态

2. **轻量级锁**

   轻量级锁是指当锁是偏向锁的时候，却被另外的线程所访问，此时偏向锁就会升级为轻量级锁，其他线程会通过自旋的形式尝试获取锁，线程不会阻塞，从而提高性能。

   轻量级锁的获取主要由两种情况：

   1. 当关闭偏向锁功能时；
   2. 由于多个线程竞争偏向锁导致偏向锁升级为轻量级锁。

   一旦有第二个线程加入锁竞争，偏向锁就升级为轻量级锁（自旋锁）。这里要明确一下什么是锁竞争：如果多个线程轮流获取一个锁，但是每次获取锁的时候都很顺利，没有发生阻塞，那么就不存在锁竞争。只有当某线程尝试获取锁的时候，发现该锁已经被占用，只能等待其释放，这才发生了锁竞争。

   在轻量级锁状态下继续锁竞争，没有抢到锁的线程将自旋，即不停地循环判断锁是否能够被成功获取。获取锁的操作，其实就是通过CAS修改对象头里的锁标志位。先比较当前锁标志位是否为“释 放”，如果是则将其设置为“锁定”，比较并设置是原子性发生的。这就算抢到锁了，然后线程将当前锁的持有者信息修改为自己。

   长时间的自旋操作是非常消耗资源的，一个线程持有锁，其他线程就只能在原地空耗CPU，执行不了任何有效的任务，这种现象叫做**忙等**（busy-waiting）。如果多个线程用一个锁，但是没有发生锁竞争，或者发生了很轻微的锁竞争，那么synchronized就用轻量级锁，允许短时间的忙等现象。这是一种折中的想法，短时间的忙等，换取线程在用户态和内核态之间切换的开销。

   （1）轻量级锁加锁

   线程在执行同步块之前，JVM会先在当前线程的栈桢中创建用于存储锁记录的空间，并<font color='red'>将对象头中的Mark Word复制到锁记录中</font>，官方称为Displaced Mark Word。然后线程尝试使用 CAS将对象头中的Mark Word替换为指向锁记录的指针。如果成功，当前线程获得锁，如果失败，表示其他线程竞争锁，当前线程便尝试使用自旋来获取锁。 

   （2）解锁

   轻量级解锁时，会使用原子的CAS操作将Displaced Mark Word替换回到对象头，如果成 功，则表示没有竞争发生。如果失败，表示当前锁存在竞争，锁就会膨胀成重量级锁。

3. **重量级锁**

   重量级锁此忙等是有限度的（有个计数器记录自旋次数，默认允许循环10次，可以通过虚拟机参数更改）。如果锁竞争情况严重，某个达到最大自旋次数的线程，会将轻量级锁升级为重量级锁（依然是CAS修改锁标志位，但不修改持有锁的线程ID）。当后续线程尝试获取锁时，发现被占用的锁是重量级锁，则直接将自己挂起（而不是忙等），等待将来被唤醒。

   重量级锁是指当有一个线程获取锁之后，其余所有等待获取该锁的线程都会处于阻塞状态。简而言之，就是所有的控制权都交给了操作系统，由操作系统来负责线程间的调度和线程的状态变更。而这样会出现频繁地对线程运行状态的切换，线程的挂起和唤醒，从而消耗大量的系统资。

4. **锁的优缺点的比较**

![image-20210317204740719](https://gitee.com/lgaaip/img/raw/master/20210317204742.png)

## 原子操作

原子操作就是不可被中断的一个或一系列操作。

> 处理器如何实现原子操作？

1. 使用总线锁保证原子性

   所谓的总线锁就是使用处理器提供一个LOCK#信号，当一个处理器在总线上面输出此信号的时候，其他处理器的请求将被阻塞住，那么该线程就可以独占共享内存了，其他线程也就无法去更改共享变量内存地址的缓存了。开销比较大

2. 使用缓存锁保证原子性

   所谓“缓存锁定”是指内存区域如果被缓存在处理器的缓存 行中，并且在Lock操作期间被锁定，那么当它执行锁操作回写到内存时，处理器不在总线上声言LOCK＃信号，而是修改内部的内存地址，并允许它的缓存一致性机制来保证操作的原子 性，因为<font color='red'>缓存一致性机制</font>会阻止同时修改由两个以上处理器缓存的内存区域数据，<font color='red'>当其他处理器回写已被锁定的缓存行的数据时，会使缓存行无效。</font>



> Java如何实现原子操作？

1. **使用CAS实现原子操作**

   从Java 1.5开始，JDK的并发包里提供了一些类来支持原子操作，如AtomicBoolean（用原子方式更新的boolean值）、AtomicInteger（用原子方式更新的int值）和AtomicLong（用原子方式更 新的long值）。这些原子包装类还提供了有用的工具方法，比如以原子的方式将当前值自增1和 自减1。

2. **存在的三个问题**

   **1、 ABA问题**

   如果一个变量V初次读取的时候是A值，并且在准备赋值的时候检查到它仍然是A值，那我们就能说明它的值没有被其他线程修改过了吗？很明显是不能的，因为在这段时间它的值可能被改为其他值，然后又改回A，那CAS操作就会误认为它从来没有被修改过。这个问题被称为CAS操作的 **"ABA"问题。**

   部分乐观锁的实现是通过`版本号（version）`的方式来解决 ABA 问题，乐观锁每次在执行数据的修改操作时，都会带上一个版本号，一旦版本号和数据的版本号一致就可以执行修改操作并对版本号执行+1 操作，否则就执行失败。因为每次操作的版本号都会随之增加，所以不会出现 ABA 问题，因为版本号只会增加不会减少。

   JDK 1.5 以后的 `AtomicStampedReference 类`就提供了此种能力，其中的 `compareAndSet 方法`就是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

   **2、循环时间长开销大**

   自旋CAS（也就是不成功就一直循环执行直到成功）如果长时间不成功，会给CPU带来非常大的执行开销。

   **3、只能保证一个共享变量的原子操作**

   CAS 只对单个共享变量有效，当操作涉及跨多个共享变量时 CAS 无效。但是从 JDK 1.5开始，提供了`AtomicReference类`来保证引用对象之间的原子性，你可以把多个变量放在一个对象里来进行 CAS 操作.所以我们可以使用锁或者利用`AtomicReference类`把多个共享变量合并成一个共享变量来操作。

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

   
