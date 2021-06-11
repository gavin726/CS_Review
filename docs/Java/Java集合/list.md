>[!danger]
>总结了List面试中常问的几个问题~
>会一直更新~


# List

## ArrayList和LinkedList有什么区别？

1. ArrayList的实现是基于数组，LinkedList的实现是基于双向链表；

2. 对于随机访问ArrayList要优于LinkedList，ArrayList可以根据下标以O(1)时间复杂度对元素进行随机访问，而LinkedList的每一个元素都依靠地址指针和它后一个元素连接在一起，查找某个元素的时间复杂度是O(N)； 

3. 对于插入和删除操作，LinkedList要优于ArrayList，因为当元素被添加到LinkedList任意位置的时候，不需要像ArrayList那样重新计算大小或者是更新索引；

4. LinkedList比ArrayList更占内存，因为LinkedList的节点除了存储数据，还存储了两个引用，一个指向前一个元素，一个指向后一个元素。

## 有哪些线程安全的List？

1. `Vector`

   Vector是比较古老的API，虽然保证了线程安全，但是由于效率低一般不建议使用。

2. `Collections.SynchronizedList`

   SynchronizedList是Collections的内部类，Collections提供了synchronizedList方法，可以将一个线程不安全的List包装成线程安全的List，即SynchronizedList。它比Vector有更好的扩展性和兼容性，但是它所有的方法都带有同步锁，也不是性能最优的List。 

3. `CopyOnWriteArrayList`

   CopyOnWriteArrayList是Java 1.5在java.util.concurrent包下增加的类，它采用复制底层数组的方式来实现写操作。当线程对此类集合执行读取操作时，线程将会直接读取集合本身，无须加锁与阻塞。当线程对此类集合执行写入操作时，集合会在底层复制一份新的数组，接下来对新的数组执行写入操作。由于对集合的写入操作都是对数组的副本执行操作，因此它是线程安全的。在所有线程安全的List中，它是性能最优的方案。



## 介绍一下ArrayList的数据结构？

ArrayList的底层是用数组来实现的，默认第一次插入元素时创建大小为10的数组，超出限制时会增加50%的容量，并且数据以 System.arraycopy() 复制到新的数组，因此最好能给出数组大小的预估值。

按数组下标访问元素的性能很高，这是数组的基本优势。直接在数组末尾加入元素的性能也高，但如果按下标插入、删除元素，则要用 System.arraycopy() 来移动部分受影响的元素，性能就变差了，这是基本劣势。

底层源码探究传送门[Java中最简单的集合类——List源码探究](/java/源码分析/list.html)



## 谈谈CopyOnWriteArrayList的原理

CopyOnWriteArrayList是Java并发包里提供的并发类，简单来说它就是一个线程安全且读操作无锁的ArrayList。正如其名字一样，在写操作时会复制一份新的List，在新的List上完成写操作，然后再将原引用指向新的List。这样就保证了写操作的线程安全。

CopyOnWriteArrayList允许线程并发访问读操作，这个时候是没有加锁限制的，性能较高。而写操作的时候，则首先将容器复制一份，然后在新的副本上执行写操作，这个时候写操作是上锁的。结束之后再将原容器的引用指向新容器。注意，在上锁执行写操作的过程中，如果有需要读操作，会作用在原容器上。因此上锁的写操作不会影响到并发访问的读操作。

- 优点：读操作性能很高，因为无需任何同步措施，比较适用于读多写少的并发场景。在遍历传统的List时，若中途有别的线程对其进行修改，则会抛出ConcurrentModificationException异常。而CopyOnWriteArrayList由于其"读写分离"的思想，遍历和修改操作分别作用在不同的List容器，所以在使用迭代器进行遍历时候，也就不会抛出ConcurrentModificationException异常了。

- 缺点：一是内存占用问题，毕竟每次执行写操作都要将原容器拷贝一份，数据量大时，对内存压力较大，可能会引起频繁GC。二是无法保证实时性，Vector对于读写操作均加锁同步，可以保证读和写的强一致性。而CopyOnWriteArrayList由于其实现策略的原因，写和读分别作用在新老不同容器上，在写操作执行过程中，读不会阻塞但读取到的却是老容器的数据。