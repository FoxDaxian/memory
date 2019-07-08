---
title: 图片高斯模糊
tags: frontend
categories: 原理
---

图片加载一个老生常谈的问题，由于最近工作中经常有h5宣传页的需求，所以也看了一些方案

- medium网站上提高用户体验的图片高斯模糊加载
```html
<!-- figure，代表一段独立的内容，常用语引用图片、插图、表格、代码段等等 -->
<figure>
    <!-- 图片容器 -->
    <div class="aspectRatioPlaceholder is-locked" style="max-width: 383px; max-height: 326px;">
        <!-- 放置reflow的占位元素，style上的padding-bottom是通过接下来相邻div上写好的图片宽高计算而来，可通过十字相乘得到高度百分比 -->
        <div class="aspectRatioPlaceholder-fill" style="padding-bottom: 85.1%;"></div>
        <!-- 实际的图片信息，包括图片id和图片宽高 -->
        <div data-image-id="1*MZY5pNF7fgOarY-J2fNuHQ.png" data-width="383" data-height="326">
            <!-- 可以看到png后缀后有一个query: ?q=20，这个是缩略图的质量，猜想是二十分之一？ -->
            <img src="https://cdn-images-1.medium.com/freeze/max/60/1*MZY5pNF7fgOarY-J2fNuHQ.png?q=20" crossorigin="anonymous">
            <!-- 获取上面的图片，渲染到canvas中，canvas宽高为实际的图片宽高，并添加高斯模糊效果，以获取较好的用户体验 -->
            <canvas></canvas>
            <!-- 真正的图片 -->
            <img src="https://cdn-images-1.medium.com/max/1600/1*MZY5pNF7fgOarY-J2fNuHQ.png">
            <!-- 向后兼容，在不支持js脚本或者支持js脚本，但认为禁止js脚本的浏览器中可以被识别 -->
            <noscript>
                <img  src="https://cdn-images-1.medium.com/max/1600/1*MZY5pNF7fgOarY-J2fNuHQ.png">
            </noscript>
        </div>
    </div>
</figure>
```

1. 诺，可以先看一遍上面HTML代码中的注释，加上一点自己的理解，估计你能理解个大概
2. 首先，准备一个真正需要展示给用户的图片和一个可以通过query来生成不同质量的缩略图的服务，哈哈
3. 然后先加载质量很小很小的缩略图，然后通过div上设置的图片真正宽高，渲染到canvas中，并添加合适的高斯模糊效果
4. 然后可以通过network中看到，等小图加载完毕后，再去加载原图，保证页面第一版加载更快，缩短执行js的时间
5. 原图加载完毕后，显示原图，隐藏之前的canvas
6. 对了，还有一个placeholder元素，这个是为了放置切换时造成的reflow，这个需要js动态设置图片容器的宽高，然后通过比例设置placeholder元素的padding-bottom
7. 元素上使用了自定义属性，一个通用的、赋予html数据属性的特性，解决了自定义属性混乱无管理的情况，css选择器也可以选中它哦

