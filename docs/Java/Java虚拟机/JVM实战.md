## OOM实战

### Java堆溢出

Java堆用于存储对象实例，所以我们需要不断创建对象，保证GC Roots到对象之间都是可达的，避免被回收，那么随着对象的增加，达到最大堆的容量限制的时候，则会产生内存溢出异常。

我们通过一段代码来演示：

```java
/**
 * @Author Alan
 * @Date 2021/6/25 0:09
 * @Description   -Xms20m -Xmx20m -XX:+HeapDumpOnOutOfMemoryError
 * @Version 1.0
 */
public class HeapOOM {

    static class OOMObject{
    }

    public static void main(String[] args) {
        ArrayList<OOMObject> list = new ArrayList<>();

        // 不断new对象并不断的往list里面放
        while (true){
            list.add(new OOMObject());
        }
    }
}
```

此时我们设置的VMOptions为 ` -Xms20m -Xmx20m -XX:+HeapDumpOnOutOfMemoryError`

![image-20210625002200398](https://gitee.com/lgaaip/img/raw/master/image-20210625002200398.png)

为限制Java堆的大小为20m，所以设置 -Xms 20m -Xmx20m，表示堆空间初始为20m，最大堆也为20m，即不可继续扩展。

`-XX:+HeapDumpOnOutOfMemoryError`参数是为了在虚拟机出现异常的时候，Dump出当前内存堆转储快照以便事后进行分析。

运行程序，结果为：

![image-20210625002518403](https://gitee.com/lgaaip/img/raw/master/image-20210625002518403.png)

生成了Dump出来的堆转存快照文件

![image-20210625003250383](https://gitee.com/lgaaip/img/raw/master/image-20210625003250383.png)

**分析：**

对于以上出现的问题，常规方法就是去通过内存映像工具分析Dump出来的堆转存快照文件，需要分析导致OOM的对象是不是必要的，也就是说要分清楚是**内存溢出**还是**内存泄漏**，从而进一步的做出对应的策略。

我们在IDEA中，可以查看`.hprof`文件。

![image-20210625003341274](https://gitee.com/lgaaip/img/raw/master/image-20210625003341274.png)

- 如果是**内存泄漏**，则可以进一步的查看泄漏对象到GC Root的引用链，找到泄露的对象是通过怎样的引用路径、与哪些GC Roots相关联，导致无法被回收掉的，一般通过如何分析，可以比较准确的找到这些对象创建的位置，进而找到内存泄漏的代码的具体位置。
- 如果是**内存溢出**，也就是说这些对象都是必须存活的，则此时需要考虑Java虚拟机的堆参数（-Xmx与-Xms）的设置，与机器内存相比，是否还有向上调整的空间。然后再在代码中检查是否有某些对象的生命周期太长、持有状态时间过长、存储结构不合理等情况，尽量减少因为代码书写的问题导致的内存消耗。

