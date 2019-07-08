---
title: webp
tags: frontend
categories: 原理
---

2010年，谷歌发布了一种新的图片格式：[WebP](https://developers.google.com/speed/webp/)，它是可以当初png和jpg的一种替代格式，在不损失图片质量的前提下，会尽可能的减少文件大小.

#### WebP有哪些优点呢？
由于WebP提供的性能和优点，它简直完美。不像其他屙屎，WebP有无损和有损两个压缩方式，还支持动画和透明度

|   | WebP | png | jpg | gif |
| ------ | ------ | ------ | ----- | ----- |
| Lossy compression | √ | √  | √  | x  |
| Lossless compression | √ | √ | √  | √  |
| Transparency | √ | √ | x | √  |
| Animation | √ | x | x | √  |

即使有这么多的优点，webp依然提供比其他格式更小的文件大小，在[这个测试中](https://developers.google.com/speed/webp/docs/c_study#results)，web有损图片比jpg格式要小30%，无损图片要比png格式小25。

#### 怎么转换到webp格式呢
1. 在线工具
	1. [squoosh](https://squoosh.app/)
	2. [online-convert.com](https://image.online-convert.com/convert-to-webp)
2. 命令行工具
	[cwebp](https://www.npmjs.com/package/cwebp)是一个不错的工具，可以转换图片到webp格式
    ```javascript
    // cwebp -q [图片大小] [输入] -o [输出]
    cwebp -q 75 image.png -o image.webp
    ```
3. node工具
	[imagemin](https://github.com/imagemin/imagemin)，还有它的插件[imagemin-webp](https://github.com/imagemin/imagemin-webp)，是一个转换图片到webp格式的工具
    下面这个例子将所有的png和jpg图片转成webp
    ```javascript
    /* convert-to-webp.js */

    const imagemin = require("imagemin");
    const webp = require("imagemin-webp");

    imagemin(["*.png", "*.jpg"], "images", {
      use: [
        webp({ quality: 75})
      ]
    });
    ```
4. sketch
	可以使用sketch导出webp格式的图片


#### 当下环境如何在开发中使用webp格式呢
可以先查看一下webp的[兼容性](https://caniuse.com/#search=webp)
可以看到，当今各端支持率已高达70%多，虽然webp有这么多的有点，但是也不能直接使用，而不提供一种向后兼容的方式，否则在不支持的浏览器中，用户体验会很差。
我们可以使用HTML5中的<picture>元素，该标签允许为单张图片提供多个源。想下面这样
```javascript
<picture>
    <source type="image/webp" srcset="image.webp">
    <source type="image/jpeg" srcset="image.jpg">
    <img src="image.jpg" alt="My Image">
</picture>
```

source标签作为不同的源，img标签作为当浏览器不支持时的一种回退方案，当前<picture>支持率高达85%以上

除了html的办法，当然还有其他方案，比如：
```javascript
var isSupportWebp = !![].map && document.createElement('canvas').toDataURL('image/webp').indexOf('data:image/webp') == 0;

console.log(isSupportWebp);
```
或者
```javascript
window.isSupportWebp = false;//是否支持
(function() {
    var img = new Image(); 
    function getResult(event) {
        //如果进入加载且图片宽度为1(通过图片宽度值判断图片是否可以显示)
        window.isSupportWebp = event && event.type === 'load' ? img.width == 1 : false;
    }
    img.onerror = getResult;
    img.onload = getResult;
    // 如果可以在那么则支持
    img.src = 'data:image/webp;base64,UklGRiQAAABXRUJQVlA4IBgAAAAwAQCdASoBAAEAAwA0JaQAA3AA/vuUAAA=';
```

[webp官网](https://developers.google.com/speed/webp/)