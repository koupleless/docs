---
title: Semi-Automated Split Tool User Guide
date: 2024-05-13T10:28:32+08:00
weight: 1
---
# Background
When extracting the Koupleless module from a large monolithic SpringBoot application, users face high learning and trial-and-error costs. Users need to analyze from the service entrance which classes to split into the module, then modify the module according to the Koupleless module coding method. 

To reduce learning and trial-and-error costs, KouplelessIDE plugin provides semi-automated splitting capabilities: analyzing dependencies and automating modifications.
# Quick Start
## 1. Install Plugin

Install the KouplelessIDE plugin from the IDEA plugin marketplace:

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/install-idea-plugin.jpg">
</div>

## 2. Configure IDEA

Ensure that IDEA -> Preferences -> Builder -> Compiler's “User-local build process heap size” is at least 4096

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/change-heap-size.jpg">
</div>

## 3. Select Module

Step one: Open the SpringBoot application that needs splitting with IDEA, on the right panel open ServerlessSplit

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/open-right-plugin.jpg">
</div>

Step two: Select the splitting method as needed, click “Confirm and Collapse”

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/commit-description.jpg">
</div>

## 4. Dependency Analysis

During splitting, it is necessary to analyze the dependencies between classes and Beans. The plugin allows for the visualization of dependency relationships, and it is up to the business side to decide whether a class should be split into a module.

Step one: Click to activate

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/activate.jpg">
</div>

Step two: Drag the service entry to the module, supporting cross-level dragging

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/drag.jpg">
</div>

Dragging result:

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/drag-result.jpg">
</div>

Step three: Drag the “Files for Analysis”, click to analyse dependencies, view **Class/Bean dependencies** as shown below:

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/drag-to-analyse.jpg">
</div>

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/click-analyse-dependency.jpg">
</div>

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/analyse-dependency-result.jpg">
</div>

Where the icons represent:

| Icon    |Meaning| Required Action                                                                                                                  |
|-------|----------------|-------------------------------------------------------------------------------------------------------------------------------|
| ![in-module-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/in-module-icon.jpg) |Already in module| No action required                                                                                                            |
| ![can-move-to-module.jpg](/docs/contribution-guidelines/split-module-tool/imgs/can-move-to-module.jpg) |Can be moved to module| Drag to module ![can-move-to-module-action.jpg](/docs/contribution-guidelines/split-module-tool/imgs/can-move-to-module-action.jpg) |
| ![recommend-to-analyse-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/recommend-to-analyse-icon.jpg) |Recommended to analyze dependency| Drag to analyze  ![recommend-to-analyse-action.jpg](/docs/contribution-guidelines/split-module-tool/imgs/recommend-to-analyse-action.jpg) |
| ![warning-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/warning-icon.jpg) |Should not be moved to module| Hover to view dependency details ![warning-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/warning-icon.jpg) |

Step four: Follow the prompts, through dragging, stepwise analyze, import the necessary module files

## 5. Detection
Click on "Preliminary Detection", which will prompt the user about possible issues with this split, and which middleware might require manual intervention.

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/check.jpg">
</div>

Open the lower sidebar in KouplelessIDE to view the prompts.

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/check-result.jpg">
</div>

## 6. Splitting

Click to start the splitting.

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/split.jpg">
</div>

Open the lower sidebar in KouplelessIDE to view the prompts.

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/split-result.jpg">
</div>
