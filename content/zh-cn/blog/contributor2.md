---
title: 恭喜 颜文 成为 Koupleless 社区优秀 Contributor！
date: 2024-06-25T10:28:32+08:00
description: 恭喜 颜文 成为 Koupleless 社区优秀 Contributor！
weight: 501
author: 赵真灵
---

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1718883984928-dc6736d7-fae2-495c-886e-233676d39b93.png)



[颜文](https://github.com/qq290584697) 作为[政采云](https://login.zcygov.cn/user-login/#/login)<font style="color:rgb(0, 0, 0);">大客定制团队业务架构师，主要负责对大型客户业务的开发模式优化和研发效能提升。</font><font style="color:rgb(31, 35, 40);">自了解到 Koupleless 的设计理念和实践效果以来，他积极参与 Koupleless 开源社区，并结合内部实践经验，为社区贡献了如下两大实用功能 </font>[MultiBizProperties](https://github.com/koupleless/runtime/blob/main/koupleless-common/src/main/java/com/alipay/sofa/koupleless/common/util/MultiBizProperties.java)<font style="color:rgb(31, 35, 40);">、</font>[Koupleless-web-gateway](https://github.com/koupleless/samples/blob/main/springboot-samples/web/tomcat/README-zh_CN.md)<font style="color:rgb(31, 35, 40);">，并得到社区的好评。2024 年 6 月 20 日，Koupleless 社区 PMC 之一 赵真灵 代表 Koupleless 社区，宣布 颜文 </font>[@巨鹿](https://github.com/qq290584697)<font style="color:rgb(31, 35, 40);"> 通过投票，成为社区优秀 Contributor！</font>

### <font style="color:rgb(31, 35, 40);">commits 记录/PR 贡献等：</font>
[https://github.com/koupleless/koupleless/pulls?q=is%3Apr+is%3Aclosed+author%3Aqq290584697](https://github.com/koupleless/koupleless/pulls?q=is%3Apr+is%3Aclosed+author%3Aqq290584697)

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1718896162808-2a25b212-3ca2-4ca6-aeed-aa34fc4f19bf.png)



[https://github.com/sofastack/sofa-serverless/pulls?q=is%3Apr+is%3Aclosed+author%3Aqq290584697](https://github.com/sofastack/sofa-serverless/pulls?q=is%3Apr+is%3Aclosed+author%3Aqq290584697)<font style="color:rgb(31, 35, 40);">  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1718896105312-0a5cd345-4b61-449c-b737-3f902beb0b34.png)



[https://github.com/sofastack/sofa-ark/pulls?q=is%3Apr+author%3Aqq290584697+is%3Aclosed](https://github.com/sofastack/sofa-ark/pulls?q=is%3Apr+author%3Aqq290584697+is%3Aclosed)

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1718896238461-c3b944c4-ad55-4a32-9734-78655ad3e82c.png)

### <font style="color:rgb(31, 35, 40);">突出贡献：</font>
1. [MultiBizProperties](https://github.com/koupleless/runtime/blob/main/koupleless-common/src/main/java/com/alipay/sofa/koupleless/common/util/MultiBizProperties.java)<font style="color:rgb(31, 35, 40);">：在 Java 里 System.Properties 是 JVM 级别的配置，在多应用合并在一起后可能会存在不同应用间 System Properties 互相干扰的问题，</font>[颜文](https://github.com/qq290584697)<font style="color:rgb(31, 35, 40);"> 提出 MultiBizProperties 方案优雅且低成本的解决了多个应用合并一起后，为不同应用提供了互相隔离 System Properties 能力。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1718895912490-97972138-0cd5-41d8-91c0-0487d95be1ed.png)

2. [Koupleless-web-gateway](https://github.com/koupleless/samples/blob/main/springboot-samples/web/tomcat/README-zh_CN.md): 多个存量应用合并在一个进程后，由于复用一个 tomcat 的 host，需要在原来的web path 里增加一个 webContext Path 来区分不同的应用。但这会导致原来访问的地址发生改变，如 biz1.alipay.com/path/to/content 变成了 biz1.alipay.com/<font style="color:#DF2A3F;">biz1/</font>path/to/content，访问的路径发生了改变。这对于存量应用接入来说，是很大的一个变化，可能涉及到上游的调用路径配置。[颜文](https://github.com/qq290584697) 通过设计进程内的 web forward 能力，能让上游调用路径不变的情况下，把服务转发到对应的 biz 模块内，大大降低了存量应用合并部署的改造成本。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1718895841337-46f2d463-dc28-4d34-8420-fa7ca9b9ca9f.png)

### <font style="color:rgb(31, 35, 40);">成员感想</font>
<font style="color:rgb(0, 0, 0);">很荣幸可以参与到koupleless的开发，这也是我参与的第一个开源项目。前期的时候，甚至连提交PR和提交ISSUE都需要询问，感谢项目成员不厌其烦的指导。在我看来，koupleless是对于微服务架构重大补充，且有望成长为java生态中，极具影响力的项目，期待着未来更多的参与，与koupleless共同成长。</font>

### <font style="color:rgb(31, 35, 40);">社区同学寄语</font>
<font style="color:rgb(31, 35, 40);">感谢</font>[颜文](https://github.com/qq290584697)<font style="color:rgb(31, 35, 40);">一直以来为 Koupleless 项目做出的巨大贡献！期待未来和</font>[颜文](https://github.com/qq290584697)<font style="color:rgb(31, 35, 40);">一起，让 Koupleless 变得更好，帮助更多的企业降本增效、绿色计算！</font>

<font style="color:rgb(31, 35, 40);">同时感谢各位对 Koupleless 社区的贡献，也希望更多的小伙伴加入 Koupleless 社区，共同助力开源社区的快速发展。</font>
