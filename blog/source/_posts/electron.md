---
title:  electron简析
tags: frontend
categories: 原理
---

### 什么是electron
electron是一个可以用HTML、CSS、JS来构建桌面应用的程序，并且具有跨平台型。

### electron的重要性
一般来说，桌面应用在不同的系统上需要不同的原生语言。electron，可以让你的桌面应用兼容大多数流行平台。

### 组成
electron组合chromium和nodejs，并且为原生操作系统暴露出一些自定义的api，比如吊起文件dialog，通知栏，等等
![alt](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/12_electron/components.png)

### 开发体验
开发electron就像构建一个网页一样，你可以无缝使用nodejs。并且你不需要考虑兼容性。


### 进程
- 主进程：package.json中的main对应的文件执行后是主进程
- 渲染进程：每个electron页面都运行着自己的进程，称为渲染进程

###  联系和区别
- 主进程，一般来说是main.js。这是整个electron app的入口，控制着app的生命周期，从打开到关闭，控制着打开原生元素，和创建新的渲染进程。并且集成nodejs api


![alt](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/12_electron/main.png)

- 渲染进程：说白了渲染进程就是app的浏览器窗口，不像主进程，这可以有多个，并且相互独立。也可以被隐藏，一般来说命名为index.html，html中有着通用文件特性，但有一点，你可以使用node api。

![alt](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/12_electron/renderer.png)

主进程使用browserWindow实例创建页面（node层使用browserWindow创建实例），每个browserWindow实例都在自己的渲染进程里运行页面。当一个实例被销毁后，相应的渲染进程也会被终止。（页面层使用remote-本质是eventEmmiter）
主进程管理所有页面和与之对应的渲染进程。每个渲染进程都是相互独立的，并且只关心他们自己的页面。
几乎所有与底层API进行交互的逻辑都需要在主进程调用。

### 联想一波
electron的渲染进程就像谷歌或者其他浏览器中的每个tab，每个web页面就是一个渲染进程
如果你关闭所有的tab，chrome仍然没有关闭，这就像主进程，你可以打开新的窗口或退出整个app

![alt](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/12_electron/like-this.png)


### 通讯方式 [参考](https://imweb.io/topic/5b13a663d4c96b9b1b4c4e9c)
1. ipcmain 主进程使用 ipcrender 渲染进程使用
2. remote 渲染进程使用

本质上是事件的监听订阅。


### 开发方案
#### 非单页
- electron
- hbs（等模板）
使用hbs渲染模板，根据机器语言不同的页面风格。使用hbs打包到目标目录，electron直接loadurl。简单高效。

#### 单页
- electron
- mvvm框架
- store
- router
语法是大家所熟悉，不需要再去熟悉模板语言，开发效率高，目录结构清晰，单页用户体验好，不涉及seo问题，但是不支持服务端渲染，除非只做一个架子，但是还得考虑请求时间，毕竟electron是直接加载本地文件。
建议还是开发单窗口应用，比如网易云音乐。

### 两个问题
1. 为什么browserWindow在渲染进程中找不到
  渲染进程本身就是一个browserWindow实例，有些api是通用的有些不是，要是想在渲染进程中使用browserWindow需要引入remote模块
2. 想在渲染进程使用主进程的api
  需要使用通信，让主进程代劳



[参考1](http://nodejh.com/posts/electron-quick-start/)
[参考2](http://jlord.us/essential-electron/)
