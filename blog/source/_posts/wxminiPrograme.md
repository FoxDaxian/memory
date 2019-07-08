---
title:  微信小程序简析
tags: frontend
categories: 原理
---

#### 流程图
![demo](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/11_wx/naotu.png)

#### 优化点：

最直接的方式的控制小程序的大小，比如制定代码规范和通用组件的控制
分包： 包括分包、分包预加载、独立分包
某些请求进行前置，比如某些量级很小的数据、用户必定会点击的页面的数据预请求
利用微信提供的缓存 storage
避免白屏，将一些静态或极少更新的状态传递给下一页，并结合骨架图进行页面的框架展示
控制setdata的使用次数和传达数据大小，建议一定少于64kb
减少WXML中非必须节点的使用
合理使用onpagescroll



#### 分包介绍
本质上是按需加载，分为主包和分包，主包会运行app等公共方法和加载一些公共资源。当进入某个分包页面的时候，才会按需下载并执行展示出来。

目前小程序所有分包大小不超过8M

单个分包/主包不能超过2M

#### 主要应用
小程序首次启动的下载和加载时间大大缩短

#### demo

![demo](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/11_wx/demo.png)

#### 参数解释：
pages：主包

subpackages：分包

root：分包根目录 → 分包所在的目录
name：分包别名 →  预下载的时候可以引用该别名，方便
pages：相对于root的分包路径，可包含多个
preloadRule：开启分包预下载，key - value形式，key代表某个页面，比如上图中的index主页面，当进入该页面的时候，需要预下载哪些分包

packages：需要下载的分包，数组形式
network：可以指定只有在某些网络下才会下载，默认是wifi


关于独立分包：独立分支只需要在subpackages中的添加 independent: true 即可，注意不要依赖主包和其他分包的内容，可能无法获取全局数据，因为主包可能未加载，不过可以在独立主包中定义一个全局数据，等加载主要的时候会与主包和全局数据进行合并，