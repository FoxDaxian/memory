---
title: 浏览器内核
tags: frontend
categories: 原理
---

浏览器是用户的窗口，而这个窗口则是前端工程师们的舞台。
据统计，目前常见的浏览器有：
- 谷歌
- 火狐
- ie、edge
- opera
- safari
- uc
- qq
- 搜狗
- 360
- 百度

[浏览器占比](https://zh.wikipedia.org/wiki/%E7%BD%91%E9%A1%B5%E6%B5%8F%E8%A7%88%E5%99%A8#/media/File:Usage_share_of_web_browsers_(Source_StatCounter).svg)


对于前端来说，浏览器是一台转换代码的机器，将代码转换成用户可以看到的界面，但是，如何解释和执行代码却因为浏览器的种类繁多而千差万别。而决定如何解释和执行代码的就是浏览器内核(排版引擎 | 浏览器引擎  |  页面渲染引擎  | 渲染引擎)。

![浏览器结构](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/07_browser_webview/browser-construct.png)

1. 用户界面
    你能看到的，包括工具栏、导航栏、书签菜单等等
2. 浏览器引擎
    是一个可嵌入的组件，为渲染引擎提供高级接口。
    可以加载一个指定的URI，支持和历史记录相关的操作
    查询和修改渲染引擎
3. 渲染引擎
    显示请求的内容，比如解析html、css，并将解析后的render tree渲染到浏览器中
4. 网络
    用于网络调用，具有独立性，可在不同平台使用
5. js解释器
    用来解释执行js代码，由于安全问题，浏览器引擎和渲染引擎可能会禁止掉某些js功能。
6. xml解析器
    将xml文档解析成文档对象模型树，xml解析器是浏览器结构中复用最多的子系统之一，几乎所有的浏览器都复用现有的xml解析器，而不是从头开始
7. 显示后端
    显示后端提供绘图和窗口原语，包括用户界面控件集合、字体集合
8. 数据持久层
    数据持久层将会话相关的各种数据存储在硬盘上。比如书签，工具栏设置，比如cookies，安全证书，localstore

一般来说，浏览器只有一个内核，但是为了ie，发明了双核浏览器，大部分都是```Trident```+```Webkit```，因为ie的历史，导致中国大陆很多大量银行网上服务仅支持ie浏览器，所以开发了这种急速+兼容的双核浏览器。
webkit是苹果研发的，chrome起初使用webkit，后来另起分支blink，并且越来越好
[视频介绍](https://www.youtube.com/watch?v=DQPqZPTIESc&t=8s)

接着说说移动端的浏览器内核。

首先移动端不像pc，网站都是前端开发的。移动端目前来说常用的有下面几种：

|  |  native  |  rn、wx、flutter  | hybrid | webapp |
| -- | -- | -- | -- | -- |
| 跨平台 | 复杂 | 容易 | 容易 | 容易 |
| 版本更新 | 慢 | 快 | 快 | 快 |
| 性能和体验 | 最高 | 高 | 一般 | 一般 |
| 学习和开发成本 | 很大 | 大 | 一般 | 一般 |

这里拿和浏览器内核有关的```hybrid```和```webapp```来说，其余感兴趣的在做深入了解。

介绍移动端内核之前，简单介绍一下hybrid和webapp，hybrid是native的webview容器中的webapp，webapp就是普通的页面。正因为有这个webview的关系，导致hybrid自诞生以来就比webapp多了一个初始化webview容器的这个损耗，所以才会有后面的rn，flutter等等。简单的解释下这个过程：

在浏览器中，我们输入地址时，浏览器就可以加载页面。

![浏览器结构](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/07_browser_webview/borwser.png)

在客户端中，首先需要花费时间初始化webview，才能加载页面。所以如果webview没有加载完毕，用户可能就会看到白屏影响体验。

![浏览器结构](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/07_browser_webview/webview.png)

当然，也不是没有优化方案。比如：
- 使用单例模式去初始化webview，这样只有在第一次的时候回慢一些，之后就没问题了，缺点就是内存消耗和怎么处理同时存在多个webview
- 将网络请求相关交给native去做，也就是初始化webview和网络请求并行的方案，即客户端代理数据请求
- dns采用和客户端api相同的域名，类似dns预解析



我们都知道手机有两大主类：Android和IOS。不过总的来说大部分都在使用webkit或者类webkit内核。

webapp：
- ios safari 使用webkit内核
- android4.4之前使用webkit，4.4之后切换到了chromium（基于一个webkit的分支blink，是chrome的先行版）


webview(webkit内核+js引擎)：
- ios8之前使用uiwebview，之后使用wkwebview
- 安卓常用的有：

安卓4.4之前的webkit内核和4.4之后的blink内核：

|  |  webkit  |  chromium  |  备注  |
| -- | -- | -- | -- |
| html5test  |  278  |  434  | http://html5test.com/  |
| 远程调试  |  不支持  |  支持  |  安卓4.4以上支持 |
| 内存占用  |  小  |  大  |  相差20-30M左右  |
| WebAudio  |  不支持  |  支持  |  Android 5.0及以上支持  |
| WebGL  |  不支持  |  支持  |  Android 5.0及以上支持  |
| WebRTC  |  不支持  |  支持  |  Android 5.0及以上支持  |


由于低版本安卓的有很多兼容的问题，所以一般会采用三方webview，常见的：

| 类别 | 介绍 | 性能 | 特点 | html5test |
| -- | -- | -- | -- | -- |
| 系统自带webview | 安卓默认 | 一般 | 没有额外jar负担，原生api，不过兼容性差 | 一般 |
| X5 webview | 腾讯出品 | 一般 | 兼容性好，可信度高，不过工作量会增大，并且不支持Cordova | 良好 |
| crosswalk | 国外为安卓提供的一个融合webkit的方案 | 优 | 无兼容性，性能问题，支持Cordova，不过体积大 | 较佳 |


两个优化方案。
### 首先是webp

3w方法：
1. 什么是webp
2. webp是怎么做的
3. 如何使用webp




#### 什么是webp
webp是一种可以有损或无损的压缩图片的方法，能够适用于有很多图片资源的网站上，它还供你选择压缩程度，让你自由控制图片大小和图片质量，在不影响质量的前提下，大约可以节省30%的体积，详细见：[官网比较](https://developers.google.com/speed/webp/docs/c_study)
#### webp是怎么做的
我们知道，在大部分网站中，图片占用了60%左右的页面资源，这非常影响整个渲染时间，而且，在移动端页面大小更是重要，这关系到流量和电池寿命。那webp是怎么做的呢？

1. 有损压缩
有损webp基于VP8视频编码方法来压缩图像数据，基础步骤类似于JPEG压缩,流程如下图所示，红色部门代表与JPEG不同的部分。
![alt](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/07_browser_webview/webpProcess.jpg)
    1. 格式转换
    若压缩前图像数据为RGB格式，则需要先将格式转换成YUV格式，Y表示亮度，UV表示色度，之所以这么做是因为人类的眼睛对色度敏感度比亮度低，所以可通过减少色度来减少图片占用空间。比如每四个相邻像素点采用一对UV值
    2. 分割宏块
    将数据分割成4 * 4或8 * 8 或 16 * 16的宏块
    3. 预测编码
    预测编码的原理是基于前面编码好的宏块，预测多余的动作颜色等信息，属于帧内预测（帧内预测是一个物理学术语，指的是H.264采用的一种新技术）
        - H_PRED（horizontal prediction）使用宏块左边的一列（简称L）来填充剩余列
        - V_PRED（vertical prediction） 使用宏块上面的一行（简称A）来填充剩余行
        - DC_PRED（DC prediction） 使用L和A的所有像素的平均值填充宏块
        - TM_PRED（TrueMotion prediction） 使用渐进的方式
        下面展示了不同帧内预测的模式
        ![alt](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/07_browser_webview/compression-intra_modes.png)
    4. 接下来通过FDCT（正向离散余弦变换）处理残差。让变换后的数据低频部分分布在数据块左上方，高频集中在右下方以实现更高效的压缩
    5. 最后将结果量化并进行熵编码，webp使用布尔算数编码作为熵编码方式，直接把输入的消息编码为一个满足(0.0 <= n <= 1.0)的小数n

2. 无损压缩
无损webp采用了预测变换、颜色变换、减去绿色变换、彩色缓存编码、LZ77反响参考等不同技术来处理图像，之后对变换图像数据和参数进行熵编码，有兴趣的自行了解。

#### 如何使用webp
首先是支持度：
pc上谷歌、火狐、edge、opera支持度很好，换句话说使用blink内核的都没啥问题。
android4以上 ios支持过一段时间，后来移除了，web端支持尚好，不过ie和safari完全不支持
详见[wiki](https://en.wikipedia.org/wiki/WebP#Support)
其实，目前有很多垫片已经几乎可以做到常用环境全支持webp了，比如
- [安卓4.0以下支持](https://github.com/alexey-pelykh/webp-android-backport)
- [ios支持](https://github.com/carsonmcdonald/WebP-iOS-example)
不过这些是native那边做的，那我们前端怎么做呢？
- 服务端
    1. 通过accetp头信息进行协商
    发送accept字段非常常见，这个字段说明浏览器可以接受的内容类型，如果浏览器发送一个*image/webp*，那么服务端就知道浏览器支持webp格式，然后直接使用ok

- 客户端 
    1. [Modernizr](https://github.com/Modernizr/Modernizr)
    Modernizr是一个js库，可以非常方便的查看你的浏览器H5/Css3的支持度，你可以查看下面这些字段：Modernizr.webp, Modernizr.webp.lossless, Modernizr.webp.alpha and Modernizr.webp.animation
    2. 使用H5的**picture**元素
    picture允许你放置多个source和一个回退的img，就算webp不支持，也会显示回退方案
    3. 使用js
    这是尝试解码一个非常小的不同版本webp图片
```javascript
//  check_webp_feature:
//  'feature' can be one of 'lossy', 'lossless', 'alpha' or 'animation'.
//  'callback(feature, result)' will be passed back the detection result (in an asynchronous way!)
function check_webp_feature(feature, callback) {
    var kTestImages = {
        lossy: "UklGRiIAAABXRUJQVlA4IBYAAAAwAQCdASoBAAEADsD+JaQAA3AAAAAA",
        lossless: "UklGRhoAAABXRUJQVlA4TA0AAAAvAAAAEAcQERGIiP4HAA==",
        alpha: "UklGRkoAAABXRUJQVlA4WAoAAAAQAAAAAAAAAAAAQUxQSAwAAAARBxAR/Q9ERP8DAABWUDggGAAAABQBAJ0BKgEAAQAAAP4AAA3AAP7mtQAAAA==",
        animation: "UklGRlIAAABXRUJQVlA4WAoAAAASAAAAAAAAAAAAQU5JTQYAAAD/////AABBTk1GJgAAAAAAAAAAAAAAAAAAAGQAAABWUDhMDQAAAC8AAAAQBxAREYiI/gcA"
    };
    var img = new Image();
    img.onload = function () {
        var result = (img.width > 0) && (img.height > 0);
        callback(feature, result);
    };
    img.onerror = function () {
        callback(feature, false);
    };
    img.src = "data:image/webp;base64," + kTestImages[feature];
}
```


### 再说说variable fonts

之前就有了解，直接抛链接了: [variable fonts](https://github.com/FoxDaxian/memory/issues/4)
[支持程度](https://v-fonts.com/support/)



##### 参考链接
[现代浏览器工作原理](http://chuquan.me/2018/01/21/browser-architecture-overview/)
[浏览器内核](http://www.eyee21.com/category/%E6%B5%8F%E8%A7%88%E5%99%A8)
[前端解读webview](https://www.cnblogs.com/pqjwyn/p/7120342.html)
[美团webview性能、体验分析和优化](https://tech.meituan.com/2017/06/09/webviewperf.html)
[主流浏览器内核介绍](http://web.jobbole.com/84826/)
[安卓webview选择对比](https://lingenliu.com/2016/09/03/something-about-android-webview/)
[webp官网](https://developers.google.com/speed/webp/)
[webp原理](https://tech.upyun.com/article/253/%E9%83%BD%E8%AF%B4%20WebP%20%E5%8E%89%E5%AE%B3%EF%BC%8C%E7%A9%B6%E7%AB%9F%E5%8E%89%E5%AE%B3%E5%9C%A8%E5%93%AA%E9%87%8C%EF%BC%9F%20.html)
