# **HashMap问题集锦**



## 存取原理

![img](https://gitee.com/lgaaip/img/raw/master/20210314214334.png)

先介绍几个属性

**size：** key-value键值对的个数

![image-20210314195414910](https://gitee.com/lgaaip/img/raw/master/20210314195415.png)

**threshold：**为阈值，有capactity * load factor计算得来，其中load factor为加载因子

![image-20210314195500698](https://gitee.com/lgaaip/img/raw/master/20210314195502.png)

**load factor：**加载因子，默认为0.75

![image-20210314195708282](https://gitee.com/lgaaip/img/raw/master/20210314195714.png)

> loadFactor表示HashMap的拥挤程度，影响hash操作到同一个数组位置的概率。默认loadFactor等于0.75，当HashMap里面容纳的元素已经达到HashMap数组长度的75%时，表示HashMap太挤了，需要扩容，在HashMap的构造器中可以定制loadFactor。

**capactity：**容量，默认容量为16

![image-20210314195807454](https://gitee.com/lgaaip/img/raw/master/20210314195808.png)

**<font color='red'>JDK1.8的put原理</font>**

`计算key的hash()值`

首先会先调用一个hash方法去计算得到key的hash值

![image-20210314192318601](https://gitee.com/lgaaip/img/raw/master/20210314192332.png)

![image-20210314192331832](https://gitee.com/lgaaip/img/raw/master/20210314192332.png)

`初始化table数组`

初始化table数组的工作放在了第一次put值的时候。此时会先判断table数组是否为空，如果为空的话则会直接调用resize方法进行扩容

![image-20210314192537992](https://gitee.com/lgaaip/img/raw/master/20210314193026.png)

`计算key的索引值`

如果不为空，或者是空然后已经经历了上面的那一步，现在就到了计算key存放的一个索引值了，它是通过（假设数组的长度为n，计算这个所以只的方法则为  (n-1)&hash ，hash为刚开始通过hash()计算得到的）

![image-20210314193001557](https://gitee.com/lgaaip/img/raw/master/20210314193002.png)

`判断索引值的位置是否为空`

此时通过上面计算得到的索引值，在table中找到该位置，当此位置为空的时候则会直接插入，当此位置不为空的时候，会判断当前位置下的key是否跟此时要插入的key，如果相等的话则覆盖掉原来存放的value

![image-20210314194401837](https://gitee.com/lgaaip/img/raw/master/20210314194403.png)

**`当当前位置的key与新插入的不相等的时候`**

会先判断当前节点是树节点还是普通的链表节点。

若为普通链表节点，则会遍历该链表进行节点的插入，当链表的长度大于8的时候则会转换为红黑树并插入节点，否则则插入到链表中，存在即覆盖，不存在即插入。

若节点为树节点，则直接插入节点。

`size是否需要加+1`

size表示的含义是容器中key-value键值对的对数，当新插入键值对的时候则会size+1，当插入键值对的时候只是覆盖了原有键值对的value的时候，则不会+1。

`判断是否需要扩容`

当key-value的对数即将达到阈值时，则会调用resize()方法

![image-20210314195138946](https://gitee.com/lgaaip/img/raw/master/20210314195139.png)



## 线程不安全问题

在JDK1.7中，由于在链表中插入值的时候采用的是头插法，所以在多线程操作HashMap时可能引起死循环，原因是扩容转移后前后链表顺序倒置，在转移过程中修改了原来链表中节点的引用关系。

在JDK1.8中，使用的是尾插法，虽然不会引起上面的问题，但是同样是不安全的，只能保持在一个快照中数据的一致性，当涉及多线程的时候，可能会get到脏数据，所以线程安全还是无法保证。

> 假设A线程计算得到桶的索引值，B线程同时也计算得到桶的索引值，两个索引值恰好相等，此时这个位置是空的，然后A线程时间片用完了，B线程将数据添加进去，但是当A线程"复活"后，并不会发现此时位置已经被占用了，所以会覆盖掉原来B线程put进去的值，于是就造成了数据的不一致性。

## 如何减少hash碰撞？为什么要是2的幂次方？

- 扰动函数可以减少碰撞，原理是如果两个不相等的对象返回不同的hashcode的话，那么碰撞的几率就会小些，这就意味着存链表结构减小，这样取值的话就不会频繁调用equal方法，这样就能提高HashMap的性能。（扰动即Hash方法内部的算法实现，目的是让不同对象返回不同hashcode。）
- 使用不可变的、声明作final的对象，并且采用合适的equals()和hashCode()方法的话，将会减少碰撞的发生。不可变性使得能够缓存不同键的hashcode，这将提高整个获取对象的速度，使用String，Interger这样的wrapper类作为键是非常好的选择。为什么String, Interger这样的wrapper类适合作为键？因为String是final的，而且已经重写了equals()和hashCode()方法了。不可变性是必要的，因为为了要计算hashCode()，就要防止键值改变，如果键值在放入时和获取时返回不同的hashcode的话，那么就不能从HashMap中找到你想要的对象。



看源码我们知道默认设置的容量为16。为什么要设置16呢？原因是为了减少碰撞的几率和数据存储的均匀度。还有是为了位运算提高计算效率。

我们在上面知道，计算索引值是通过数组的长度-1再与上hash值 (n-1)&hash，因为数组的长度规定是2的幂次方，此时减1后的二进制数结尾则全为1，再与hash进行与运算，则得到的索引会是hash的后几位，此时只需要保证hash值的生成的足够散列，则我们得到的索引就足够散列，所以说白了就是减少碰撞的几率，使得存储更加均匀。



> hash的计算规则

将对象的hashcode()方法返回的hash值，进行无符号的右移16位，并与原来的hash值进行按位异或操作，目的是将hash的低16bit和高16bit做了一个异或，使返回的值足够散列

在get和put的过程中，计算下标时，先对hashCode进行hash操作，然后再通过hash值进一步计算下标，如下图所示：

​              ![img](https://gitee.com/lgaaip/img/raw/master/20210314205644.png)



## HashMap扩容

JDK1.7中，如果数组的长度超过了阈值并且当前插入键值对计算得到的索引位置已经有键值对的时候，才会发生扩容。

![image-20210314205358196](https://gitee.com/lgaaip/img/raw/master/20210314205436.png)

JDK1.8中，如果链表长度到达8且数组的长度大于64时，则将链表转为红黑树，如果数组长度小于64，则是进行扩容。

![image-20210314205505466](C:/Users/Alan/AppData/Roaming/Typora/typora-user-images/image-20210314205505466.png)

## HashMap如何解决初始化的容量不是2的幂次方

<font color='red'>JDK1.7</font>

JDK1.7中，是通过两个方法去将传进去不是2的幂次方的容量转换为2的幂次方的容量

![image-20210314211504594](https://gitee.com/lgaaip/img/raw/master/20210314211506.png)

首先通过上面的方法，我们看到注释是获得一个大于等于toSize的2的幂次方的数，即假设传进去5会得到8，

点进这个方法，它又调用了另外的方法

![image-20210314211646098](https://gitee.com/lgaaip/img/raw/master/20210314211647.png)

![image-20210314211701574](C:/Users/Alan/AppData/Roaming/Typora/typora-user-images/image-20210314211701574.png)

![image-20210314212531832](https://gitee.com/lgaaip/img/raw/master/20210314212533.png)

这个方法是计算得到一个小于等于i的2的幂次方的数，即i=5的时候，得到的值是4。

将两个方法结合在一起，当number的值为6的时候，(number - 1) << 1 值为 11

> 0110(6) - 1 =   0101 << 1 = 1010 = 11（十进制）

然后传进去highestOneBit方法，我们知道这个方法计算得到的值会是小于等于11的2的幂次方的数，即为8。

所以最后我们自己传进去一个初始化容量为6的时候，hashMap会帮我们优化为8。



<font color='red'>JDK1.8</font>

在JDK1.8中，HashMap则简化为了一个方法去优化我们自定义的容量

![image-20210314212350236](C:/Users/Alan/AppData/Roaming/Typora/typora-user-images/image-20210314212350236.png)

方法其实跟jdk1.7中的highestOneBit类似，前面部分都一样。我们知道前面的部分其实是将n转为低位全是1的二进制数，此时JDK1.8采取的方法则为直接+1，此时得到的即为2的幂次方的数，比当前值大一点点的2的n次幂的数

## 为要引入红黑树，而不引入二叉搜索数，AVL树

JDK 1.8 以前 HashMap 的实现是 数组+链表，即使哈希函数取得再好，也很难达到元素百分百均匀分布。当 HashMap 中有大量的元素都存放到同一个桶中时，这个桶下有一条长长的链表，这个时候 HashMap 就相当于一个单链表，假如单链表有 n 个元素，遍历的时间复杂度就是 O(n)，完全失去了它的优势。针对这种情况，JDK 1.8 中引入了 红黑树（查找时间复杂度为 O(logN)）来优化这个问题。

> 那为什么不引入二叉搜索树呢？

之所以选择红黑树是为了解决二叉查找树的缺陷，二叉查找树在特殊情况下会变成一条线性结构（这就跟原来使用链表结构一样了，造成很深的问题），遍历查找会非常慢。而红黑树在插入新数据后可能需要通过左旋，右旋、变色这些操作来保持平衡，引入红黑树就是为了查找数据快，解决链表查询深度的问题，我们知道红黑树属于平衡二叉树，但是为了保持“平衡”是需要付出代价的，但是该代价所损耗的资源要比遍历线性链表要少，所以当长度大于8的时候，会使用红黑树，如果链表长度很短的话，根本不需要引入红黑树，引入反而会慢。

> 同样是二叉平衡树，为什么红黑树更好？

红黑树和AVL树都是**最常用的平衡二叉搜索树**，它们的查找、删除、修改都是O(logN) time

AVL树和红黑树有几点比较和区别：
（1）AVL树是更加严格的平衡，因此可以提供更快的查找速度，一般读取查找密集型任务，适用AVL树。
（2）红黑树更适合于插入修改密集型任务。
（3）通常，AVL树的旋转比红黑树的旋转更加难以平衡和调试。

**总结**：
（1）AVL以及红黑树是高度平衡的树数据结构。它们非常相似，真正的区别在于在任何添加/删除操作时完成的旋转操作次数。
（2）两种实现都缩放为a O(log N)，其中N是叶子的数量，但实际上AVL树在查找密集型任务上更快：利用更好的平衡，树遍历平均更短。另一方面，插入和删除方面，AVL树速度较慢：需要更高的旋转次数才能在修改时正确地重新平衡数据结构。
（3）在AVL树中，从根到任何叶子的最短路径和最长路径之间的差异最多为1。在红黑树中，差异可以是2倍。
（4）两个都给O（log n）查找，但平衡AVL树可能需要O（log n）旋转，而红黑树将需要最多两次旋转使其达到平衡（尽管可能需要检查O（log n）节点以确定旋转的位置）。旋转本身是O（1）操作，因为你只是移动指针。

## 说一说红黑树

1. 每个节点非红即黑
2. 根节点总是黑色的
3. 如果节点是红色的，则它的子节点必须是黑色的（反之不一定）
4. 每个叶子节点都是黑色的空节点（NIL节点）
5. 从根节点到叶节点或空子节点的每条路径，必须包含相同数目的黑色节点（即相同的黑色高度）

## HashMap为什么不直接使用hashCode()处理后的哈希值直接作为table的下标？

`hashCode()`方法返回的是int整数类型，其范围为-(2 ^ 31)~(2 ^ 31 - 1)，约有40亿个映射空间，而HashMap的容量范围是在16（初始化默认值）~2 ^ 30，HashMap通常情况下是取不到最大值的，并且设备上也难以提供这么多的存储空间，从而导致通过`hashCode()`计算出的哈希值可能不在数组大小范围内，进而无法匹配存储位置；

**面试官：那怎么解决呢？**

1. HashMap自己实现了自己的`hash()`方法，通过两次扰动使得它自己的哈希值高低位自行进行异或运算，降低哈希碰撞概率也使得数据分布更平均；
2. 在保证数组长度为2的幂次方的时候，使用`hash()`运算之后的值与运算（&）（数组长度 - 1）来获取数组下标的方式进行存储，这样一来是比取余操作更加有效率，二来也是因为只有当数组长度为2的幂次方时，h&(length-1)才等价于h%length，三来解决了“哈希值与数组大小范围不匹配”的问题；



## Java集合的快速失败机制 “fail-fast”？

**是java集合的一种错误检测机制，当多个线程对集合进行结构上的改变的操作时，有可能会产生 fail-fast 机制。**

例如：假设存在两个线程（线程1、线程2），线程1通过Iterator在遍历集合A中的元素，在某个时候线程2修改了集合A的结构（是结构上面的修改，而不是简单的修改集合元素的内容），那么这个时候程序就会抛出 ConcurrentModificationException 异常，从而产生fail-fast机制。

**原因：迭代器在遍历时直接访问集合中的内容，并且在遍历过程中使用一个 modCount 变量。集合在被遍历期间如果内容发生变化，就会改变modCount的值。每当迭代器使用hashNext()/next()遍历下一个元素之前，都会检测modCount变量是否为expectedmodCount值，是的话就返回遍历；否则抛出异常，终止遍历。**

**解决办法：**

**1. 在遍历过程中，所有涉及到改变modCount值得地方全部加上synchronized。**

**2. 使用CopyOnWriteArrayList来替换ArrayList**



## ConcurrentHashMap了解吗？

**<font color='red'>ConcurrentHashMap不同于HashMap，它既不允许key值为null，也不允许value值为null。</font>**

**JDK 1.7中的实现：**

在 jdk 1.7 中，ConcurrentHashMap 是由 Segment 数据结构和 HashEntry 数组结构构成，采取分段锁来保证安全性。Segment 是 ReentrantLock 重入锁，在 ConcurrentHashMap 中扮演锁的角色，HashEntry 则用于存储键值对数据。一个 ConcurrentHashMap 里包含多个 Segment 数组，一个Segment 里包含一个 HashEntry 数组，HashEntry 的结构和 HashMap 类似，是一个数组和链表结构。

> ConcurrentHashMap不会像HashTable一样，对put和gei操作都需要加锁，而是分成了每个段，每当一个线程占用锁访问一个Segment时，不会影响到其他的Segment。

一个concurrentHashMap有多少个segment，最大就能支持多少条线程同时访问，但是前提是访问各不相同的segment。

![JDK1.7下的ConcurrentHashMap](https://gitee.com/lgaaip/img/raw/master/20210317163404.png)

![image-20210317164421285](https://gitee.com/lgaaip/img/raw/master/20210317164636.png)

我们可以看到`HashEntry`中的 hash、key都被声明为`final`这保证了courrentHashMap的不可变性，意味着我们不能从hash链的中间或尾部添加或删除节点，因为这需要修改next引用值，因此所有的节点的修改只能从头部开始。对于put操作，可以一律添加到Hash链的头部。

然后value、next被声明为`volatile`保证了它们的可见性，确保被读线程能够读到最新的值，<font color='red'>这也是ConcurrentHashmap读操作并不需要加锁的一个重要原因</font>。

**put操作**

实际上我们对ConcurrentHashMap的put操作被ConcurrentHashMap委托给特定的段来实现。也就是说，当我们向ConcurrentHashMap中put一个Key/Value对时，首先会获得Key的哈希值并对其再次哈希，然后根据最终的hash值定位到这条记录所应该插入的段；

然后找到对应的段后，put操作首先会尝试获取锁，获取不到就调用`scanAndLockForPut()`进行自旋，当自旋次数达到`MAX_SCAN_RETRIES`则会阻塞等待直到获取锁。



----

**JDK 1.8中的实现：**

JDK1.8 的实现已经摒弃了 Segment 的概念，而是直接用 <font color='red'>Node 数组+链表+红黑树</font>的数据结构来实现，并发控制使用 Synchronized 和 CAS 来操作，整个看起来就像是优化过且线程安全的 HashMap，虽然在 JDK1.8 中还能看到 Segment 的数据结构，但是已经简化了属性，只是为了兼容旧版本。

​                          ![image-20210317170946564](https://gitee.com/lgaaip/img/raw/master/20210317170947.png)

**put操作**

```java
final V putVal(K key, V value, boolean onlyIfAbsent) {
    // key 和 value都不能为空
        if (key == null || value == null) throw new NullPointerException();
    //  计算得到hash
        int hash = spread(key.hashCode());
        int binCount = 0;
    
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            // 如果 table数组桶为空 则调用方法进行初始化（自旋+cas）
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
                // 桶内为空，则新建node然后cas放入，这个操作不加锁，成功了直接break退出
                if (casTabAt(tab, i, null,
                             new Node<K,V>(hash, key, value, null)))
                    break;                   // no lock when adding to empty bin
            }
            else if ((fh = f.hash) == MOVED)
                tab = helpTransfer(tab, f);
            else {
                V oldVal = null;
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key,
                                                              value, null);
                                    break;
                                }
                            }
                        }
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);
        return null;
    }
```

1. 先根据key计算出hashcode
2. 判断是否需要进行初始化。
3. 即为当前 key 定位出的 Node，如果为空表示当前位置可以写入数据，利用 CAS 尝试写入，失败则自旋保证成功。
4. 如果当前位置的 `hashcode == MOVED == -1`,则需要进行扩容。
5. 如果都不满足，则利用 synchronized 锁写入数据。
6. 如果数量大于 `TREEIFY_THRESHOLD` 则要转换为红黑树。



**get操作**

```java
public V get(Object key) {
        Node<K,V>[] tab; Node<K,V> e, p; int n, eh; K ek;
    // 计算放的位置
        int h = spread(key.hashCode());
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (e = tabAt(tab, (n - 1) & h)) != null) {
            // 如果头结点就为目标节点，直接返回值
            if ((eh = e.hash) == h) {
                if ((ek = e.key) == key || (ek != null && key.equals(ek)))
                    return e.val;
            }
            // 如果头结点的hash小于0 则说明此时正在扩容或者是红黑树 调用find进行查找
            else if (eh < 0)
                return (p = e.find(h, key)) != null ? p.val : null;
            // 如果是链表则遍历查找
            while ((e = e.next) != null) {
                if (e.hash == h &&
                    ((ek = e.key) == key || (ek != null && key.equals(ek))))
                    return e.val;
            }
        }
        return null;
    }
```

1. 根据 hash 值计算位置。
2. 查找到指定位置，如果头节点就是要找的，直接返回它的 value.
3. 如果头节点 hash 值小于 0 ，说明正在扩容或者是红黑树，查找之。
4. 如果是链表，遍历查找之。



**总结：**

> Java7 中 ConcruuentHashMap 使用的分段锁，也就是每一个 Segment 上同时只有一个线程可以操作，每一个 Segment 都是一个类似 HashMap 数组的结构，它可以扩容，它的冲突会转化为链表。但是 Segment 的个数一但初始化就不能改变。
>
> Java8 中的 ConcruuentHashMap 使用的 Synchronized 锁加 CAS 的机制。结构也由 Java7 中的 **Segment 数组 + HashEntry 数组 + 链表** 进化成了 **Node 数组 + 链表 / 红黑树**，Node 是类似于一个 HashEntry 的结构。它的冲突再达到一定大小时会转化成红黑树，在冲突小于一定数量时又退回链表。

