---
title:  rem移动端适配
tags: frontend
categories: 原理
---

移动端适配，老生常谈的问题，这次再谈一次。
闲话少说，直奔正题。

### 一些像素概念
1. 物理像素：即实际的每一个物理像素，也就是移动设备上每一个物理显示单元（点）
2. 设备逻辑像素（css中的px）：可以理解为一个虚拟的相对的显示块，与物理像素有着一定的比例关系，也就是下面的设备像素比
3. 设备像素比（dpr）：= 物理像素 / 设备独立像素(px)
如果dpr为1的话，那么1px = 1物理像素，x轴y轴加起来就是1![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190618215518.png)
如果dpr为2的话，那么1px = 2物理像素，x轴y轴加起来就是4
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190618215524.png)
以此类推
在js中可以通过`window.devicePixelRatio`获取当前设备的dpr。

这里说明一下，无论dpr多大，1px的大小通常来说是一致的，这也就意味着，随着dpr的增大，物理像素点会越来越小，这样才能容纳更多的物理像素，才能更高清，更retina
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190618215817.gif)

-----

说完基本概念，来说一下几个问题：

#### retina屏图片模糊
首先普及一下位图像素：一个位图像素是图片的最小数据单元，每一个单元都包含具体的显示信息（色彩，透明度，位置等等）
那为什么在dpr高的retina屏上反而会模糊呢？看图~
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190618221043.jpg)
在1dpr的屏幕上，位图像素和物理像素一一对应没什么问题，但是在retina屏上，由于一个px由4个甚至更多的物理像素组成，并且单个位图像素不能进一步分割，所以会出现就近取色的情况，如果取色不均，那么就会导致图片模糊。
对于这种情况，只能采用@2x、@3x这样的倍图来适配高清展示，这样侧向说明了为什么照着iphone6做的ui稿不是375，而是750的问题。
虽然这样在dpr为1的屏幕上会导致1个物理像素上有4个位图像素，但是这种情况的取色算法更优，影响不大，不做讨论。

#### 1px的粗细问题
由于1px的实际大小是一样的，只是里面的物理像素数量不同，所以如果直接写1px是没问题的，不会出现粗细不同的情况，但是这样一来retina的优势也rem的作用也就没了，其实还是dpr的问题，dpr为1，那么1px就是一个物理像素，但是在retina中。1px实际可能有4、9个物理像素，ui想要的其实是1个物理像素，而不是1px，不过由于不是素所有的手机都能适配0.x，所以曲线救国，采用`scale`缩放或者设置meta都可以
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190618223230.jpg)

-----

### viewport

#### 三个概念：
1. layout viewport
2. visual viewport
3. ideal viewport

##### layout viewport
最开始，pc上的页面是无法再移动端正常显示的，因为屏幕太小，会挤作一团，所以就有了viewport的概念，又称`布局视口`（虚拟视口），这个视口大小接近于pc，大部分都是980px。

##### visual viewport
有了`布局视口`，还缺一个承载它的真是视口，也就是移动设备的可视区域-`视觉视口`（物理视口）,这个尺寸随着设备的不同也有不同。这样在`视觉视口`中创建了一个`布局视口`，类似`overscroll:scroll;`这样，可以通过滚动拖拽、缩放扩大进行较好的访问体验。

##### ideal viewport
像上面的体验在早些年可能比较多，但是近几年几乎很少了，还是归咎于用户体验，所以，我们还需要一个视口-`理想视口`（同样是虚拟视口），不过这个理想视口的大小是等于`布局视口`的，这样用户就能得到更好的浏览体验。

------

### 一个特性
viewport有六种可以设置的常用属性：
1. width：定义layout viewport的宽度，如果不设置，大部分情况下默认是980
2. height：非常用
3. initial-scale：可以以某个比例将页面缩放\放大，你也可以用它来设置`ideal viewport`：
  ```html
    <meta name='viewport' content='initial-scale=1' />
  ```
4. maximum-scale：限制最大放大比例
5. minimum-scale：限制最小缩小比例
6. user-scalable：是否允许用户放大\缩小页面，默认为yes

------

### rem适配方案
先说原理，通过meta修正1px对应的物理像素数量，在根据统一的设计稿来生成html上的动态font-size，根据dpr构造字体等误差较大的样式的mixin
```javascript
// 第一版:
function initRem() {
  const meta = document.querySelector('meta[name="viewport"]');;
  const html = document.documentElement;
  const cliW = html.clientWidth;
  const dpr = window.devicePixelRatio || 1;
  meta.setAttribute('name', 'viewport');
  meta.setAttribute(
      'content',
      `width=${cliW * dpr}, initial-scale=${1 /
          dpr} ,maximum-scale=${1 / dpr}, minimum-scale=${1 /
          dpr},user-scalable=no`
  );
  html.setAttribute('data-dpr', dpr);
  // 这样计算的好处是，你可以直接用ui的px/100得到的就是rem大小，方便快捷，无需mixin
  html.style.fontSize = 10 / 75 * cliW * dpr + 'px';
}
initRem();
window.onresize = window.onorientationchange = initRem();

```
对于引入的第三方ui组件，需要使用px2rem转换工具去做整体转换，比如[postcss-pxtorem](https://github.com/cuth/postcss-pxtorem)




### 参考链接
[移动端高清，多屏适配](http://www.html-js.com/article/Mobile-terminal-H5-mobile-terminal-HD-multi-screen-adaptation-scheme%203041)
[viewport详解](http://helloweb.wang/qianduankaifa/3549.html)
[完全理解px dpr dpi dip](http://www.ayqy.net/blog/%E5%AE%8C%E5%85%A8%E7%90%86%E8%A7%A3px-dpr-dpi-dip/)