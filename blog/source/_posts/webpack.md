---
title: webpack - 优化阻塞渲染的css
tags: frontend
categories: 原理
---

```
随着浏览器的日新月异，网页的性能和速度越来越好，并且对于用户体验来说也越来越重要。
现在有很多优化页面的办法，比如：静态资源的合并和压缩，code splitting，DNS预读取等等。
本文介绍的是另一种优化方法：首屏阻塞css优化

```
##### 原理：
首先我们了解一下页面的基本渲染流程（[参考](https://juejin.im/post/5b88ddca6fb9a019c7717096)）：
webkit渲染过程：
![webkit渲染过程](https://user-gold-cdn.xitu.io/2018/9/3/1659db14e773f9cc?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)
Gecko渲染过程:
![gecko渲染过程](https://user-gold-cdn.xitu.io/2018/9/3/1659db14e7df8a8f?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)
那么，为什么要做这种优化呢？上面的流程图就是原因：首先解析html生成dom树，同时解析css生成css树，之后结合两者生成渲染树，然后渲染到屏幕上。不但如此，如果css后面有其他javascript，并且css加载时间过长，也会阻塞后面的js执行，因为js可能会操作dom节点或者css样式，所以需要等待render树完成。那么，如果我们能优化css，那么就能大大减少页面渲染出来的时间，从而提升pv，增加黏性，走向编码巅峰。。。

* * *


##### 怎么做呢：
目前我知道的比较实用的办法是webpack集成[critical](https://github.com/addyosmani/critical)，critical是一个提取关键css，内联到html中，并且使用preload和noscript兼容加载非关键css的工具。
那么，我们开门见山，直接从webpack配置开始：
```javascript
const HtmlWebpackPlugin = require('html-webpack-plugin'); // 创建html来服务你的资源
const MiniCssExtractPlugin = require('mini-css-extract-plugin'); // 提取css到分离的文件，需要webpack4
const HtmlCriticalWebpackPlugin = require('html-critical-webpack-plugin'); // 集成critical的html-webpack-plugin版本
const path = require('path');

// 用于设置Chromium，因为Chromium使用npm或者yarn经常有问题
process.env['PUPPETEER_EXECUTABLE_PATH'] =
    '你电脑中的Chromium地址';

module.exports = {
    mode: 'none',
    module: {
        rules: [
            {
                test: /\.css$/,
                // 使用MiniCssExtractPlugin.loader代替style-loader
                use: [MiniCssExtractPlugin.loader, 'css-loader']
            },
            {
                test: /\.js$/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env']
                    }
                }
            }
        ]
    },
    plugins: [
        new HtmlWebpackPlugin({ template: './index.html' }),
        new MiniCssExtractPlugin({}),
        new HtmlCriticalWebpackPlugin({
            base: path.resolve(__dirname, 'dist'),
            src: 'index.html',
            dest: 'index.html',
            inline: true,
            minify: true,
            extract: true,
            width: 375,
            height: 565,
            // 确保调用打包后的JS文件
            penthouse: {
                blockJSRequests: false
            }
        })
    ]
};
```
然后是html文件：
```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="ie=edge" />
        <title>Document</title>
    </head>
    <body>
        <div class="div"></div>
		<h2>hello world</h2>
		<div class="mask">这是一个弹窗</div>
    </body>
</html>
```
接着是css文件：
```css
.div {
    width: 200px;
    height: 100vh;
    background-color: red;
}
h2 {
    color: blue;
}
.mask {
    width: 500px;
    height: 500px;
    display: none;
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    margin: auto;
	background-color: yellowgreen;
}

```
运行webpack后，查看打包后的html文件：
```html
// 省略...
<style>
    .div {
        width: 200px;
        height: 100vh;
        background-color: red;
    }
    .mask {
        width: 500px;
        height: 500px;
        display: none;
        position: absolute;
        top: 0;
        left: 0;
        bottom: 0;
        right: 0;
        margin: auto;
        background-color: #9acd32;
    }
</style>
<link
    href="main.80dc2a9c.css"
    rel="preload"
    as="style"
    onload="this.onload=null;this.rel='stylesheet'"
/>
<noscript><link href="main.80dc2a9c.css" rel="stylesheet"/></noscript>
// 省略...
```
#### [代码仓库在此，点击fork进行实战练习](https://github.com/FoxDaxian/webpack4)

可以看到，h2标签的css样式没有出现在内联style里，而是出现在main.[hash].css中，因为它不再所设置首屏范围内，这就是所谓的首屏css优化。

##### 相关内容
在上面打包后的html文件里，我们看到了有一个link内有`rel="preload" as="style"`字段，紧接着下面就有一个`noscript`标签，这两个是做什么的呢？
- `rel="preload" as="style"`： 用于进行页面预加载，`rel="preload"`通知浏览器开始获取非关键CSS以供之后用。其关键在于，`preload`不阻塞渲染，无论资源是否加载完成，浏览器都会接着绘制页面。并且，搭配as使用，可以指定将要预加载内容的类型，可以让浏览器：
    1. 更精确地优化资源加载优先级。
    2. 匹配未来的加载需求，在适当的情况下，重复利用同一资源。
    3. 为资源应用正确的内容安全策略。
    4. 为资源设置正确的 Accept 请求头。
- `noscript`：如果页面上的脚本类型不受支持或者当前在浏览器中关闭了脚本，则在HTML `<noscript>` 元素中定义脚本未被执行时的替代内容。换句话说，就是当浏览器不支持js脚本或者用户主动关闭脚本，那么就会展示`noscript`里的内容，而[critical](https://github.com/addyosmani/critical)则是利用这一点做了向后兼容

##### 总结
利用[critical](https://github.com/addyosmani/critical)可以大大提高页面渲染速度，但是由于其使用puppeteer，所以下载安装比较麻烦，上面的webpack中使用设置env中puppeteer位置的方法解决了这一问题。

文中如若有不对的地方，还望之处，共同交流。
