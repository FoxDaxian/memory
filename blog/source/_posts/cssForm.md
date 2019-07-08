---
title: css实现表单验证
tags: frontend
categories: 原理
---

#### 有没有办法只通过css来确定input标签是否有输入？

我有这个想法是因为我想完成一个自动补全的input部件，最基本的功能是：
- 如果input没有内容，这隐藏下拉框
- 反之，显示下拉框

我找到了一个也许不是很完美的实现方案，描述中可能会有一些细微的区别，不过我还是很希望能做这个简单的分享

***

首先，我们构造一个简单的form表单，仅仅只有一个input
```css
<form>
	<label for="input">输入框</label>
    <input type="text" id="input"/>
</form>
```

当输入一些值，我设置input的边框颜色为绿的，下面是一个例子:
![gif](https://foxdaxian.github.io/assets/04_input_only_css/check.gif)

#### 判断input是否为空
我通过html表单验证去判断是否为空，所以，这里我使用了```required```属性
```css
<form>
	<label> Input </label>
	<input type="text" name="input" id="input" required />
</form>
// valid：当input输入值也合法值时采用的样式
#input:valid{
	border-color: green;
}
```

这时，当有输入的时候，input表现的很好，边框颜色也有了相应的变化：

![gif](https://foxdaxian.github.io/assets/04_input_only_css/check2.gif)

但是，这里有个问题，如果用户输入的是空格，那么边框颜色也会发生改变。

![gif](https://foxdaxian.github.io/assets/04_input_only_css/check-whitespace.gif)

原理上看，这种表现是正常的，因为输入框确实有了内容。
但是，实际上，我不想让空格来触发自动补全弹窗
所以这还不能满足我们的需求，我要做更细致的检查

#### 进一步完善

html提供我们利用正则去验证输入框内容的属性:```pattern```，这里也尝试使用该属性来完善

因为想把空格视为非法输入，我使用```\S+```，这个很简单，匹配一个或者多个任何非空白字符
```css
<form>
	<label> Input </label>
	<input type="text" name="input" id="input" required pattern="\S+"/>
</form>
```

使用这种方式，的确奏效了，如果用户输入空格，输入框没有任何变化

![gif](https://foxdaxian.github.io/assets/04_input_only_css/check-pattern-pre1.gif)

但了个是，但是这个正则还是有问题，因为只允许输入非空白字符，所以你在任何位置输入空白都会导致输入框校验失败

![gif](https://foxdaxian.github.io/assets/04_input_only_css/check-pattern1.gif)

这里可以使用其他的正则来匹配，比如```\^\S+?.+```
```css
<form>
	<label> Input </label>
	<input type="text" name="input" id="input" required pattern="\S+.*"/>
</form>
```

现在输入框可以和空格混合输入了！
但是如果当前校验失败，输入框没有任何提示，这很不友好！
但我写这篇文章的时候，有一个问题我不断思考，能不能只用css给非法验证也加一种样式？

#### 输入无效

这里不能使用```:invalid```，因为有```required```字段，即使我们什么也不做，输入框也会有非正确状态的样式提示，这很奇怪。

查看了相关资源，我们可以使用```:placeholder-shown```来达到我们的目的

大概思路是：
- 增加placeholder
- 如果输入框如果用户输入了内容，但还不合法做一个处理
- 最后利用css的覆盖特性，添加一个当验证成功的样式处理

最终的css大概是这样
```css
/* 当填充的时候展示红色，所以这里默认是校验失败 */
input:not(:placeholder-shown) {
	border-color: hsl(0, 76%, 50%);
}
/* 当验证成功的时候，采用这个样式 */
input:valid {
	border-color: hsl(120, 76%, 50%);
}
```
这里有一个小小的[demo](https://codepen.io/zellwk/pen/dgEKxX/)

#### 总结
上面的内容就是如何只用css来提供一个基础表单验证功能，说是只用css，其实也利用的```pattern```能接受正则表达式，哈哈，所以最根本的是如何写出最优的正则表达式。



[原文链接](https://dev.to/zellwk/checking-if-an-input-is-empty-with-css-1fn3)




