---
title: Object.assign引发的问题
tags: frendend
categories: 原理浅析
---

### 缘由

今天看到一段代码

```javascript
return Object.assign(func1, func2);
```

心生疑惑，为什么 Object.assign 的参数可以是函数？
于是有了下面这一堆东西，其实都是老生常谈的东西，可能是岁数大了吧，有些片段都快丢失了，哈哈

### prototype

js 中 万物皆是对象！！！

**proto**（隐式原型）与 prototype（显式原型）
对象具有属性**proto**，可称为隐式原型
实例(对象)的 **proto** === 构造(该实例)函数的 prototype
函数 Function 是特殊的对象，除了有**proto**外，还有自己的特有的属性 - 原型对象(prototype)
原型对象有一个属性 - constructor，指回 x.prototype 的 x(原函数)

所以 函数 还是 构造函数的函数(Function)都会指回 Object

```javascript
// 特例
function aa() {}
aa.prototype; // => {constructor: ƒ}

Function.prototype; // => ƒ () { [native code] } 函数也是对象哦

// 所以
Function.prototype.constructor; // => ƒ Function() { [native code] }

Function.prototype.constructor === Function; // => true
```

Object.prototype 是 原型的尽头，在往上就是 null 了

看张老图吧

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191010200746.jpg)

### Objecg.assign

#### 定义

Object.assign 方法只会拷贝源对象自身的并且可枚举的属性到目标对象

分为两个关键点 源对象自身且可枚举的属性 和 目标对象，一个个解释

##### 枚举

判断是否为枚举属性: Object.propertyIsEnumerable(prop)
如果判断的属性存在于 Object 对象的原型内，不管它是否可枚举都会返回 false。

总的来说，不管什么类型，只要可以用 for...in 遍历出来的属性，全都可以拷贝到 **对象** 上

例如 string 和 number：
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191010200634.png)

##### 对象

所说的对象是哪些呢？通过 instanlceof 可知(不包含全部类型)

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191010194627.png)

上面是前提，下面让我们看一个 demo 吧：

```javascript
function fn() {}
console.log(fn[0], fn[1], fn[2]); // => undefined undefined undefined

const str = "963";
for (let k in str) {
  console.log(`${k}: ${str[k]}`); // => 0: 9
  // => 1: 6
  // => 2: 3
}

Object.assign(fn, "963");

console.log(fn[0], fn[1], fn[2]); // => 9 6 3
```

结果如下:
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191010201232.png)

[深入讲解**proto** 和 prototype](https://github.com/creeperyang/blog/issues/9)
[属性的可枚举型](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Enumerability_and_ownership_of_properties)
