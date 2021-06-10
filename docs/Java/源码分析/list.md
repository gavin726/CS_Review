# ArrayList和LinkedList的区别

## ArrayList的源码分析

![image-20210113205712032](https://gitee.com/lgaaip/img/raw/master/img/20210117224443.png)

![image-20210113205729463](https://gitee.com/lgaaip/img/raw/master/img/20210117224445.png)

因为 ArrayList 是基于数组实现的，所以支持快速随机访问。RandomAccess 接口标识着该类支持快速随机访问。

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
{
    private static final long serialVersionUID = 8683452581122892189L;
    //默认初始容量大小为10
    private static final int DEFAULT_CAPACITY = 10;
    private static final Object[] EMPTY_ELEMENTDATA = {};
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
    transient Object[] elementData; 
    // 指的是elementData中实际有多少个元素
    private int size;
    
    
// EMPTY_ELEMENTDATA 和 DEFAULTCAPACITY_EMPTY_ELEMENTDATA 简单来说就是用来标记说是从无参的构造函数中初始化数组还是是从有参的构造函数中初始化的
    
```

下面来看一下构造函数

```java
//无参构造函数
public ArrayList() {
    	// DEFAULTCAPACITY_EMPTY_ELEMENTDATA 空数组
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
    }

//有参构造函数，传进去一个初始化容量值
 public ArrayList(int initialCapacity) {
     	// 当传进来的值大于0的时候，则直接开辟一个对应空间大小的数组
        if (initialCapacity > 0) {
            this.elementData = new Object[initialCapacity];
            // 如果等于0，则直接赋值为原来声明好的空数组 EMPTY_ELEMENTDATA
        } else if (initialCapacity == 0) {
            this.elementData = EMPTY_ELEMENTDATA;
        } else {
            throw new IllegalArgumentException("Illegal Capacity: "+
                                               initialCapacity);
        }
    }
```

在上面的构造函数中，我们可以见到，ArrayList并不是在实例化的时候就给你分配了默认容量的数组，那么原来声明的默认初始化容量又在哪里用到呢？

下面我们来看一下add方法

```java
public boolean add(E e) {
    	// 调用另外的方法，然后size（实际元素的数量）每次+1
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        elementData[size++] = e;
        return true;
    }

//这个函数的作用是来确认容量的大小，得到最小的扩容量
private void ensureCapacityInternal(int minCapacity) {
    	//这里我们就可以看到前面两个变量的作用了，假设条件成立，则前面调用的是无参的构造函数
        //证明我们没有自定义容量的大小，所以此时使用默认的容量大小10，DEFAULT_CAPACITY一开始就是10
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
            minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
        }
        ensureExplicitCapacity(minCapacity);
    }

// 判断是否需要扩容
private void ensureExplicitCapacity(int minCapacity) {
    	//记录每次操作的次数，每操作一次就+1，该变量在AbstractList中
        modCount++;

        // 当实际需要装载的元素大于数组的容量的时候，则需要扩容
        if (minCapacity - elementData.length > 0)
            grow(minCapacity);
    }


// 在指定的位置插入元素
public void add(int index, E element) {
        rangeCheckForAdd(index);   // 检查index 的合法性
		// 确认容量的大小，具体分析在上面
        ensureCapacityInternal(size + 1);  
        //  用来在插入元素之后，要将index之后的元素都往后移一位
        System.arraycopy(elementData, index, elementData, index + 1,
                         size - index);
        // 在目标的位置插入元素
        elementData[index] = element;
        // 元素数量增加1
        size++;
    }
```

<font color='red'>扩容</font>

```java
private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

private void grow(int minCapacity) {
        // 先将旧的容量保存起来
        int oldCapacity = elementData.length;
        // 扩容到原来容量的1.5倍
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        // 当扩容后的容量还不足以装载元素时，则直接将元素的数量设置为新的数组的容量
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        // 当算出来的新容量大于MAX_ARRAY_SIZE的时候
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // 将原来数组的元素赋值到一个新开辟的数组，新数组的最大容量为newCapacity
        elementData = Arrays.copyOf(elementData, newCapacity);
    }


private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow 溢出直接报OOM
            throw new OutOfMemoryError();
       // 如果需要装载的元素的数量大小大于 MAX_ARRAY_SIZE 时，则直接将新数组大小赋值为Integer.MAX_VALUE
       // 否则则赋值为原来声明的数组最大值
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
    }
```

下面来看一下remove函数

```java
// 移除指定的元素，返回移除的结果 true or false
public boolean remove(Object o) {
        // 移除null值   从这里知道 ArrayList 允许存放null值
        // 下面都是遍历找到要移除的元素的位置
        if (o == null) {
            for (int index = 0; index < size; index++)
                if (elementData[index] == null) {
                    fastRemove(index);
                    return true;
                }
        } else {
            for (int index = 0; index < size; index++)
                if (o.equals(elementData[index])) {
                    fastRemove(index);
                    return true;
                }
        }
        return false;
    }
 // 私有的方法，移除指定位置的元素，从上面的方法里面遍历找到要移除元素的位置
 private void fastRemove(int index) {
        modCount++;
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work
    }

----------------------------------------------------
// 移除指定位置的元素，并且返回移除的元素
public E remove(int index) {
        rangeCheck(index);   // 检查index的合法性

        modCount++;
        E oldValue = elementData(index); // 直接找到要移除的元素

        int numMoved = size - index - 1;   // 计算要移动的长度
        if (numMoved > 0)
            // 从index+1开始的位置，长度为numMoved，移动到从index开始的位置
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        // 元素数量减少1 然后将原来的最后一个元素的位置置为null
        elementData[--size] = null; // clear to let GC do its work
        // 返回移除的元素
        return oldValue;
    }
------------------------------------
// 移除数组中 数组与c 的交集的元素
public boolean removeAll(Collection<?> c) {
        Objects.requireNonNull(c);
        return batchRemove(c, false);
    }

// 判断传进来的容器是否为空，为空则直接空指针抛异常
public static <T> T requireNonNull(T obj) {
        if (obj == null)
            throw new NullPointerException();
        return obj;
    }

private boolean batchRemove(Collection<?> c, boolean complement) {
        final Object[] elementData = this.elementData;
        int r = 0, w = 0;
        boolean modified = false;
        try {
            for (; r < size; r++)
                if (c.contains(elementData[r]) == complement)
                    elementData[w++] = elementData[r];
        } finally {
            // Preserve behavioral compatibility with AbstractCollection,
            // even if c.contains() throws.
            if (r != size) {
                System.arraycopy(elementData, r,
                                 elementData, w,
                                 size - r);
                w += size - r;
            }
            if (w != size) {
                // clear to let GC do its work
                for (int i = w; i < size; i++)
                    elementData[i] = null;
                modCount += size - w;
                size = w;
                modified = true;
            }
        }
        return modified;
    }

----------------------------------------------------
    // 移除数组中 在c中没有的元素
    public boolean retainAll(Collection<?> c) {
        Objects.requireNonNull(c);
        return batchRemove(c, true);
    }
```

看看clear方法

```java
// 将全部置为null，然后等待垃圾回收
public void clear() {
        modCount++;

        // clear to let GC do its work
        for (int i = 0; i < size; i++)
            elementData[i] = null;

        size = 0;
    }
```

**总结：**

1）arrayList可以存放null。

2）arrayList本质上就是一个elementData数组。

3）arrayList区别于数组的地方在于能够自动扩展大小，其中关键的方法就是gorw()方法。

4）arrayList中removeAll(collection c)和clear()的区别就是removeAll可以删除批量指定的元素，而clear是全是删除集合中的元素。

5）arrayList由于本质是数组，所以它在数据的查询方面会很快，而在插入删除这些方面，性能下降很多，要移动很多数据才能达到应有的效果

6）arrayList实现了RandomAccess，所以在遍历它的时候推荐使用for循环。

-------


## LinkedList的源码分析

先来看一下节点类

```java
private static class Node<E> {
    E item;
    Node<E> next;
    Node<E> prev;

    Node(Node<E> prev, E element, Node<E> next) {
        this.item = element;
        this.next = next;
        this.prev = prev;
    }
}
```

**<font color='cornflowerblue'>构造方法</font>**

```java
public LinkedList() {
    }
// 使用已有的容器构建新链表
public LinkedList(Collection<? extends E> c) {
        this();
        addAll(c);
    }
```

<font color='cornflowerblue'>**add方法**</font>

```java
// 添加到链表的尾部
public boolean add(E e) {
    linkLast(e);
    return true;
}
// 简单的过程
void linkLast(E e) {
        final Node<E> l = last;
        final Node<E> newNode = new Node<>(l, e, null);
        last = newNode;
        if (l == null)   // 如果链表本身最后一个就是空的 那么将新节点作为链表的头节点
            first = newNode;
        else
            l.next = newNode;
        size++;   // 元素个数加1
        modCount++;   // 操作次数
    }

----------------------------------------------------
    // 在指定的位置添加元素
    public void add(int index, E element) {
        checkPositionIndex(index);  // 检查index的合法性

        if (index == size)  // 如果指定的位置刚好是链表最后一个元素的下一个，则直接加到链表的尾部
            linkLast(element);
        else
            linkBefore(element, node(index));  // 不是则调用下面的方法进行插入
    }

void linkBefore(E e, Node<E> succ) {
        // assert succ != null;
        final Node<E> pred = succ.prev;  //获取指定位置的前驱节点A
        final Node<E> newNode = new Node<>(pred, e, succ);  //构造出要插入的新节点，前驱节点为A，后驱节点则为原来在index这个位置的节点
        succ.prev = newNode;   // 原来index处的节点的前驱节点为新插入的节点
        if (pred == null)    
            first = newNode;
        else
            pred.next = newNode;
        size++;
        modCount++;
    }

----------------------------------------------------
    // 将集合插入到链表尾部
    public boolean addAll(Collection<? extends E> c) {
        // 调用下面的方法
        return addAll(size, c);
    }


public boolean addAll(int index, Collection<? extends E> c) {
        checkPositionIndex(index);  // 检查index的合法性

        Object[] a = c.toArray();  // 将集合转化为数组
        int numNew = a.length;   // 数组的长度，即集合中的元素(即要插入的元素的数量)
        if (numNew == 0)    //如果集合中没有元素，则返回false
            return false;
		
    	// 插入位置的前驱节点和后继节点
        Node<E> pred, succ;  
        if (index == size) {  // 如果index==size，证明是要插入到链表的尾部
            succ = null;
            pred = last;      //原来链表的最后一个节点就是插入的节点的前驱节点
        } else {
            // 不是的话则插入的位置在链表的中间
            // 获得index这个位置的节点(要作为新插入节点的后继节点)
            succ = node(index);
            // 获得index这个位置的前驱节点
            pred = succ.prev;
        }

        for (Object o : a) {
            @SuppressWarnings("unchecked") E e = (E) o;
            // 新插入的节点
            Node<E> newNode = new Node<>(pred, e, null);
            // 前驱节点为null，证明插入的位置在链表的首部，则直接将链表的第一个节点置为新插入的节点
            if (pred == null)
                first = newNode;
            else
                pred.next = newNode;  // 否则前驱节点的下一个节点则为新插入的节点
            // 将pred置为了新插入的那个节点
            pred = newNode;
        }
		// 如果后继节点为null 证明插入的位置为链表的尾部，则将last置为新插入的节点
        if (succ == null) {
            last = pred;
        } else {
            //否则不是的话，新插入的节点的下一个节点则为后继节点
            pred.next = succ;
            //后继节点的前一个节点则为新插入的节点
            succ.prev = pred;
        }
		// 链表的元素累加
        size += numNew;
        modCount++;
        return true;
    }
```

上面可以看出addAll方法通常包括下面四个步骤：

1. 检查index范围是否在size之内
2. toArray()方法把集合的数据存到对象数组中
3. 得到插入位置的前驱和后继节点
4. 遍历数据，将数据插入到指定位置

下面我们继续看，addFirst和addLast方法

```java
// 将元素添加到链表的首部
public void addFirst(E e) {
        linkFirst(e);
    }

private void linkFirst(E e) {
        final Node<E> f = first;  // 获取原始链表的头节点
    	// 构造新插入的节点，它的前驱节点为null，后继节点为原始链表的头节点
        final Node<E> newNode = new Node<>(null, e, f);  
        // 新插入的节点为现在链表的首部
        first = newNode;
    	// 如果链表为null，则头尾节点都是新插入的节点
        if (f == null)
            last = newNode;
        // 不然的话，原来的头节点的前驱节点则为新插入的节点
        else
            f.prev = newNode;
        size++;
        modCount++;
    }

----------------------------------------------------
    // 跟add方法一样
    public void addLast(E e) {
        linkLast(e);
    }
```

<font color='cornflowerblue'>**根据位置获取数据的方法**</font>

get方法

```java
// 根据指定的索引获取元素
public E get(int index) {
        checkElementIndex(index);  // 检查index的合法性
        return node(index).item;   // 得到指定位置的元素
    }

// 获取指定位置的节点
Node<E> node(int index) {
        
        // 下面两种判断是因为减少搜索的时间
    	// 从前开始遍历
        if (index < (size >> 1)) {
            Node<E> x = first;
            for (int i = 0; i < index; i++)
                x = x.next;
            return x;
         // 从后往前遍历
        } else {
            Node<E> x = last;
            for (int i = size - 1; i > index; i--)
                x = x.prev;
            return x;
        }
    }
```

四个获取链表第一个节点的方法

```java
// 为null会抛异常
public E getFirst() {
        final Node<E> f = first;
        if (f == null)
            throw new NoSuchElementException();
        return f.item;
    }
public E element() {
        return getFirst();
    }

----------------------------------------------------
// 为null不会抛异常 返回null
public E peek() {
        final Node<E> f = first;
        return (f == null) ? null : f.item;
    }

public E peekFirst() {
        final Node<E> f = first;
        return (f == null) ? null : f.item;
     }
```

获取为尾节点的方法

```java
// 会抛异常
public E getLast() {
        final Node<E> l = last;
        if (l == null)
            throw new NoSuchElementException();
        return l.item;
    }
// 不会抛异常，返回null
public E peekLast() {
        final Node<E> l = last;
        return (l == null) ? null : l.item;
    }
```



**<font color='cornflowerblue'>根据对象得到索引</font>**

```java
// 无非就是从前往后遍历寻找后返回index
public int indexOf(Object o) {
        int index = 0;
        if (o == null) {
            for (Node<E> x = first; x != null; x = x.next) {
                if (x.item == null)
                    return index;
                index++;
            }
        } else {
            for (Node<E> x = first; x != null; x = x.next) {
                if (o.equals(x.item))
                    return index;
                index++;
            }
        }
        return -1;
    }

// 无非就是从后面往前面遍历寻找后返回index
public int lastIndexOf(Object o) {
        int index = size;
        if (o == null) {
            for (Node<E> x = last; x != null; x = x.prev) {
                index--;
                if (x.item == null)
                    return index;
            }
        } else {
            for (Node<E> x = last; x != null; x = x.prev) {
                index--;
                if (o.equals(x.item))
                    return index;
            }
        }
        return -1;
    }
```



<font color='cornflowerblue'>**检查链表是否包含某对象的方法**</font>

```java
// 调用了查找元素的下标值来验证是否包含
public boolean contains(Object o) {
        return indexOf(o) != -1;
    }
```



**<font color='cornflowerblue'>删除方法</font>**

remove() ,removeFirst(),pop(): 删除头节点

```java
public E pop() {
        return removeFirst();
    }
public E remove() {
        return removeFirst();
    }
public E removeFirst() {
        final Node<E> f = first;
        if (f == null)
            throw new NoSuchElementException();
        return unlinkFirst(f);
    }
```

removeLast(),pollLast(): 删除尾节点

```java
public E removeLast() {
        final Node<E> l = last;
        if (l == null)
            throw new NoSuchElementException();
        return unlinkLast(l);
    }
public E pollLast() {
        final Node<E> l = last;
        return (l == null) ? null : unlinkLast(l);
    }
```

**区别：** removeLast()在链表为空时将抛出NoSuchElementException，而pollLast()方法返回null。

remove(Object o): 删除指定元素

```java
public boolean remove(Object o) {
        //如果删除对象为null
        if (o == null) {
            //从头开始遍历
            for (Node<E> x = first; x != null; x = x.next) {
                //找到元素
                if (x.item == null) {
                   //从链表中移除找到的元素
                    unlink(x);
                    return true;
                }
            }
        } else {
            //从头开始遍历
            for (Node<E> x = first; x != null; x = x.next) {
                //找到元素
                if (o.equals(x.item)) {
                    //从链表中移除找到的元素
                    unlink(x);
                    return true;
                }
            }
        }
        return false;
    }
```

当删除指定对象时，只需调用remove(Object o)即可，不过该方法一次只会删除一个匹配的对象，如果删除了匹配对象，返回true，否则false。

unlink(Node x) 方法：

```java
E unlink(Node<E> x) {
        // assert x != null;
        final E element = x.item;
        final Node<E> next = x.next;//得到后继节点
        final Node<E> prev = x.prev;//得到前驱节点

        //删除前驱指针
        if (prev == null) {
            first = next;//如果删除的节点是头节点,令头节点指向该节点的后继节点
        } else {
            prev.next = next;//将前驱节点的后继节点指向后继节点
            x.prev = null;
        }

        //删除后继指针
        if (next == null) {
            last = prev;//如果删除的节点是尾节点,令尾节点指向该节点的前驱节点
        } else {
            next.prev = prev;
            x.next = null;
        }

        x.item = null;
        size--;
        modCount++;
        return element;
    }
```

remove(int index)：删除指定位置的元素

```java
public E remove(int index) {
        //检查index范围
        checkElementIndex(index);
        //将节点删除
        return unlink(node(index));
    }
```

## 区别汇总

### **1、ArrayList 和LinkedList结构不同；**

可以说ArrayList和LinkedList除了是同属于集合类，其他都是不同的，因为他们本身的实现是两种不同的实现方式，<font color='red'>ArrayList 维护的是一个动态数组，LinkedList维护的是一个双向链表，</font>而他们之间的不同是数组与链表的特性比较；

### **2、效率不同**

网上很多说法都比较笼统“ArrayList查询快、LinkedList添加删除快”，经过实践后发现的结论和上面有一点不同；



#### **2.1添加效率**

用ArrayList和LinkedList分别插入1000万数据测试

![image-20210114200454189](https://gitee.com/lgaaip/img/raw/master/img/20210114200502.png)



<font color='red'>很明显普通的插入数据ArrayList要比LinkedList要快很多</font>，可为什么普遍的说法是“LinkedList添加删除快”，这里是有前提条件的linkedList在两种情况下插入数据要比ArrayList快：

##### **（1）往集合中间插入数据时ArrayList比linkedList慢**

ArrayList往集合中间插入数据要做两个事：把之前的数据挪开赋值到新的数组位置，然后把需要插入的数据插入到数组对应位置；

LinkedList只要修改对应位置数据before 和last对象的指向就可以了

##### **（2）ArrayList正好扩容的时候添加数据要比LinkedList慢**

因为ArrayList维护的是一个数组，所以当容量到达阀值时就会进行扩容，然后会重新分配数据的位置，当数组扩容的时候速度也要比LinkedList慢；

#### **2.2删除数据**

AraayList要比LinkedList慢，原理同往集合中间插入数据一样，ArrayList每次删除数据都要对数组重组;

#### **2.3查询数据**

ArrayList比LinkedList快；

原理是：ArrayList是数组有下标标记数据位置的，查询时世界返回对应数组下表数据即可；

LinkedList是链表，没有对数据进行位置标记，每次获取固定位置的数据都需要循环遍历链表如linkedList.get(100)，就需要循环100次找到对应的节点返回。