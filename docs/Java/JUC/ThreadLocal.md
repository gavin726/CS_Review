# ThreadLocal

## 简介

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

## 基本使用

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

## 对比synchronized

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

## 区别

虽然ThreadLocal模式与synchronized关键字都用于处理多线程并发访问变量的问题, 不过<font color='orange'>两者处理问题的角度和思路</font>不同。

|        | synchronized                                                 | ThreadLocal                                                  |
| ------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 原理   | 同步机制采用’以时间换空间’的方式, 只提供了一份变量,让不同的线程排队访问 | ThreadLocal采用’以空间换时间’的方式, 为每一个线程都提供了一份变量的副本,从而实现同时访问而相不干扰 |
| 侧重点 | 多个线程之间访问资源的同步                                   | 多线程中让每个线程之间的数据相互隔离                         |

> 总结：
> 在刚刚的案例中，虽然使用ThreadLocal和synchronized都能解决问题,但是使用ThreadLocal更为合适,因为这样可以使程序拥有更高的并发性。

## 运用案例

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

## ThreadLocal方案的好处

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

## 弱引用和内存泄漏

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