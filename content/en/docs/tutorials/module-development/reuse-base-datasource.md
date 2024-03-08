---
title: Reusing Base Data Source
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Reusing Base Data Source
weight: 600
---

## Recommendation
It is highly recommended to use the approach outlined in this document to **reuse the base data source** within the module whenever possible. Failing to do so may result in repeated creation and consumption of data source connections during module deployments, leading to slower module publishing and operations, as well as increased memory usage.<br/>

## SpringBoot Solution
Simply create a MybatisConfig class in the module's code. This way, the transaction template is reused from the base, and only the Mybatis SqlSessionFactoryBean needs to be newly created. Refer to the demo: /koupleless/samples/springboot-samples/db/mybatis/biz1

Use `SpringBeanFinder.getBaseBean` to obtain the base Bean object, and then register it as the module's Bean: 

```java

@Configuration
@MapperScan(basePackages = "com.alipay.sofa.biz1.mapper", sqlSessionFactoryRef = "mysqlSqlFactory")
@EnableTransactionManagement
public class MybatisConfig {

    // Note: Do not initialize a base DataSource, as it will be destroyed when the module is uninstalled. 
    // However, resources such as transactionManager, transactionTemplate, and mysqlSqlFactory can be safely destroyed.

    @Bean(name = "transactionManager")
    public PlatformTransactionManager platformTransactionManager() {
        return (PlatformTransactionManager) getBaseBean("transactionManager");
    }

    @Bean(name = "transactionTemplate")
    public TransactionTemplate transactionTemplate() {
        return (TransactionTemplate) getBaseBean("transactionTemplate");
    }

    @Bean(name = "mysqlSqlFactory")
    public SqlSessionFactoryBean mysqlSqlFactory() throws IOException {
        // The data source cannot be declared as a bean in the module's Spring context, as it will be closed when the module is uninstalled.

        DataSource dataSource = (DataSource) getBaseBean("dataSource");
        SqlSessionFactoryBean mysqlSqlFactory = new SqlSessionFactoryBean();
        mysqlSqlFactory.setDataSource(dataSource);
        mysqlSqlFactory.setMapperLocations(new PathMatchingResourcePatternResolver()
                .getResources("classpath:mappers/*.xml"));
        return mysqlSqlFactory;
    }
}

```

## SOFABoot Solution
If the SOFABoot base does not enable multi-bundle (there is no MANIFEST.MF file in the Package), the solution is identical to the SpringBoot solution mentioned above. If there is a MANIFEST.MF file, you need to call BaseAppUtils.getBeanOfBundle to obtain the base Bean, where **BASE_DAL_BUNDLE_NAME** is the`Module-Name` in the MANIFEST.MF file:<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2022/png/38696/1661758587977-7a499d0d-d5ca-4a68-9925-fa7258679d9b.png#clientId=ue6b6f4dc-5527-4&errorMessage=unknown%20error&from=paste&height=458&id=u531b3c3e&originHeight=916&originWidth=2042&originalType=binary&ratio=1&rotation=0&showTitle=false&size=383535&status=error&style=none&taskId=ua403e261-49af-4d10-99e6-12edf669677&title=&width=1021)
```java

@Configuration
@MapperScan(basePackages = "com.alipay.koupleless.dal.dao", sqlSessionFactoryRef = "mysqlSqlFactory")
@EnableTransactionManagement
public class MybatisConfig {

    // Note: Do not initialize a base DataSource, as it will be destroyed when the module is uninstalled. 
    // However, resources such as transactionManager, transactionTemplate, and mysqlSqlFactory can be safely destroyed

    private static final String BASE_DAL_BUNDLE_NAME = "com.alipay.koupleless.dal"

    @Bean(name = "transactionManager")
    public PlatformTransactionManager platformTransactionManager() {
        return (PlatformTransactionManager) BaseAppUtils.getBeanOfBundle("transactionManager",BASE_DAL_BUNDLE_NAME);
    }

    @Bean(name = "transactionTemplate")
    public TransactionTemplate transactionTemplate() {
        return (TransactionTemplate) BaseAppUtils.getBeanOfBundle("transactionTemplate",BASE_DAL_BUNDLE_NAME);
    }

    @Bean(name = "mysqlSqlFactory")
    public SqlSessionFactoryBean mysqlSqlFactory() throws IOException {
        // The data source cannot be declared as a bean in the module's Spring context, as it will be closed when the module is uninstalled.
        ZdalDataSource dataSource = (ZdalDataSource) BaseAppUtils.getBeanOfBundle("dataSource",BASE_DAL_BUNDLE_NAME);
        SqlSessionFactoryBean mysqlSqlFactory = new SqlSessionFactoryBean();
        mysqlSqlFactory.setDataSource(dataSource);
        mysqlSqlFactory.setMapperLocations(new PathMatchingResourcePatternResolver()
                .getResources("classpath:mapper/*.xml"));
        return mysqlSqlFactory;
    }
}

```

<br/>
<br/>
