---
title: 为什么margin：auto会居中?
tags: frontend
categories: 原理
---

#### 根本原因
auto值的计算是基于可用空间的，也就是只有块级非替换元素才会有剩余空间，这也就解释了为什么有些行内元素使用position:absolute;也会居中，因为absolute和float会悄悄的把元素编成block元素呀

如果是块级元素，他会填充父级所有的可用空间，如图：

![gif](https://foxdaxian.github.io/assets/05_qunaer/block.png)

如果是替换元素的话，就不会产生这样的效果，如图：
![gif](https://foxdaxian.github.io/assets/05_qunaer/img.png)

大概的原理是，如果块级非内联元素定位为非当前内容流，比如absolute，那么该元素不会和普通内容流一起渲染，如果设置
```css
x{
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
}
```
那么该元素会填充父级所有的可用空间，当然他没有```width```、```height```优先级高，所以没有宽高会充满，有宽高会水平垂直居中