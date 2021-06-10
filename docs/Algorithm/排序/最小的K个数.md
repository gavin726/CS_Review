# 最小的K个数

[题目传送门](https://www.nowcoder.com/practice/6a296eb82cf844ca8539b57c23e6e9bf?tpId=196&tqId=37099&rp=1&ru=%2Fta%2Fjob-code-total&qru=%2Fta%2Fjob-code-total%2Fquestion-ranking&tab=answerKey)

> 众所周知，TopK一直是面试的热点，其实TopK本身问题并不难，但是要怎么效率最高的TopK则没有那么简单，下面我写出了四种方法，层层递进，其实用到的都是上一道题目排序的思想，所以刷题是一个循序渐进的过程~

## 直接排序

利用库函数直接将数组排序，然后输出最小的K个数即可。

```java
public ArrayList<Integer> GetLeastNumbers_Solution(int [] input, int k) {
        ArrayList<Integer> arrayList = new ArrayList<>();
        if (k < 0 || k > input.length)
            return arrayList;
        Arrays.sort(input);

        for (int i = 0; i < k; i++){
            arrayList.add(input[i]);
        }

        return arrayList;
    }
```

时间复杂度：**O(nlogn)**，其中 n 是数组  的长度。

## 部分选择排序

因为只需要输出最小的K个数，那么只需要找出最小的K个即可。（冒泡排序）

时间复杂度 **n*k**

```java
public ArrayList<Integer> GetLeastNumbers_Solution(int [] input, int k) {
        ArrayList<Integer> list = new ArrayList<>();

        if (input.length < k || k < 0 || input.length == 0)
            return list;

        for (int i = 0; i < k; i++){
            for (int j = i+1; j < input.length; j++) {
                if (input[i] > input[j]){
                    int tmp = input[i];
                    input[i] = input[j];
                    input[j] = tmp;
                }
            }
            list.add(input[i]);
        }
        return list;
    }
```



## 优先队列（大小顶堆）

使用优先队列，将数组中的全部元素放进队列中，然后输出K个即可。

时间复杂度 **O(logN)**

```java
public ArrayList<Integer> GetLeastNumbers_Solution(int [] input, int k) {
        ArrayList<Integer> list = new ArrayList<>();
        if (input.length == 0 || input.length < k || k < 0)
            return list;
    //小顶堆（默认就是小顶堆）
        PriorityQueue<Integer> queue = new PriorityQueue<>(new Comparator<Integer>() {
            @Override
            public int compare(Integer o1, Integer o2) {
                return o1.compareTo(o2);
            }
        });
        for (int i = 0; i < input.length; i++) {
            queue.add(input[i]);
        }

        for (int i = 0; i < k; i++) {
            list.add(queue.poll());
        }
        return list;
    }
```

上面是直接将全部的数放进队列中，那么还可以再优化一下。

我们可以在刚开始的时候放K个值进去即可，初始化一个大顶堆，此时放进去K个值，堆顶是堆中最大的值，我们将数组中剩下的值每次都跟堆顶进行比较，如果堆顶的值大于数组元素，那么就想数组元素置换进去，依次选择比较，最后堆中的元素即可最小的K个。

```java
/**
     * 使用优先队列进行排序
     * @param input
     * @param k
     * @return
     */
    public ArrayList<Integer> GetLeastNumbers_Solution1(int [] input, int k) {
        ArrayList<Integer> list = new ArrayList<>();
        if (input.length == 0 || input.length < k || k < 0)
            return list;
        //大顶堆
        PriorityQueue<Integer> queue = new PriorityQueue<>(new Comparator<Integer>() {
            @Override
            public int compare(Integer o1, Integer o2) {
                return o2.compareTo(o1);
            }
        });
        //放进去K个数
        for (int i = 0; i < k; i++) {
            queue.offer(input[i]);
        }
        //依次跟堆中最大的数进行比较
        for (int i = k; i < input.length; i++) {
            if (queue.peek() > input[i]){
                queue.poll();
                queue.offer(input[i]);
            }
        }

        for (int i = 0; i < k; i++) {
            list.add(queue.poll());
        }
        return list;
    }
```



## 快速排序

其实题目可以利用快速排序的思想，在上一题我们都知道快速排序是利用找到分割点，分割点左边的值都大于右边的值，所以此时我们利用这一点，如果分割点此时等于k-1，那么证明分割点左边的数就要找到的k个最数了，如果大于k-1，那么继续在左边分割，如果大于k+1，则在右边分割。这样问题就迎刃而解了。

时间复杂度 **O(n)**

```java
/**
     * 找出分割点
     */
    public int partition(int[] arr, int left, int right, int k){

        //选取一个基准值
        int base = arr[left];
        while(left < right){
            while (left < right && arr[right] >= base)
                right--;
            //右边小于基准值的往左填
            swap(arr,left,right);
            while (left < right && arr[left] <= base)
                left++;
            //左边大于基准值的往右填
            swap(arr,left,right);
        }
        //此时 left为分界，左边的是小的，右边的是大的
        return left;
    }

    public void quickSort(int[] arr, int left, int right, int k){
        if (left < right) {
            int partition = partition(arr, left, right, k);
            if (partition == k-1)
                return;
            else if (partition < k-1)
                quickSort(arr,partition+1,right,k);
            else
                quickSort(arr,left,partition-1,k);
        }
    }

    /**
     * 交换顺序
     * @param arr
     * @param left
     * @param right
     */
    private void swap(int[] arr, int left, int right) {
        int tmp = arr[left];
        arr[left] = arr[right];
        arr[right] = tmp;
    }


    /**
     * 基于快速排序的思想进行解题
     * @param input
     * @param k
     * @return
     */
    private ArrayList<Integer> GetLeastNumbers_Solution(int[] input, int k) {
        ArrayList<Integer> list = new ArrayList<>();
        if (input.length == 0 || k < 0 || input.length < k)
            return list;
        quickSort(input,0,input.length-1,k);
        for (int i = 0; i < k; i++) {
            list.add(input[i]);
        }
        return list;


    }
```

