---
title: 4.3.5 Module Local Development and Debugging  
date: 2024-01-25T10:28:32+08:00  
description: Local development and debugging of the Koupleless module  
weight: 400
---

## Arkctl Tool Installation
The Arkctl module installation mainly provides automated packaging and deployment capabilities, including invoking the `mvn` command to automatically build the module as a JAR file and calling the API interface provided by Arklet for completion of deployment. The installation method for Arkctl can refer to the documentation: [arkctl Installation](../build_and_deploy.md) in the *Local Environment Development Verification* section.

### Installation Method 1: Using the Golang Toolchain
1. Download the corresponding version of Golang from the [Golang official website](https://go.dev/); the version must be above 1.21.
2. Execute the command `go install github.com/koupleless/arkctl@v0.2.1` to install the Arkctl tool.

### Installation Method 2: Downloading Binary Files
1. Download Arkctl based on the actual operating system. [Download Arkctl](https://github.com/koupleless/arkctl/releases).
2. Unzip the corresponding binary file and place it in a directory that is included in the system's PATH variable.
3. After the base and module have been modified and the base has been started, the Arkctl tool can be used to quickly complete the build and deployment of the module into the base.  
   &nbsp;
#### How to Find the PATH Value on Linux/Mac?
Execute in the terminal:
```shell  
echo $PATH  
# Choose a directory and place arkctl in that directory  
```  

#### How to Find the PATH Value on Windows?
Press Windows + R, type `cmd`, and then press Enter to open the command prompt. In the command prompt window, enter the following command and press Enter:
```shell  
echo %PATH%  
```  

Note: In the Windows environment, if Windows Defender is enabled, it may falsely report issues when downloading binaries through the browser, as shown below:
<div style="text-align: center;">  
    <img align="center" width="600px" src="/docs/tutorials/imgs/error-hint.png" />  
</div>  
<br/>  
You can refer to the [Go official documentation](https://go.dev/doc/faq#virus) for the reason behind the error. This error can be ignored; feel free to download.  
> Since Arkctl deployment is actually completed by calling the API, if you prefer not to use the command-line tool, you can directly use the Arklet [API interface](/docs/contribution-guidelines/arklet/architecture) to complete the deployment operation. We also provide a telnet method for module deployment; [detailed instructions can be found here](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-telnet/).  

## Local Quick Deployment
You can use the Arkctl tool to quickly build and deploy modules, improving the efficiency of local debugging and development.

### Scenario 1: Building a Module JAR and Deploying to a Locally Running Base.
Preparation:
1. Start a base locally.
2. Open a module project repository.  
   Execute the command:
```shell  
# This needs to be executed in the root directory of the repository.  
# For example, if it is a Maven project, execute it in the directory where the root pom.xml is located.  
arkctl deploy  
```  
Once the command completes, it is successfully deployed, and the user can debug and validate the relevant module functionalities.

### Scenario 2: Deploying a Locally Built JAR to a Locally Running Base.
Preparation:
1. Start a base locally.
2. Prepare a built JAR file.  
   Execute the command:
```shell  
arkctl deploy /path/to/your/pre/built/bundle-biz.jar  
```  
Once the command completes, it is successfully deployed, and the user can debug and validate the relevant module functionalities.

### Scenario 3: Deploying a Locally Unbuilt JAR to a Locally Running Base.
Preparation:
1. Start a base locally.  
   Execute the command:
```shell  
arkctl deploy ./path/to/your/biz/  
```  
Note: This command is applicable if the module can be built independently (e.g., if commands like `mvn package` can be successfully executed in the biz directory), the command will automatically build the module and deploy it to the base.

### Scenario 4: Building and Deploying Submodule JARs in a Multi-Module Maven Project from the Root.
Preparation:
1. Start a base locally.
2. Open a multi-module Maven project repository.  
   Execute the command:
```shell  
# This needs to be executed in the root directory of the repository.  
# For example, if it is a Maven project, execute it in the directory where the root pom.xml is located.  
arkctl deploy --sub ./path/to/your/sub/module  
```  
Once the command completes, it is successfully deployed, and the user can debug and validate the relevant module functionalities.

### Scenario 5: Building a Module JAR and Deploying to a Remote Running K8s Base.
Preparation:
1. Ensure that a base pod is already running remotely.
2. Open a module project repository.
3. You must have a K8s certificate with exec permissions and the kubectl command-line tool available locally.  
   Execute the command:
```shell  
# This needs to be executed in the root directory of the repository.  
# For example, if it is a Maven project, execute it in the directory where the root pom.xml is located.  
arkctl deploy --pod {namespace}/{podName}  
```  
Once the command completes, it is successfully deployed, and the user can debug and validate the relevant module functionalities.

### Scenario 6: How to Use This Command More Quickly
You can create a Shell Script in IDEA, set the running directory, and then enter the corresponding Arkctl command as shown in the image below.
<div style="text-align: center;">  
    <img align="center" width="800" src="/img/arkctl-shell-starter.png">  
</div>  

## Local Module Debugging
### Module and Base in the Same IDEA Project
Since the IDEA project can see the module code, debugging the module is no different from normal debugging. Just set breakpoints in the module code and start the base in debug mode.
<div style="text-align: center;">  
    <img align="center" width="900" src="/img/local_debug_base_and_biz_in_same_idea.png">  
</div>  

### Module and Base in Different IDEA Projects
1. Add the debug configuration to the base startup parameters: `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000`, then start the base.
2. Add remote JVM debug to the module, setting host to localhost: `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000`.
3. Set breakpoints in the module.
4. After installing the module, you can begin debugging.

## Checking Deployment Status
### Scenario 1: Querying Modules Already Deployed in the Current Base.
Preparation:
1. Start a base locally.  
   Execute the command:
```shell  
arkctl status  
```  

### Scenario 2: Querying Modules Already Deployed in the Remote K8s Environment Base.
Preparation:
1. Start a base in the remote K8s environment.
2. Ensure you have Kube certificates and the necessary permissions locally.  
   Execute the command:
```shell  
arkctl status --pod {namespace}/{name}  
```  

## Viewing Runtime Module Status and Information Using Arthas
### Retrieve All Biz Information
```shell  
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100  
```  
For example:  
<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961335431-516ae20b-16c8-48f3-8241-43e414a9f988.png#clientId=ue9573504-0f91-4&from=paste&height=165&id=uf5756bf0&originHeight=330&originWidth=1792&originalType=binary&ratio=2&rotation=0&showTitle=false&size=75826&status=done&style=none&taskId=ue37b95ce-9ff0-4e2b-8c76-c4ac6d3c852&title=&width=896)

### Retrieve Specific Biz Information
```shell  
# Please replace ${bizName}  
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100 | grep ${bizName} -A 4  
```  
For example:  
<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961580662-719aa62b-735d-4443-8208-11f16dc74613.png#clientId=ue9573504-0f91-4&from=paste&height=87&id=u99973d00&originHeight=174&originWidth=1970&originalType=binary&ratio=2&rotation=0&showTitle=false&size=46592&status=done&style=none&taskId=ud87e82e9-b349-4c47-b6c2-a441f096de0&title=&width=985)

### Retrieve Biz Information Corresponding to a Specific BizClassLoader
```shell  
# Please replace ${BizClassLoaderHashCode}  
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100 | grep ${BizClassLoaderHashCode} -B 1 -A 3  
```  
For example:  
<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961557440-865e8681-e5be-4e09-81da-ba1e93d6650f.png#clientId=ue9573504-0f91-4&from=paste&height=92&id=ue02744a4&originHeight=184&originWidth=2086&originalType=binary&ratio=2&rotation=0&showTitle=false&size=51618&status=done&style=none&taskId=u9423d30f-c7f2-45ca-baaa-70f1a358b7d&title=&width=1043)  
