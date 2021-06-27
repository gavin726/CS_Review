## 一、OOM实战

### 1、Java堆溢出

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



### 2、虚拟机栈和本地方法栈溢出

由于HotSpot虚拟机中并不区分虚拟机栈和本地方法栈，因此对于HotSpot来说，-Xoss参数（设置本地方法栈大小）虽然存在，但实际上是没有任何效果的，栈容量只能由-Xss参数来设定。

关于虚拟机栈和本地方法栈，在《Java虚拟机规范》中描述了两种异常：

1）如果线程请求的栈深度大于虚拟机所允许的最大深度，将抛出 `StackOverflowError`异常。

2）如果虚拟机的栈内存允许动态扩展，当扩展栈容量无法申请到足够的内存时，将抛出 `OutOfMemoryError` 异常。

《Java虚拟机规范》明确允许Java虚拟机实现自行选择是否支持栈的动态扩展，而HotSpot虚拟机的选择是不支持扩展，所以除非在**创建线程申请内存时就因无法获得足够内存**而出现`OutOfMemoryError`异常，否则在线程运行时是不会因为扩展而导致内存溢出的，只会因为**栈容量无法容纳新的栈帧**而导致`StackOverflowError`异常。

下面我们就来写一些用例验证上面说的~

①首先使用-Xss参数减少栈内存容量

```java
public class JavaVMStackSOF {
    private int stackLength = 1;

    public void stackLeak(){
        stackLength++;
        // 自己调自己
        stackLeak();
    }

    public static void main(String[] args) {
        JavaVMStackSOF oom = new JavaVMStackSOF();

        try {
            oom.stackLeak();
        } catch (Throwable e) {
            System.out.println("stack Length"+ oom.stackLength);
            e.printStackTrace();
        }
    }
}
```

运行结果：抛出StackOverflowError异常，异常出现时输出的堆栈深度相应缩小。

![image-20210626012013957](https://gitee.com/lgaaip/img/raw/master/image-20210626012013957.png)

② 定义了大量的本地变量，增大此方法帧中本地变量表的长度

```java
package com.cr.oom;

/**
 * @Author Alan
 * @Date 2021/6/26 1:22
 * @Description
 * @Version 1.0
 */
public class JavaVMStackSOF1 {

    private static int stackLength = 0;

    public static void test() {
        long unused1, unused2, unused3, unused4, unused5,
                unused6, unused7, unused8, unused9, unused10,
                unused11, unused12, unused13, unused14, unused15,
                unused16, unused17, unused18, unused19, unused20,
                unused21, unused22, unused23, unused24, unused25,
                unused26, unused27, unused28, unused29, unused30,
                unused31, unused32, unused33, unused34, unused35,
                unused36, unused37, unused38, unused39, unused40,
                unused41, unused42, unused43, unused44, unused45,
                unused46, unused47, unused48, unused49, unused50,
                unused51, unused52, unused53, unused54, unused55,
                unused56, unused57, unused58, unused59, unused60,
                unused61, unused62, unused63, unused64, unused65,
                unused66, unused67, unused68, unused69, unused70,
                unused71, unused72, unused73, unused74, unused75,
                unused76, unused77, unused78, unused79, unused80,
                unused81, unused82, unused83, unused84, unused85,
                unused86, unused87, unused88, unused89, unused90,
                unused91, unused92, unused93, unused94, unused95,
                unused96, unused97, unused98, unused99, unused100;

        stackLength++;
        test();
        unused1 = unused2 = unused3 = unused4 = unused5 =
        unused6 = unused7 = unused8 = unused9 = unused10 =
        unused11 = unused12 = unused13 = unused14 = unused15 =
        unused16 = unused17 = unused18 = unused19 = unused20 =
        unused21 = unused22 = unused23 = unused24 = unused25 =
        unused26 = unused27 = unused28 = unused29 = unused30 =
        unused31 = unused32 = unused33 = unused34 = unused35 =
        unused36 = unused37 = unused38 = unused39 = unused40 =
        unused41 = unused42 = unused43 = unused44 = unused45 =
        unused46 = unused47 = unused48 = unused49 = unused50 =
        unused51 = unused52 = unused53 = unused54 = unused55 =
        unused56 = unused57 = unused58 = unused59 = unused60 =
        unused61 = unused62 = unused63 = unused64 = unused65 =
        unused66 = unused67 = unused68 = unused69 = unused70 =
        unused71 = unused72 = unused73 = unused74 = unused75 =
        unused76 = unused77 = unused78 = unused79 = unused80 =
        unused81 = unused82 = unused83 = unused84 = unused85 =
        unused86 = unused87 = unused88 = unused89 = unused90 =
        unused91 = unused92 = unused93 = unused94 = unused95 =
        unused96 = unused97 = unused98 = unused99 = unused100 = 0;
    }


    public static void main(String[] args) {
        try {
            test();
        }catch (Error e){
            System.out.println("stack length:" + stackLength);
            throw e;
        }
    }
}

```

运行结果：抛出StackOverflowError异常，异常出现时输出的堆栈深度相应缩小。



**实验结果表明**：无论是由于栈帧太大还是虚拟机栈容量太小，当新的栈帧内存无法分配的时候，HotSpot虚拟机抛出的都是StackOverflowError异常。可是如果在允许动态扩展栈容量大小的虚拟机上，相同代码则会导致不一样的情况。



