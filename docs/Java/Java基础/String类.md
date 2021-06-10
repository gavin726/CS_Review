# String类

## 常用方法介绍

String类是Java最常用的API，它包含了大量处理字符串的方法，比较常用的有：

- char charAt(int index)：返回指定索引处的字符；
- String substring(int beginIndex, int endIndex)：从此字符串中截取出一部分子字符串；
- String[] split(String regex)：以指定的规则将此字符串分割成数组；
- String trim()：删除字符串前导和后置的空格；
- int indexOf(String str)：返回子串在此字符串首次出现的索引；
- int lastIndexOf(String str)：返回子串在此字符串最后出现的索引；
- boolean startsWith(String prefix)：判断此字符串是否以指定的前缀开头；
- boolean endsWith(String suffix)：判断此字符串是否以指定的后缀结尾；
- String toUpperCase()：将此字符串中所有的字符大写；String toLowerCase()：将此字符串中所有的字符小写；
- String replaceFirst(String regex, String replacement)：用指定字符串替换第一个匹配的子串；
- String replaceAll(String regex, String replacement)：用指定字符串替换所有的匹配的子串。

- T valueOf(T i)：返回T参数的字符串T形式

> 以上只是String类中部分常用到的方法，具体方法可以自行查看JDK1.8官方文档去了解具体的意思。



## String可以被继承吗？

**String类被final修饰，所以不可变。**

> 这里穿插一下final关键字的说明，final修饰类时，被修饰的类就不能被继承，类中的方法不能被重写，但是可以被重载，final修饰成员变量时，如果是修饰基本数据类型的话，则被修饰的变量不可变，若修饰的是引用类型时，则被修饰的变量只能指向初始化时的那个对象，不能再指向其他的对象了，但是对象的内容是可变的。所以这就有了String的不可变性。

在Java中，String类被设计为不可变类，主要表现在它保存字符串的成员变量是final的。

- Java 9之前字符串采用char[]数组来保存字符，即 private final char[] value ；
- Java 9做了改进，采用byte[]数组来保存字符，即 private final byte[] value ；

之所以要把String类设计为不可变类，主要是出于安全和性能的考虑，可归纳为如下4点。

1. **安全性**。由于字符串无论在任何 Java 系统中都广泛使用，会用来存储敏感信息，如账号，密码，网络路径，文件处理等场景里，保证字符串 String 类的安全性就尤为重要了，如果字符串是可变的，容易被篡改，那我们就无法保证使用字符串进行操作时，它是安全的，很有可能出现 SQL 注入，访问危险文件等操作。

2. **线程安全**。在多线程中，只有不变的对象和值是线程安全的，可以在多个线程中共享数据。由于 String 天然的不可变，当一个线程”修改“了字符串的值，只会产生一个新的字符串对象，不会对其他线程的访问产生副作用，访问的都是同样的字符串数据，不需要任何同步操作。

3. **hash缓存**。字符串作为基础的数据结构，大量地应用在一些集合容器之中，尤其是一些散列集合，在散列集合中，存放元素都要根据对象的 hashCode() 方法来确定元素的位置。由于字符串 hashcode 属性不会变更，保证了唯一性，使得类似 HashMap，HashSet 等容器才能实现相应的缓存功能。由于String 的不可变，避免重复计算 hashcode ，只要使用缓存的 hashcode 即可，这样一来大大提高了在散列集合中使用 String 对象的性能。

4. **String Pool 的需要**。当字符串不可变时，字符串常量池才有意义。字符串常量池的出现，可以减少创建相同字面量的字符串，让不同的引用指向池中同一个字符串，为运行时节约很多的堆内存。若字符串可变，字符串常量池失去意义，基于常量池的 String.intern() 方法也失效，每次创建新的字符串将在堆内开辟出新的空间，占据更多的内存。

   ​     ![image-20210304095207361](https://gitee.com/lgaaip/img/raw/master/20210304095208.png)

因为要保证String类的不可变，那么将这个类定义为final的就很容易理解了。如果没有final修饰，那么就会存在String的子类，这些子类可以重写String类的方法，强行改变字符串的值，这便违背了String类设计的初衷。

## StringBuffer和StringBuilder了解吗？

**`Stirng和StringBuffer的区别：`**

- String类是不可变的，一旦一个String对象被创建以后，包含在这个对象中的字符序列是不可改变的，直到这个对象被销毁。

- StringBuffer对象则代表一个字符序列可变的字符串，当一个StringBuffer被创建以后，通过StringBuffer提供的append()、insert()、reverse()、setCharAt()、setLength()等方法可以改变这个字符串对象的字符序列。一旦通过StringBuffer生成了最终想要的字符串，就可以调用它的toString()方法

  将其转换为一个String对象。

**`StringBuffer和StringBuilder的区别：`**

StringBuffer、StringBuilder都代表可变的字符串对象，它们有共同的父类AbstractStringBuilder ，并且两个类的构造方法和成员方法也基本相同。不同的是，**StringBuffer是线程安全的，而StringBuilder是非线程安全的**，所以`StringBuilder性能略高`。一般情况下，要创建一个内容可变的字符串，建议优先考虑StringBuilder类。



对于三者使⽤的总结：

1. 操作少量的数据: 适⽤ String

2. 单线程操作字符串缓冲区下操作⼤量数据: 适⽤ StringBuilder

3. 多线程操作字符串缓冲区下操作⼤量数据: 适⽤ StringBuffer



## **使用字符串时，new和" "推荐使用哪种方式？**

先看看 "hello" 和 new String("hello") 的区别：

- 当Java程序直接使用 "hello" 的字符串直接量时，JVM将会使用常量池来管理这个字符串；

- 当使用 new String("hello") 时，JVM会先使用常量池来管理 "hello" 直接量，再调用String类的构造器来创建一个新的String对象，新创建的String对象被保存在堆内存中。

显然，采用new的方式会多创建一个对象出来，会占用更多的内存，所以一般建议使用直接量的方式创建字符串。

​           ![image-20210304101944671](https://gitee.com/lgaaip/img/raw/master/20210304105926.png)

## 说一说你对字符串拼接的理解

拼接字符串有很多种方式，其中最常用的有4种，下面列举了这4种方式各自适合的场景。

1. 运算符：如果拼接的都是字符串直接量，则适合使用 + 运算符实现拼接；

2. StringBuilder：如果拼接的字符串中包含变量，并不要求线程安全，则适合使用StringBuilder； 

3. StringBuffer：如果拼接的字符串中包含变量，并且要求线程安全，则适合使用StringBuffer； 

4. String类的concat方法：如果只是对两个字符串进行拼接，并且包含变量，则适合使用concat方法；

**扩展：**

采用 + 运算符拼接字符串时：

- 如果拼接的都是字符串直接量，则在编译时编译器会将其直接优化为一个完整的字符串，和你直接写一个完整的字符串是一样的，所以效率非常的高。
- 如果拼接的字符串中包含变量，则在编译时编译器采用StringBuilder对其进行优化，即自动创建StringBuilder实例并调用其append()方法，将这些字符串拼接在一起，效率也很高。但如果这个拼接操作是在循环中进行的，那么每次循环编译器都会创建一个StringBuilder实例，再去拼接字符串，相当于执行了 new StringBuilder().append(str) ，所以此时效率很低。

采用StringBuilder/StringBuffer拼接字符串时：

- StringBuilder/StringBuffer都有字符串缓冲区，缓冲区的容量在创建对象时确定，并且默认为16。当拼接的字符串超过缓冲区的容量时，会触发缓冲区的扩容机制，即缓冲区加倍。
- 缓冲区频繁的扩容会降低拼接的性能，所以如果能提前预估最终字符串的长度，则建议在创建可变字符串对象时，放弃使用默认的容量，可以指定缓冲区的容量为预估的字符串的长度。

采用String类的concat方法拼接字符串时：

- concat方法的拼接逻辑是，先创建一个足以容纳待拼接的两个字符串的字节数组，然后先后将两个字符串拼到这个数组里，最后将此数组转换为字符串。
- 在拼接大量字符串的时候，concat方法的效率低于StringBuilder。但是只拼接2个字符串时，concat方法的效率要优于StringBuilder。并且这种拼接方式代码简洁，所以只拼2个字符串时建议优先选择concat方法。

>  **小结：**

- 如果拼接的都是字符串直接量，则在编译时编译器会将其直接优化为一个完整的字符串，和你直接写一个完整的字符串是一样的。

- 如果拼接的字符串中包含变量，则在编译时编译器采用StringBuilder对其进行优化，即自动创建StringBuilder实例并调用其append()方法，将这些字符串拼接在一起。

