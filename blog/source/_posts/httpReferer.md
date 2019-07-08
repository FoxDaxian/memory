---
title:  http referer
tags: frontend
categories: 原理
---

referer指的是请求来自哪里，值为url格式，大白话说，就是你是从哪里访问的当前网站。
常用来检测方可来自于哪，比如防盗链、恶意请求等等
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190628193343.png)

### 防盗链
打个比方，如果用户请求一个资源，比如下载链接地址，那么下载链接地址的referer就指向你的来源地址，这时候你就可以通过referer判断是否来自你的域下，进行安全权限检测，对来源进行限制。不过如果你直接输入url打开的下载链接地址，那么referer就不存在或者为空，你又可以做其他的骚操作。
总之referer用好，会让你的网站更安全、也更灵活.