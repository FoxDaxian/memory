---
title: variable fonts - 更小更灵活的字体
tags: frontend
categories: 原理
---

## [原文链接](https://github.com/FoxDaxian/memory/issues/4)

variable fonts（下文中vf为缩写）是数字时代制作的字体技术，用更小的文件大小在web上提供更丰富的排版，但是一项新的技术往往伴随着新的挑战和复杂未知的情况。不过，我们要拥抱技术，那么怎么才能使用它呢？

让我们从以下几个问题去学习一下variable fonts。

- [什么是variable fonts?](#part_one)
- [variable fonts能做什么](#part_two)
- [拉伸或者扭曲字体会不会有不好的效果和影响？](#part_three)
- [variable fonts有哪些优点？](#part_four)
- [怎么在web上使用variable fonts？](#part_five)
- [有哪些潜在的缺陷需要注意？](#part_six)
- [variable fonts何时才会相对成熟？](#part_seven)


### <a id="part_one">什么是variable fonts?</a>
有人解释它为一个存在多种字体格式单字体文件。一般来说，字体的不同格式，比如斜体、粗细、拉伸存储在分开的单个文件内，而现在，你可以存储多种字体格式在一个openType可变字体文件内，正因为如此，这个vf文件相对来说体积会更小。

![资源](https://foxdaxian.github.io/assets/02_variableFonts/static-font-files-vs-variable-font-files.png)
<p align="center">多个静态字体文件可以被存储到一个vf文件</p>

因为只有一种排版的`轮廓点`，所以文件体积很小。这些点决定了文字的直接表现。修改`轮廓点`的位置意味着能够动态的在浏览器里改变文字的样子。这使得在半粗体和粗体之间的转换成为可能。向下面这样：

![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-fonts-interpolation.gif)
<p align="center">修改vf字体的例子，这些`轮廓点`的数量没有变化，仅仅是位置发生了改变</p>

在各种`轴(将一个可修改范围抽象化为一条(x)轴，或者说横坐标)`上可以以非常小的数值进行改变，比如`粗细轴`，一点点的修改就会发生很大的风格变化，像`regular`和`font-weight: 700`之间有其他的值可以进行指定。

![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-fonts-named-instances-along-weight-axis.png)

一个vf字体可以有很多类似的`轴`，比如增加一个`身高轴`，就能延伸出更多风格的字体。也可以想想成为一个有x和y的坐标轴，当x轴的可修改范围为50，y轴的可修改范围为500的时候，你就会得到25000中不同风格的字体，并且文件大小也很可观。

![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-fonts-venn-weight-axis-width-axis.png)
<p align="center">各种各样的字体</p>



### <a id="part_two">variable fonts能做什么？</a>

这个得根据字体的设计来决定，字体的设计提供了各种各种可以被修改的`轴`，比如粗细，长短以及任何合理范畴之内的。下面提供五个常用的`保留轴`:

- wdth: 用于修改字的宽窄
- wght: 用于修改字的粗细
- ital: 是否倾斜，0为非倾斜，1为斜体
- slnt: 用于修改字的倾斜程度
- opsz: 对于字形的修改(待确认)

尽管宽窄、粗细是更为常见的`供修改轴`，但是也有一些`自定义轴`，比如`衬线(衬线是字的笔画开始和结束部分的额外装饰)轴`等。

![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-fonts-weight-width-slant-axis-morphing.gif)
<p align="center">通过改变`轴`生成的动画，有没有很酷炫？</p>

### <a id="part_three">拉伸或者扭曲字体会不会有不好的效果和影响？</a>

当vf字体改变宽窄、粗细或者其他维度的时候，不会造成不好的影响。但是如果换做`transform: scaleX(0.5)`，就会发生不好的影响，因为它直接修改了字体的设计，设计师看了会打人。

为什么拉伸或者扭曲字体是一个很严重的问题？因为字体设计师在每个字符的协调上下了很多心血，所以这样的字体符合正常的审美。而草率的拉伸或者扭曲字体会导致设计师的心血功亏一篑。即使修改之后的不同是很微小的，但是也会影响字体整体的外观和感觉。

![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-font-vs-distorted-stretched-font.png)
<p align="center">仔细看上面这张图中的字母O，下面的O已经超出蓝色范围，而上面的依旧保持的很好。吐槽，本人没觉得有啥美感的丢失</p>

### <a id="part_four">variable fonts有哪些优点？</a>

##### 最明显的优点，或许你已经想到了，就是提供丰富的自定义web字体

网站开发者可以利用不同风格的字体去突出某些部分的趣味性和重要性，网站可以以编辑设计的方式处理更多的排版，提供更丰富的视觉展示和个性化方案。我创建了一个[测试网站](https://zeichenschatz.net/demos/vf/variable-web-typo/)，在这个网站上，我限制颜色风格，换句话说，我仅仅用了4中左右的颜色来表现网站的层次感，然后用了多大18中的字体去丰富网站。在我看来，这样比减少样式风格更加简介和独特。你可以点击右下角按钮来切换不同的字体主题，获得不同的体验。

![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-fonts-on-the-web-demo-page-its-time-for-variable-web-typography.jpg)
<p align="center">一个使用字体变换改变网站风格的测试网站</p>

#### 更小的文件体积

vf字体用更小的文件带来更多的可选风格。比如你想使用三四种不同粗细的字体，你可以用vf字体来获得更小文件体积的收益。举个例子：[Süddeutsche Zeitung Magazin](https://sz-magazin.sueddeutsche.de/)
该网站的字体加起来一共有236kb大小，其中四中不同粗细的字体加起来共166kb，如果换用vf字体，可以较少到80kb，__足足减少了50%！__

![资源](https://foxdaxian.github.io/assets/02_variableFonts/web-fonts-loaded-for-sz-magazin-sueddeutsche-de.jpg)
<p align="center">如果使用vf字体，至少可以节约一半的带宽</p>

#### 细颗粒度的控制

vf字体在如何渲染字体上提供细颗粒度的控制，你可以设置`font-weight:430`来提供更好地效果。因为这是一个可选的，所以像`font-weight:bold`这样的方式，仍然是奏效的

#### 更好地文字适配

如果vf字体提供`宽窄轴`操作能力，你可以让文字在移动设备上有更好的可读性。在宽一点的屏幕上，也能更好地利用空间。这个例子可以很清晰的展示这种效果: [browser example](https://zeichenschatz.net/demos/vf/width/)

#### 与动画结合

所有`轴`都可以通过css来产生一个过渡的动画效果。这能让你的网站带来很酷和充满活力的效果。在[微软示例](https://developer.microsoft.com/en-us/microsoft-edge/testdrive/demos/variable-fonts/)页面中，你可以通过滚动来查看令人印象深刻的动画效果。

#### 一种更重视视觉美的文字

这个概念来自印刷技术，通常指在小字号的时候更加可读，大字号的时候更加富有个性。在金属活字时期(使用金属作为载体的活字印刷术)，只能通过修改的文字尺寸来进行优化。后来，通过数字化技术，你可以设计一个适配所有尺寸的字体。现在相同的情况随着vf字体的出现得以解决。例如，小字号的时候笔画可以更粗一点，这意味着更低的对比度使可读性更高。另一方面，当大字号的情况下，空间更多，所以有更多的操纵性，和对比度。类似的变化在vf字体中可以在单一文件内逐渐产生。
![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-font-optical-size-voto-serif-variable.png)


### <a id="part_five">怎么在web上使用variable fonts？</a>

1. 找到可用的vf字体
	这个技术还是非常积极地，所以，如果你想使用它，你首先要找到相关资源。这有一个[资源](http://v-fonts.com/)可以供你使用，在这个网站里你能尝试很多vf字体，很多都是在github开源，并且可以直接下载的。[这也有一些很不错的资源](https://docs.google.com/spreadsheets/d/1ycxOqpcPA9NmCWcNbmxiY-KHEh820MucI1eO6QkKLOE/htmlview#gid=0)
1. 整合到你的网站中的样式表内
	2018上半年，超过一般的浏览器已经[支持](https://caniuse.com/#search=variable%20fonts)的很好了。

    通过`@font-face`引入到页面内：
    ```css
    @font-face {
        font-family: 'VennVF';
        src: url('VennVF_W.woff2') format('woff2-variations'),
            url('VennVF_W.woff2') format('woff2');
    }
    ```
    找到字体可变`轴`和可变范围，根据设计的不同的vf都有不同的`轴`和不同的范围，如果你不知道vf字体能做什么改变，你可以使用[在线工具](https://wakamaifondue.com/)，他也可以帮你生成现成的css。
    然后我们进行css的开发，不过在这之前，先说一下即将在css4字体模块中增加的可以设置vf字体的`高级属性`：
    - `font-weight`：可以设置1-999的任意数值
    - `font-stretch`：是一个百分比的值，100%是正常的，50%是紧缩的，200%是拉伸的，其对应的关键字应该可以使用，这对印刷来说是可怕的，因为它不能拉伸字体，拉伸字体会导致不好的结果，但是vf的改变是在涉及范围内的拉伸，是可以接受的。
    - `font-style`：一个倾斜的属性，从-90deg到90deg，当然关键字也是可以使用。90deg看起来是奇怪的，8deg是大部分字体中采用的最大值。
    - `font-optical-sizing`：这是一个新的属性，有两个可选属性`auto`和`none`。一般来说，浏览器会设置为auto，但你也可以设置为none

	不是所有vf字体都能控制上面的属性，这得根据字体的设计和可用范围来决定。我做了一些测试，safari支持`font-weight`和`font-stretch`，并且，如果optical可用，它会自动打开optical sizing。但是使用`font-style: italic`的结果是，没有更新vf字体的italic`轴`范围。

	只有在sarari上，这些高级属性兼容的还可以。所以，如果想保证稳定性，你需要使用一个低级的属性：`font-variation-settings`，你可以设置四部分，其实和上面的差不多。

    ```css
    p {
    	font-family: "VennVF";
    	font-variation-settings: "wght" 550, "wdth" 125;
    }
    ```

    这段代码改变字体粗细为550，还有宽窄为125。在不远的将来，你或许可以使用高级属性来得到同样的效果：

    ```css
    p {
    	font-family: "VennVF";
    	font-weight: 550;
    	font-stretch: 125%;
    }
    ```

    当然，vf字体其实还有更多的自定义`轴`可以使用，都可以使用`font-variation-setting`属性来设置：

    ```css
    h1 {
    	font-family: 'VennVF', sans-serif;
    	font-variation-settings: "TRMC" 0, "SKLA" 0, "SKLB" 0, "TRME" 0;
    }
    ```

    效果看起来像这样：

	![资源](https://foxdaxian.github.io/assets/02_variableFonts/variable-font-decovar-coustom-axis-morphing.gif)

1. 兼容不支持vf字体的浏览器

	如果你现在就想使用vf字体的话，在不支持的版本上，网站风格会和你想象中的完全不一样，所以我们需要一个回退方案，这个利用的css的特性查询功能：
    ```css
    @supports (font-variation-settings: normar){
    	/* set some property */
    }
    ```
    [点击查看@supports的各浏览器兼容](https://caniuse.com/#feat=css-featurequeries)，个人认为兼容还是可以的。
    然后，像下面这样设置vf，就可以适配大部分浏览器了：
    ```css
    body {
    	font-family: 'Venn', sans-serif;
    }

    @supports (font-variation-settings: normal) {
    	body {
    		font-family: 'VennVF', sans-serif;
    		}
    }
    ```
    解释一下：首先上面的body为正常的字体，下面为积极地做法，如果支持`font-variation-settings`，那么就采取vf字体，然后可以设置一些具体的字体细节。否则会静默失败。
    可能有人会用:not来配合@supports，有时候匹配成功不是因为not，而是因为@supports不支持，所以尽量避免。

### <a id="part_six">有哪些潜在的缺陷需要注意？</a>
vf字体为web字体带来了新的活力和发灰控件，但是，一项新的技术往往会伴随着很多我们需要注意的问题。
- 太多的选项
- 更多的与web无关的字体只是需要学习
- vf字体不一定总会对性能有所提高
- 你也许仍然需要多个字体文件以适配某些字体，比如罗马字体和斜体
- 可能会因为著作权、许可证而造成其他问题


### <a id="part_seven">variable fonts何时才会相对成熟？</a>
2018年大部分浏览器都已经支持了，很快移动设备也会支持，因为vf会节约很大的带宽。我期待2019年vf字体能够替换静态字体被用在各个web站点中。adobe和谷歌会在推动这项技术中一定会占主要部分，因为他们同样需要减少字体文件大小，虽然不知道这件事什么时候会发生。但是一定会很快。
我对文件大小没有太大的兴趣，我更多的兴趣实在使用更少的样色主题和更多的字体去设置网站的风格，像这个[网站](https://zeichenschatz.net/demos/vf/variable-web-typo/)。

##### 参考链接
- [更好地方案去使用vf字体](https://www.zeichenschatz.net/typografie/implementing-a-variable-font-with-fallback-web-fonts.html)
- [vf字体详细说明](https://www.zeichenschatz.net/typografie/how-to-start-with-variable-fonts-on-the-web.html)
- [可变字体](https://zhuanlan.zhihu.com/p/35822169)
- [字体历史](https://thetype.com/page/8/?s=%E5%AD%97%E4%BD%93)

