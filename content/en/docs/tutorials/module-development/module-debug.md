---
title: Module Testing
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Testing
weight: 400
---

## Local Debugging
You can start the base locally or remotely, then deploy the module locally or remotely using the client Arklet's exposed HTTP interface, and set breakpoints in the module code for local or remote debugging.<br /> The Arklet HTTP interface mainly provides the following capabilities:

1. Deploying and uninstalling modules.
2. Querying all deployed module information.
3. Querying various system and business metrics.

### Deploying Modules
```shell
curl -X POST -H "Content-Type: application/json" http://127.0.0.1:1238/installBiz 
```
Request Body Example: 
```json
{
    "bizName": "test",
    "bizVersion": "1.0.0",
    // local path should start with file://, alse support remote url which can be downloaded
    "bizUrl": "file:///Users/jaimezhang/workspace/github/sofa-ark-dynamic-guides/dynamic-provider/target/dynamic-provider-1.0.0-ark-biz.jar"
}
```
Successful Deployment Response Example:
```json
{
  "code":"SUCCESS",
  "data":{
    "bizInfos":[
      {
        "bizName":"dynamic-provider",
        "bizState":"ACTIVATED",
        "bizVersion":"1.0.0",
        "declaredMode":true,
        "identity":"dynamic-provider:1.0.0",
        "mainClass":"io.sofastack.dynamic.provider.ProviderApplication",
        "priority":100,
        "webContextPath":"provider"
      }
    ],
    "code":"SUCCESS",
    "message":"Install Biz: dynamic-provider:1.0.0 success, cost: 1092 ms, started at: 16:07:47,769"
  }
}
```
Failed Deployment Response Example:
```json
{
  "code":"FAILED",
  "data":{
    "code":"REPEAT_BIZ",
    "message":"Biz: dynamic-provider:1.0.0 has been installed or registered."
  }
}
```

### Uninstalling Modules
```shell
curl -X POST -H "Content-Type: application/json" http://127.0.0.1:1238/uninstallBiz 
```
Request Body Example:
```json
{
    "bizName":"dynamic-provider",
    "bizVersion":"1.0.0"
}
```
Successful Uninstallation Response Example:
```json
{
  "code":"SUCCESS"
}
```
Failed Uninstallation Response Example:
```json
{
  "code":"FAILED",
  "data":{
    "code":"NOT_FOUND_BIZ",
    "message":"Uninstall biz: test:1.0.0 not found."
  }
}
```

### Querying Modules
```shell
curl -X POST -H "Content-Type: application/json" http://127.0.0.1:1238/queryAllBiz 
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
      "bizName":"dynamic-provider",
      "bizState":"ACTIVATED",
      "bizVersion":"1.0.0",
      "mainClass":"io.sofastack.dynamic.provider.ProviderApplication",
      "webContextPath":"provider"
    },
    {
      "bizName":"stock-mng",
      "bizState":"ACTIVATED",
      "bizVersion":"1.0.0",
      "mainClass":"embed main",
      "webContextPath":"/"
    }
  ]
}
```

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
