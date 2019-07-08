---
title:  RGB <=> HSL
tags: frontend
categories: 原理
---

首先我们需要了解两种颜色模式：
- RGB
- HSL

### RGB
顾名思义，red，green，blue的首字母缩写。RGB是添加剂颜色系统，意味着哪个色值高，最终颜色会更趋向与哪个。如果色值相等，那么趋向于灰色，为0则是黑色，255则是白色。
一种替换方案是你可以用十六进制表示，也就是说将各个色值从十进制转换成十六进制。比如：

`rgb(50, 100, 0)` => `#326400`

不过，RGB很难阅读，或者直观的知道最终的颜色，所以又有了HSL，一种更直观的颜色表示形式。

### HSL
同样，HSL也是首字母缩写：hue，saturation，light。
- hue：色相 - 色彩的基本属性，单位是角度，所以，我们可以用一个圆环表示出所有的色相
![12](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/10_about_color_mode/hue.jpg)
- saturation：饱和度 - 色彩的纯度，值越高，色彩越纯越浓，越低，色彩越灰越淡。
![12](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/10_about_color_mode/saturation.jpg)
- light：亮度 - 色彩的明暗程度，值越高，月白，直到变成白色，反之变成黑色。该值优先级最高，可以直接影响前两者。。
![12](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/10_about_color_mode/light.jpg)


### 颜色模式之间的转换
RGB和HSL都可以将颜色分解成多个属性，要想颜色语法转换，我们需要计算他们的属性。
除了hue，其他值都可以用百分比表示，下面的函数中，这些百分比将有小数表示。
不过我们不会深入数学公式，只会简单的了解一下，然后转换成js代码。

### RGB 转 HSl
```javascript
    function rgbToHsl(r, g, b) {
            r /= 255, g /= 255, b /= 255;
            var max = Math.max(r, g, b), min = Math.min(r, g, b);
            var h, s, l = (max + min) / 2;

            if (max == min) {
                h = s = 0; // achromatic
            } else {
                var d = max - min;
                s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
                switch (max) {
                    case r: h = (g - b) / d + (g < b ? 6 : 0); break;
                    case g: h = (b - r) / d + 2; break;
                    case b: h = (r - g) / d + 4; break;
                }
                h /= 6;
            }

            return [h, s, l];
        }
```

### HSL 转 RGB

```javascript
    function hslToRgb(h, s, l) {
            var r, g, b;

            if (s == 0) {
                r = g = b = l; // achromatic
            } else {
                var hue2rgb = function hue2rgb(p, q, t) {
                    if (t < 0) t += 1;
                    if (t > 1) t -= 1;
                    if (t < 1 / 6) return p + (q - p) * 6 * t;
                    if (t < 1 / 2) return q;
                    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
                    return p;
                }

                var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
                var p = 2 * l - q;
                r = hue2rgb(p, q, h + 1 / 3);
                g = hue2rgb(p, q, h);
                b = hue2rgb(p, q, h - 1 / 3);
            }

            return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
        }
```

这样我们就可在RGB和HSl之间进行任意转换，有什么奇怪的需求也就没问题啦
比如这个[工具](https://codepen.io/AdamGiese/full/989988044f3b8cf6403e3c60f56dd612)


### 参考链接
- [学会调色，从理解HSL面板开始](https://zhuanlan.zhihu.com/p/25576030)
- [JS HEX十六进制与RGB, HSL颜色的相互转换](https://www.zhangxinxu.com/wordpress/2010/03/javascript-hex-rgb-hsl-color-convert/)