# elasticsearch入门操作

## 下载安装

**下载elasticsearch  和 elasticsearch-head（可视化）**

> 跨域问题解决

**在elasticsearch.yml下配置**

```
http.cors.enabled: true
http.cors.allow-origin: "*"
```

**安装ik分词器**

> 加压到elasticsearch的plugins目录下

![image-20200729111532318](https://gitee.com/lgaaip/img/raw/master/img/20200729111540.png)

**1、ik_max_word**

会将文本做最细粒度的拆分，比如会将“中华人民共和国人民大会堂”拆分为“中华人民共和国、中华人民、中华、华人、人民共和国、人民、共和国、大会堂、大会、会堂等词语。

**2、ik_smart**
会做最粗粒度的拆分，比如会将“中华人民共和国人民大会堂”拆分为中华人民共和国、人民大会堂



> 重启elasticsearch和kibana

`ik_smart`

![image-20200729111626720](https://gitee.com/lgaaip/img/raw/master/img/20200729111628.png)

`ik_max_word`

![image-20200729111653461](https://gitee.com/lgaaip/img/raw/master/img/20200729111655.png)

之所以能够分词，是根据它默认的字典来的

> 所以问题来了，如果我们搜索的词语字典中没有呢，都被分成每一个字，这显然不是我们想要的结果，那么这个时候我们就可以自定义字典

`没自定义字典`

![image-20200729111920522](https://gitee.com/lgaaip/img/raw/master/img/20200729111921.png)

现在我们来自定义字典

![image-20200729112032595](https://gitee.com/lgaaip/img/raw/master/img/20200729112034.png)

自定义字典也很简单，自己新建一个dic文件，然后在扩展配置文件中添加自己自定义的字典即可！

![image-20200729112243746](https://gitee.com/lgaaip/img/raw/master/img/20200729112244.png)

> 重启elasticsearch  和 kibana

可以看到此时elasticsearch 加载了我们自定义的字典了

![image-20200729112327418](https://gitee.com/lgaaip/img/raw/master/img/20200729112328.png)

重新进行搜索，此时可以发现，我们想要的词语不会被分成一个个单独的字了

![image-20200729112814207](https://gitee.com/lgaaip/img/raw/master/img/20200729112815.png)

## 基础操作

**Restful**

1. **创建索引**

![image-20200729200312977](https://gitee.com/lgaaip/img/raw/master/img/20200729200314.png)

2. **创建索引的规则 mappings**

![image-20200729201251433](https://gitee.com/lgaaip/img/raw/master/img/20200729201252.png)

3. **获取索引规则，使用get**

![image-20200729201407754](https://gitee.com/lgaaip/img/raw/master/img/20200729201408.png)

4. **如果自己的文档字段没有指定，那么ES就会给我们默认配置字段类型**

![image-20200729201638154](https://gitee.com/lgaaip/img/raw/master/img/20200729201639.png)

> 扩展：通过命令 ES 索引情况！ 通过 _cat/ 可以获得es的当前的很多信息
>
> GET _cat/health
>
> GET _cat/indices?v

5. **修改**

   `使用post进行修改`

![image-20200729202102310](https://gitee.com/lgaaip/img/raw/master/img/20200729202106.png)

当我们其他的字段没有赋值的时候，就没了

![image-20200729202242528](https://gitee.com/lgaaip/img/raw/master/img/20200729202243.png)

![image-20200729202257758](https://gitee.com/lgaaip/img/raw/master/img/20200729202258.png)

`POST进行修改`       **推荐使用**

![image-20200729202439028](https://gitee.com/lgaaip/img/raw/master/img/20200729202439.png)

我们可以发现，此时我们只修改了 name ，没有对age进行修改的,   age原始的值是不会丢失的

![image-20200729202529969](https://gitee.com/lgaaip/img/raw/master/img/20200729202531.png)

6. **删除索引** （使用delete直接删除）

![image-20200729202718070](https://gitee.com/lgaaip/img/raw/master/img/20200729202720.png)

## 文档操作

1. **简单搜索** 

   GET /test/user/3

​		简单的条件查询，可以根据默认的映射规则，产生基本的查询

```
GET test1/user/_search?q=name:Alan2
```

![image-20200729203521465](https://gitee.com/lgaaip/img/raw/master/img/20200729203522.png)

2. **复杂查询**

![image-20200729204947871](https://gitee.com/lgaaip/img/raw/master/img/20200729204949.png)

> 其他的一些操作

```java
输出结果不想要那么多！ select name， desc from ----
GET ybs/user/_search
{
  "query": {
    "match": {
      "name": "Alan"
    }
  },
  "_source": ["name", "desc"]
}
我们之后使用Java 操作 Es，所有的方法和对象就是这里面的key！
 
排序 sort 
GET ybs/user/_search
{
  "query": {
    "match": {
      "name": "Alan"
    }
  },
  "sort": [
    {
      "age": {
        "order": "asc"
      }
    }
    ]
}
分页 from size  从几个开始 返回多少条
GET ybs/user/_search
{
  "query": {
    "match": {
      "name": "Alan"
    }
  },
  "sort": [
    {
      "age": {
        "order": "asc"
      }
    }
    ],
    "from": 0,
    "size": 2
}
```

**_source 进行对字段进行过滤**

```java
GET kuangshen/user/_search
{
  "query":{
    "match":{
      "name":"Alan"
    }
  },
   "_source":["name","age"]
}

```

**sort 排序！**

```java
   "sort": [
     {
       "FIELD": {
         "order": "desc"或者asc
       }
     }
   ]

```

**分页查询**

```java
"from"：    起始值
"size":		大小
12
GET kuangshen/user/_search
{
  "query":{
    "match":{
      "name":"Alan"
    }
  },
   "sort": [
     {
       "age": {
         "order": "desc"
       }
     }
   ],
   "from":0,
   "size": 1
}

```

**must （and），所有的条件都要符合 where id = 1 and name = xxx**

```java
GET kuangshen/user/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "name": "Alan"
          }
        },
        {
          "match": {
            "age": "30"
          }
        }
      ]
    }
  }
}

```

**should（or），所有的条件都要符合 where id = 1 or name = xxx**

**must_not （not）**

**过滤器 filter**

- gt 大于
- gte 大于等于
- lt小于
- lte 小于等于！

```java
  "filter": [
        {"range": {
          "age": {
            "gte": 10,
            "lte": 30
          }
        }}
      ]

```

**匹配多个条件！**

```java
  "query": {
    "match": {
      "tags": "男 暖"
    }
  }

```

**term**

查询是直接通过倒排索引指定的词条进程精确查找的！

**关于分词：**

- term ，直接查询精确的
- match，会使用分词器解析！（先分析文档，然后在通过分析的文档进行查询！）

**两个类型 text keyword**

**高亮查询！**

```java
GET kuangshen/user/_search
{
  "query": {
    "match": {
      "name":"java" 
    }
  },
  "highlight": {
    "fields": {
      "name":{}
    }
  }
}

```

**自定义搜索高亮**

```java
  "highlight": {
    "pre_tags": "<p class='key' style='color:red' >",
    "post_tags": "</p>", 
    "fields": {
      "name":{}
    }

```

- 匹配
- 按照条件匹配
- 精确匹配
- 区间范围匹配
- 匹配字段过滤
- 多条件查询
- 高亮查询



## 集成SpringBoot

`直接找到 elasticsearch 的官网，看文档 `     [官方文档](https://www.elastic.co/guide/en/elasticsearch/client/index.html)

![image-20200730101544567](https://gitee.com/lgaaip/img/raw/master/img/20200730101552.png)

![image-20200730101658538](https://gitee.com/lgaaip/img/raw/master/img/20200730101659.png)

>  我们学习高水平的文档

![image-20200730101734059](https://gitee.com/lgaaip/img/raw/master/img/20200730101735.png)

> 开始，新建一个springboot项目，勾选需要的依赖

**1、原生的依赖**

```xml
<dependency>
    <groupId>org.elasticsearch.client</groupId>
    <artifactId>elasticsearch-rest-high-level-client</artifactId>
    <version>7.8.0</version>
</dependency>
```

**2、官方文档提供的初始化**

```java
RestHighLevelClient client = new RestHighLevelClient(
        RestClient.builder(
                new HttpHost("localhost", 9200, "http"),
                new HttpHost("localhost", 9201, "http")));
```

​     **关闭方法**

```java
client.close();
```

**3、检查springboot导入的依赖是否与本机es版本对应**

​    **自定义导入es 的版本依赖**

```xml
<elasticsearch.version>7.8.0</elasticsearch.version>
```

**4、分析源码（	这三个自动配置类	）**

```java
ElasticsearchAutoConfiguration.class,
RestClientAutoConfiguration.class, 
ReactiveRestClientAutoConfiguration.class
```



> API测试

- 1、创建索引
- 2、判断索引是否存在
- 3、删除索引
- 4、创建文档
- 5、crud文档！

```java
package pers.alan;

import com.alibaba.fastjson.JSON;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexRequest;
import org.elasticsearch.action.bulk.BulkRequest;
import org.elasticsearch.action.bulk.BulkResponse;
import org.elasticsearch.action.delete.DeleteRequest;
import org.elasticsearch.action.delete.DeleteResponse;
import org.elasticsearch.action.get.GetRequest;
import org.elasticsearch.action.get.GetResponse;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.support.master.AcknowledgedResponse;
import org.elasticsearch.action.update.UpdateRequest;
import org.elasticsearch.action.update.UpdateResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.client.indices.CreateIndexRequest;
import org.elasticsearch.client.indices.CreateIndexResponse;
import org.elasticsearch.client.indices.GetIndexRequest;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.common.xcontent.XContentType;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.index.query.TermQueryBuilder;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.FetchSourceContext;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import pers.alan.pojo.User;


import java.io.IOException;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

@SpringBootTest
class EsApiApplicationTests {

    @Autowired
    @Qualifier("restHighLevelClient")
    private RestHighLevelClient client;

    //测试创建索引
    @Test
    void contextLoads() throws IOException {
        //1、 创建 索引  获取索引请求
        CreateIndexRequest request = new CreateIndexRequest("alantest_index");
        //2、客户端执行请求 IndicesClient，请求后获得响应
        CreateIndexResponse response = client.indices().create(request, RequestOptions.DEFAULT);
        System.out.println(response);

    }

    //测试获取索引
    @Test
    void getExistsIndex() throws IOException {
        //  获取对应索引名的请求
        GetIndexRequest request = new GetIndexRequest("alantest_index");
        // 判断该请求是否存在
        boolean exists = client.indices().exists(request, RequestOptions.DEFAULT);
        System.out.println(exists);
    }

    //测试删除索引
    @Test
    void deleteIndex() throws IOException {
        DeleteIndexRequest request = new DeleteIndexRequest("alantest_index");
        AcknowledgedResponse delete = client.indices().delete(request, RequestOptions.DEFAULT);
        System.out.println(delete.isAcknowledged());
    }
    //测试添加文档
    @Test
    void testAddDocument() throws IOException {
        User user = new User("alan", 3);

        //获取请求索引
        IndexRequest request = new IndexRequest("testalan_index");
        //设置请求规则
        request.id("1");
        //request.timeout(TimeValue.timeValueSeconds(1));
        request.timeout("1s");

        //将数据放到请求中
        request.source(JSON.toJSONString(user), XContentType.JSON);


        IndexResponse indexResponse = client.index(request, RequestOptions.DEFAULT);

        System.out.println(indexResponse.toString());
        System.out.println(indexResponse.status());

    }

    // 获取文档，判断是否存在 get /index/doc/1
    @Test
    void testIsExists() throws IOException {
        GetRequest getRequest = new GetRequest("testalan_index", "1");
        // 不获取返回的 _source 的上下文了
        getRequest.fetchSourceContext(new FetchSourceContext(false));
        getRequest.storedFields("_none_");
        boolean exists = client.exists(getRequest, RequestOptions.DEFAULT);
        System.out.println(exists);
    }

    // 获得文档的信息
    @Test
    void testGetDocument() throws IOException {
        GetRequest getRequest = new GetRequest("testalan_index", "1");
        GetResponse getResponse = client.get(getRequest,
                RequestOptions.DEFAULT);
        System.out.println(getResponse.getSourceAsString()); // 打印文档的内容
        System.out.println(getResponse); // 返回的全部内容和命令式一样的
    }

    // 更新文档的信息
    @Test
    void testUpdateRequest() throws IOException {
        UpdateRequest updateRequest = new UpdateRequest("testalan_index", "1");
        updateRequest.timeout("1s");
        User user = new User("狂神说Java", 18);
        updateRequest.doc(JSON.toJSONString(user), XContentType.JSON);
        UpdateResponse updateResponse = client.update(updateRequest,
                RequestOptions.DEFAULT);
        System.out.println(updateResponse.status());
    }

    // 删除文档记录
    @Test
    void testDeleteRequest() throws IOException {
        DeleteRequest request = new DeleteRequest("testalan_index", "1");
        request.timeout("1s");
        DeleteResponse deleteResponse = client.delete(request,
                RequestOptions.DEFAULT);
        System.out.println(deleteResponse.status());
    }
    // 特殊的，真的项目一般都会批量插入数据！
    @Test
    void testBulkRequest() throws IOException {
        BulkRequest bulkRequest = new BulkRequest();
        bulkRequest.timeout("10s");
        ArrayList<User> userList = new ArrayList<>();
        userList.add(new User("alan1",3));
        userList.add(new User("alan2",3));
        userList.add(new User("alan3",3));
        userList.add(new User("lin1",3));
        userList.add(new User("lin1",3));
        userList.add(new User("lin1",3));
    // 批处理请求
        for (int i = 0; i < userList.size() ; i++) {
    // 批量更新和批量删除，就在这里修改对应的请求就可以了
            bulkRequest.add(
                    new IndexRequest("testalan_index")
                            .id(""+(i+1))
                            .source(JSON.toJSONString(userList.get(i)),XContentType.JSON));
        }
        BulkResponse bulkResponse = client.bulk(bulkRequest,
                RequestOptions.DEFAULT);
        client.close();
        System.out.println(bulkResponse.hasFailures()); // 是否失败，返回 false 代表成功！
    }
    // 查询
    // SearchRequest 搜索请求
    // SearchSourceBuilder 条件构造
    // HighlightBuilder 构建高亮
    // TermQueryBuilder 精确查询
    // MatchAllQueryBuilder
    // xxx QueryBuilder 对应我们刚才看到的命令！
    @Test
    void testSearch() throws IOException {
        SearchRequest searchRequest = new SearchRequest("testalan_index");
    // 构建搜索条件
        SearchSourceBuilder sourceBuilder = new SearchSourceBuilder();
        sourceBuilder.highlighter();
    // 查询条件，我们可以使用 QueryBuilders 工具来实现
    // QueryBuilders.termQuery 精确
    // QueryBuilders.matchAllQuery() 匹配所有
        TermQueryBuilder termQueryBuilder = QueryBuilders.termQuery("name",
                "lin1");
    // MatchAllQueryBuilder matchAllQueryBuilder = QueryBuilders.matchAllQuery();
        sourceBuilder.query(termQueryBuilder);
        sourceBuilder.timeout(new TimeValue(60, TimeUnit.SECONDS));
        searchRequest.source(sourceBuilder);
        SearchResponse searchResponse = client.search(searchRequest,RequestOptions.DEFAULT);

        System.out.println(JSON.toJSONString(searchResponse.getHits()));
        System.out.println("=================================");
        for (SearchHit documentFields : searchResponse.getHits().getHits()) {
            System.out.println(documentFields.getSourceAsMap());
        }
    }

}

```

