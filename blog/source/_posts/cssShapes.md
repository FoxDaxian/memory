---
title: css shapes
tags: frontend
categories: 介绍
---

css shapes可以让css来生成一些几何图形，这种特性可以和float布局结合，让文字不再仅仅只能围绕在元素的矩形元素周围，还可以围绕在圆形、椭圆形、多边形甚至png图片内所示形状的元素盒子周围。
![12](https://foxdaxian.github.io/assets/03_css_shapes/cssshapes_featured-1.jpg)
实现css shapes的主要属性是`shape-outside`，这个属性定义了文字可以围绕的一些几何形状。

常用的一些属性：
- circle(): 圆形
- ellipse(): 椭圆形
- inset(): 类似阴影的inset
- olygon(): 自定义多边形

**被应用的元素必须是float的，并且应该具有宽高属性**

具体细节请参考这篇文章：[参考链接](https://tympanus.net/codrops/2018/11/29/an-introduction-to-css-shapes/?utm_source=CSS-Weekly&utm_campaign=Issue-342&utm_medium=web)


* * *


附注：文中提及的[CSS Shapes Editor](https://chrome.google.com/webstore/detail/css-shapes-editor/nenndldnbcncjmeacmnondmkkfedmgmp?hl=en-US)的使用方法：
1. 随便https或者https协议服务网站
2. 打开开发者工具
3. 选择一个你想要的形状元素，选择`Styles`那一行的`shapes`的选项卡
![12](https://foxdaxian.github.io/assets/03_css_shapes/shapes_editor.png)
4. 点击`+`号，页面会出现编辑样式得虚线框和操作提示
5. 进行拖拽，平移，旋转操作
6. 被选中元素会出现ploygon相关属性，复制下来即可使用

