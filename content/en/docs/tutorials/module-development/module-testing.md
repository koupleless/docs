---
title: Module Testing
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Testing
weight: 400
draft: true
---

### Getting Help
You can view the help for all external HTTP interfaces exposed by Arklet:
```shell
curl -X POST -H "Content-Type: application/json" http://127.0.0.1:1238/help 
```
Request Body Example:
```json
{}
```
Response Example:
```json
{
    "code":"SUCCESS",
    "data":[
        {
            "desc":"query all ark biz(including master biz)",
            "id":"queryAllBiz"
        },
        {
            "desc":"list all supported commands",
            "id":"help"
        },
        {
            "desc":"uninstall one ark biz",
            "id":"uninstallBiz"
        },
        {
            "desc":"switch one ark biz",
            "id":"switchBiz"
        },
        {
            "desc":"install one ark biz",
            "id":"installBiz"
        }
    ]
}
```

## How to Build Locally without Changing the Module Version Number
Add the following Maven profile, and build the module locally using the command mvn clean package -Plocal.
```xml
<profile>
    <id>local</id>
    <build>
        <plugins>
            <plugin>
                <groupId>com.alipay.sofa</groupId>
                <artifactId>sofa-ark-maven-plugin</artifactId>
                <configuration>
                    <finalName>${project.artifactId}-${project.version}</finalName>
                    <bizVersion>${project.version}</bizVersion>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```

## Unit Testing
Modules support writing and executing unit tests using standard JUnit4 and TestNG.

<br/>
<br/>
