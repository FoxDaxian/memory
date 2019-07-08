---
title: 骨架屏
tags: frontend
categories: 原理
---

骨架屏

对于前端来说，最重要的莫过于用户体验了，这次我们聊一聊骨架屏 - Skeleton Screen

我们平常对于需要请求加载的内容，可能用的比较多的是loading动画，比如在内容区域放一个菊花图，当请求结束，并且render tree构造完成后，将菊花图移除，展示用户想看的内容。虽然这种方式没啥缺点，但是现在更多的网站开始使用骨架屏代替，因为它能带过来更好的用户体验。
我们看几个例子：

facebook
![facebook](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/facebook.jpeg)

jira
![jira](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/jira.png)

linkedin
![linkedin](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/linkedin.jpeg)

slack
![slack](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/slack.png)

上图展示中，我们可以看到每个site从骨架图到真实内容的一个变化。如果你细心一点你会发现，不同site对于骨架图的block位置是不一致的：
- facebook将用户固定的头像，author，日期和一小部分文字作为骨架主体
- jira则是标题和logo对应的很整齐
- linkedin可以说完全没有对齐，而是使用一种更加的展示骨架布局
- slack则是使用混合的loading方式，有骨架图也有旋转圆，不仅如此，slack并没有全部使用同一种灰色值，不同的block的颜色代表的该区域的字体颜色，这又是一种切换顺滑度的提升。

不过他们都有一个共同点，就是采用简约的方式布局，我们可以以此为例，创造出独一无二的风格，来提高用户体验和加强品牌的风格，我想这会比一个loading logo带来更好的效果。

上面简单的介绍了一下骨架图，接下来我们来说一下具体实现吧。

 优先我们实现一个简单的带有loading效果的骨架结构：
 
 ```html
 <!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
    <style>
        *{
            margin: 0;
            padding: 0;
        }
        @keyframes loading {
            0% {
                background-position: -400px 0
            }

            100% {
                background-position: 400px 0
            }
        }

        .box1 {
            position: absolute;
            margin: 0 auto;
            left: 50%;
            margin-left: -400px;
            top: 0;
            width: 800px;
            height: 60px;
            background-color: blue;
            background-image: linear-gradient(to right, #eeeeee 8%, #dddddd 18%, #eeeeee 33%);
            animation-duration: 1s;
            animation-iteration-count: infinite;
            animation-name: loading;
            animation-timing-function: linear;
            transition: 0.3s;
        }
        .bgMasker {
            background-color: #fff;
        }

        .line1 {
            background-color: #fff;
            height: 20px;
            position: absolute;
            right: 0;
            top: 0;
            left: 60px;
        }

        .line2 {
            background-color: #fff;
            height: 20px;
            position: absolute;
            right: 700px;
            top: 20px;
            left: 60px;
        }

        .line3 {
            background-color: #fff;
            height: 20px;
            position: absolute;
            left: 400px;
            right: 0;
            top: 20px;
        }

        .line4 {
            background-color: #fff;
            height: 20px;
            top: 40px;
            position: absolute;
            left: 60px;
            right: 500px;
        }

        .line5 {
            background-color: #fff;
            height: 20px;
            position: absolute;
            left: 600px;
            right: 0;
            top: 40px;
        }
    </style>
</head>

<body>
    <!-- 骨架 -->
    <div class="box1">
        <div class="bgMasker line1"></div>
        <div class="bgMasker line2"></div>
        <div class="bgMasker line3"></div>
        <div class="bgMasker line4"></div>
        <div class="bgMasker line5"></div>
    </div>
</body>

</html>
 ```
 有一点需要说一下，由于我们使用的是渐变色的动画效果，所以我们的布局有一点的变化，我们采用的是整体加上背景色，然后内容使用定位和left,right来构成block的方式，具体内容请参考上面的代码
 
效果如下：

![block](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/block.gif)

然后我们做一下简单的骨架图和内容的切换，这里就不贴代码了，切换有很多种实现方式，不固定思维。我这边做了两种，一种是直接切换，一种是淡入的切换，可以简单参考一下：

![block](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/static.gif)

![block](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/09_skeleton%20_screen/animate.gif)



----

[饿了么骨架图方案](https://github.com/Jocs/jocs.github.io/issues/22)
1. ssr，请求后用puppeteer插入script生成当前页的骨架图，或者build的时候直接生成（个人觉得应该是这种），然后插入到根元素内，然后数据加载后直接隐藏并展示真实数据
2. 分块，对于图片，将采用最小大小尺寸 1 * 1的纯色gif图，然后进行拉伸
3. 数据请求后对骨架进行隐藏等操作