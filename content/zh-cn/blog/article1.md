---
title: 线上应用 10 秒启动、只占 20M 内存不再是想象～SOFAServerless 为你带来极致研发体验
date: 2024-01-25T10:28:32+08:00
weight: 200
author: 赵真灵
---


<font style="color:rgb(18, 18, 18);">你想让手上的工程仅需增加一个打包插件，即可变成10秒启动，只占20M内存的工程吗？</font><font style="color:rgb(0, 0, 0);">你是否遇到大应用多人协作互相阻塞，发布效率太低的问题吗？是否遇到小应用太多，资源浪费严重的问题吗？今天我们和大家介绍</font><font style="color:rgb(18, 18, 18);">基于模块化能力，从应用架构、研发框架和运维调度方面提供的完整配套的 SOFAServerless 项目</font><font style="color:rgb(0, 0, 0);">，帮助解决这些与你息息相关的问题，让存量应用一键接入，享受秒级启动、资源无感等收益，轻松跨入 Serverless 研发模式，帮助企业降本增效。</font>

## <font style="color:rgba(0, 0, 0, 0.95);">模块化应用架构</font>
<font style="color:rgba(0, 0, 0, 0.95);">为了解决这些问题，我们对应用同时做了横向和纵向的拆分。首先第一步纵向拆分：把应用拆分成</font>**<font style="color:rgba(0, 0, 0, 0.95);">基座</font>**<font style="color:rgba(0, 0, 0, 0.95);">和</font>**<font style="color:rgba(0, 0, 0, 0.95);">业务</font>**<font style="color:rgba(0, 0, 0, 0.95);">两层，这两层分别对应两层的组织分工。基座小组与传统应用一样，负责机器维护、通用逻辑沉淀、业务架构治理，并为业务提供运行资源和环境。通过关注点分离的方式为业务屏蔽业务以下所有基础设施，聚焦在业务自身上。第二部我们将业务进行横向切分出多个模块，多个模块之间独立并行迭代互不影响，同时模块由于不包含基座部分，构建产物非常轻量，启动逻辑也只包含业务本身，所以启动快，具备秒级的验证能力，让模块开发得到极致的提效。  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695131313965-18385213-eded-4a6b-b554-db5312fa2c9d.png#clientId=ua84a92a5-30aa-4&from=paste&height=431&id=udb6b29d5&originHeight=862&originWidth=3448&originalType=binary&ratio=2&rotation=0&showTitle=false&size=192627&status=done&style=none&taskId=u9a114a24-0887-48d9-87b2-57d3e15eb80&title=&width=1724)<font style="color:rgba(0, 0, 0, 0.95);">  
</font><font style="color:rgba(0, 0, 0, 0.95);">拆分之前，每个开发者可能感知从框架到中间件到业务公共部分到业务自身所有代码和逻辑，拆分后，团队的协作分工也从发生改变，研发人员分工出两种角色，基座和模块开发者，模块开发者不关系资源与容量，享受秒级部署验证能力，聚焦在业务逻辑自身上。  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695131554610-ef5c4a2f-0080-45eb-8fed-55fdf5d827f9.png#clientId=ua84a92a5-30aa-4&from=paste&height=459&id=u7227f759&originHeight=918&originWidth=3714&originalType=binary&ratio=2&rotation=0&showTitle=false&size=309179&status=done&style=none&taskId=u12307968-2a79-4f77-9c78-e976399c60e&title=&width=1857)

<font style="color:rgba(0, 0, 0, 0.95);">这里要重点看下我们是如何做这些纵向和横向切分的，切分是为了隔离，隔离是为了能够独立迭代、剥离不必要的依赖，然而如果只是隔离是没有共享相当于只是换了个部署的位置而已，很难有好的效果。所以我们除了隔离还有共享能力，所以这里需要聚焦在隔离与共享上来理解模块化架构背后的原理。</font>

### <font style="color:rgba(0, 0, 0, 0.95);">架构的优势</font>
<font style="color:rgba(0, 0, 0, 0.95);">我们根据在蚂蚁内部实际落地的效果，总结模块化架构的优势主要集中在这四点：快、省、灵活部署、可演进上，</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701399487160-11d81716-494a-41e2-bbce-4a79beef470b.png)

<font style="color:rgba(0, 0, 0, 0.95);">与传统应用对比数据如下，可以看到在研发阶段、部署阶段、运行阶段都得到了10倍以上的提升效果。  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695180250909-f5eca1b3-c416-4bac-9732-549a9bed8b87.png#clientId=ueb39d37f-ca7b-4&from=paste&height=261&id=u8907b613&originHeight=522&originWidth=2838&originalType=binary&ratio=2&rotation=0&showTitle=false&size=219589&status=done&style=none&taskId=ua4b2bd1b-a75f-4945-abce-68826a43377&title=&width=1419)



### 适用的场景
经过在蚂蚁内部 4 到 5 年的打磨，逐渐沉淀出适用的6大场景，可以看看是否有你适合的口味？

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701427273311-8c954fd1-fe91-446d-935e-1b8d718bd55e.png)

## <font style="color:rgba(0, 0, 0, 0.95);">运维调度平台架构</font>
<font style="color:rgba(0, 0, 0, 0.95);">只有应用架构还不够，需要从研发阶段到运维阶段到运行阶段都提供完整的配套能力，才能让模块化应用架构的优势真正触达到研发人员。</font>

<font style="color:rgba(0, 0, 0, 0.95);">  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695182073971-12b14861-b6fa-470c-a140-737d40ff0b3e.png#clientId=u9014394b-3a6a-4&from=paste&height=192&id=ub53430b2&originHeight=384&originWidth=1720&originalType=binary&ratio=2&rotation=0&showTitle=false&size=79335&status=done&style=none&taskId=u1eb2a897-c2ca-437f-8d56-7067be175e2&title=&width=860)

<font style="color:rgba(0, 0, 0, 0.95);">  
</font><font style="color:rgba(0, 0, 0, 0.95);">在研发阶段，需要提供基座接入能力，模块创建能力，更重要的是模块的本地快速构建与联调能力；在运维阶段，提供快速的模块发布能力，在模块发布基础上提供 A/B 测试和秒级扩缩容能力；在运行阶段，提供模块的可靠性能力，模块可观测、流量精细化控制、调度和伸缩能力。</font>

<font style="color:rgba(0, 0, 0, 0.95);"></font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695182125970-f9529014-0386-4922-b8eb-5d0c82a7e5d8.png#clientId=u9014394b-3a6a-4&from=paste&height=370&id=uf365ffd8&originHeight=740&originWidth=2096&originalType=binary&ratio=2&rotation=0&showTitle=false&size=242246&status=done&style=none&taskId=uf07de18d-931e-4ffd-9540-d4be10de3e7&title=&width=1048)<font style="color:rgba(0, 0, 0, 0.95);">  
</font><font style="color:rgba(0, 0, 0, 0.95);">组件视图</font>

<font style="color:rgba(0, 0, 0, 0.95);">在整个平台里，需要个组件：</font>

1. <font style="color:rgba(0, 0, 0, 0.95);">研发工具 Arkctl, 开发者使用 Arkctl 完成模块快速创建、快速联调测试等能力</font>
2. <font style="color:rgba(0, 0, 0, 0.95);">运行组件 SOFAArk，提供基于 ClassLoader 的多模块运行的环境</font>
3. <font style="color:rgba(0, 0, 0, 0.95);">Arklet 和 Runtime 组件，提供模块运维、模块生命周期管理，多模块环境适配</font>
4. <font style="color:rgba(0, 0, 0, 0.95);">控制面组件 ModuleController</font>
    1. <font style="color:rgba(0, 0, 0, 0.95);">ModuleDeployment 提供模块发布与运维能力</font>
    2. <font style="color:rgba(0, 0, 0, 0.95);">ModuleScheduler 提供模块调度能力</font>
    3. <font style="color:rgba(0, 0, 0, 0.95);">ModuleScaler 提供模块伸缩能力</font>

在这些组件基础上提供了从研发到运维到运行时的完善的配套能力。

### 多集群，弹性与调度
### ![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701404774158-9b98bfea-680c-4207-9385-5274b838266a.png)


将线上应用根据场景隔离出不同机器组，不同机器组上可以安装不同模块，给不同业务提供不同的 QOS 保障。同时可以单独划分出 buffer 机器组，当业务机器组机器不够时，可以快速从 Buffer 机器组里调度出机器，安装上相应的模块，完成 10 秒级的扩容。

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701404586909-ce2aa71c-a3a3-4d0b-831e-d48b2a241b02.png)

由于模块的启动速度在 10 秒级，所以在弹性上也能做到与服务更加同频，伸缩更加实时，这里看到应用实例数曲线与流量曲线基本处于一致的状态。



### 可观测、高可靠、排障等能力
模块化运维调度作为在 pod 上一层的模型，与现有配套设施会有些不同，所以需要针对配套设施完成可观测、监控排障等能力适配。

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701402418146-d48db144-5162-4187-beff-86012a61231b.png)

### <font style="color:black;">AB 测试/灰度</font>
一个模块更新时，可以同时存在多个版本，通过引流规则完成灰度测试，或者 A/B 测试。

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701402447957-961e18fe-65bd-4b3c-ba92-17b83c0f9667.png)



### <font style="color:black;">流量隔离与精细化路由</font>
<font style="color:black;">在上述中已经将应用粒度从机器分组，代码分组（模块）上做了更细粒度的划分，这里我们进一步将流量也进一步细粒度划分。一组模块和对应所在的机器组可以分配不同的流量单元，可以根据请求的不同参数，精细化路由到对应的流量分组中。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701402510492-3a5b591f-e849-4a04-828f-390defdb287a.png)



当前完整能力已经开源 [https://github.com/sofastack/sofa-serverless](https://github.com/sofastack/sofa-serverless)，并提供 2 分钟上手试用视频教程，[https://sofaserverless.gitee.io/docs/video-training/](https://sofaserverless.gitee.io/docs/video-training/) 欢迎试用，也期待与大家一起建设社区。当前已接入 15+ 企业列表



![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701426083430-a311a783-0d3f-4763-a0eb-22b2946038b1.png)

如果你也想帮助企业完成降本增效，欢迎咨询探讨。

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701402889393-7438ac03-47d2-4015-8bfe-d6f085e6ab71.png) ![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1701402909610-02f40205-3539-4d79-b078-9d87e41edcf9.png)

## 未来展望
在未来，SOFAServerless 将<font style="color:rgb(51, 51, 51);">持续不断地</font>探索<font style="color:rgba(0, 0, 0, 0.9);">，根据业务痛点为各行各业提出 Serverless 的解决方案。</font>感谢各位开源共建开发者一直以来的支持与付出！排名不分先后

<font style="color:rgb(51, 51, 51);">@</font>[QilingZhang](https://github.com/QilingZhang)<font style="color:rgb(51, 51, 51);"> @</font>[lvjing2](https://github.com/lvjing2)<font style="color:rgb(51, 51, 51);"> @</font>[glmapper](https://github.com/glmapper)<font style="color:rgb(51, 51, 51);"> @</font>[yuanyuancin](https://github.com/yuanyuancin)<font style="color:rgb(51, 51, 51);"> @</font>[lylingzhen](https://github.com/lylingzhen)<font style="color:rgb(51, 51, 51);"> @</font>[yuanyuan2021](https://github.com/yuanyuan2021)<font style="color:rgb(51, 51, 51);"> @</font>[straybirdzls](https://github.com/straybirdzls)<font style="color:rgb(51, 51, 51);"> @</font>[caojie09](https://github.com/caojie09)<font style="color:rgb(51, 51, 51);"> @</font>[gaosaroma](https://github.com/gaosaroma)<font style="color:rgb(51, 51, 51);"> @</font>[khotyn](https://github.com/khotyn)<font style="color:rgb(51, 51, 51);"> @</font>[FlyAbner](https://github.com/FlyAbner)<font style="color:rgb(51, 51, 51);"> @</font>[zjulbj](https://github.com/zjulbj)<font style="color:rgb(51, 51, 51);"> @</font>[hustchaya](https://github.com/hustchaya)<font style="color:rgb(51, 51, 51);"> @</font>[sususama](https://github.com/sususama)<font style="color:rgb(51, 51, 51);"> @</font>[alaneuler](https://github.com/alaneuler)<font style="color:rgb(51, 51, 51);"> @</font>[compasty](https://github.com/compasty)<font style="color:rgb(51, 51, 51);"> @</font>[wuqian0808](https://github.com/wuqian0808)<font style="color:rgb(51, 51, 51);"> @</font>[nobodyiam](https://github.com/nobodyiam)<font style="color:rgb(51, 51, 51);"> @</font>[ujjboy](https://github.com/ujjboy)<font style="color:rgb(51, 51, 51);"> @</font>[JoeKerouac](https://github.com/JoeKerouac)<font style="color:rgb(51, 51, 51);"> @</font>[Duan-0916](https://github.com/Duan-0916)<font style="color:rgb(51, 51, 51);"> @</font>[poocood](https://github.com/poocood)<font style="color:rgb(51, 51, 51);"> @</font>[qixiaobo](https://github.com/qixiaobo)<font style="color:rgb(51, 51, 51);"> @</font>[lbj1104026847](https://github.com/lbj1104026847)<font style="color:rgb(51, 51, 51);"> @</font>[zhushikun](https://github.com/zhushikun)<font style="color:rgb(51, 51, 51);"> @</font>[xingcici](https://github.com/xingcici)<font style="color:rgb(51, 51, 51);"> @</font>[Lunarscave](https://github.com/Lunarscave)<font style="color:rgb(51, 51, 51);"> @</font>[HzjNeverStop](https://github.com/HzjNeverStop)<font style="color:rgb(51, 51, 51);"> @</font>[AiWu4Damon](https://github.com/AiWu4Damon)<font style="color:rgb(51, 51, 51);"> @</font>[vchangpengfei](https://github.com/vchangpengfei)<font style="color:rgb(51, 51, 51);"> @</font>[HuangDayu](https://github.com/HuangDayu)<font style="color:rgb(51, 51, 51);"> @</font>[shenchao45](https://github.com/shenchao45)<font style="color:rgb(51, 51, 51);"> @</font>[DalianRollingKing](https://github.com/DalianRollingKing)<font style="color:rgb(51, 51, 51);"> @</font>[lanicc](https://github.com/lanicc)<font style="color:rgb(51, 51, 51);"> @</font>[azhsmesos](https://github.com/azhsmesos)<font style="color:rgb(51, 51, 51);"> @</font>[KangZhiDong](https://github.com/KangZhiDong)<font style="color:rgb(51, 51, 51);"> @</font>[suntao4019](https://github.com/suntao4019)<font style="color:rgb(51, 51, 51);"> @</font>[huangyunbin](https://github.com/huangyunbin)<font style="color:rgb(51, 51, 51);"> @</font>[jiangyunpeng](https://github.com/jiangyunpeng)<font style="color:rgb(51, 51, 51);"> @</font>[michalyao](https://github.com/michalyao)<font style="color:rgb(51, 51, 51);"> @</font>[rootsongjc](https://github.com/rootsongjc)<font style="color:rgb(51, 51, 51);"> @</font>[liu-657667](https://github.com/liu-657667)<font style="color:rgb(51, 51, 51);"> @</font>[CodeNoobKing](https://github.com/CodeNoobKing)<font style="color:rgb(51, 51, 51);"> @</font>[Charlie17Li](https://github.com/Charlie17Li)<font style="color:rgb(51, 51, 51);"> @</font>[TomorJM](https://github.com/TomorJM)<font style="color:rgb(51, 51, 51);"> @</font>[gongjiu](https://github.com/gongjiu)<font style="color:rgb(51, 51, 51);"> @</font>[gold300jin](https://github.com/gold300jin)<font style="color:rgb(51, 51, 51);"> @</font>[nmcmd](https://github.com/nmcmd)

**<font style="color:#117CEE;">12 月 16 日 KCD 2023 深圳站（插入文章链接）</font>**，期待和各位技术爱好者面对面交流探讨！

我将分享**《云原生微服务的下一站，蚂蚁 SOFAServerless 新架构的探索与实践》**，<font style="color:rgba(0, 0, 0, 0.9);">活动现场还将设立展台进行</font><font style="color:#117CEE;"> </font>**<font style="color:#117CEE;">SOFAServerless 能力演示、操作流程互动展示</font>**<font style="color:rgba(0, 0, 0, 0.9);">。</font><font style="color:rgb(51, 51, 51);">如果你对 SOFAServerless 感兴趣，欢迎前来参与体验～</font>

体验可以点击：[https://sofaserverless.gitee.io/docs/tutorials/trial_step_by_step/](https://sofaserverless.gitee.io/docs/tutorials/trial_step_by_step/)

如有问题可在 SOFAServerless GitHub 上及时提交 issue 互动交流～




<font style="color:rgba(0, 0, 0, 0.95);"></font>
