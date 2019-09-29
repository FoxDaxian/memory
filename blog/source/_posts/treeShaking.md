---
title:  什么是tree shaking，它是怎样工作的？
tags: backend
categories: 原理简析（翻译）
---

当javascript应用体积越来越大时，一个有利于减少体积的办法是拆分为不同的模块，伴随着模块化的产生，我们也可以进一步的移除多余的代码，比如那些虽然被应用，但是没有被实际用到的代码。tree shaking就是上述说法的一种实现，它通过去除所有引入但是并没有实际用到的代码来优化我们的最终打包结果的体积。

比如说，我们有一个工具文件，其中包含一些方法。

```javascript
// math.js
export function add(a, b) {
    console.log("add");
    return a + b;
}

export function minus(a, b) {
    console.log("minus");
    return a - b;
}

export function multiply(a, b) {
    console.log("multiply");
    return a * b;
}

export function divide(a, b) {
    console.log("divide");
    return a / b;
}
```

在我们的应用入口文件中，我们仅仅引入其中某一个方法，比如 `add`

```javascript
// index.js
import { add } from "./math";

add(1, 2);
```

假设我们使用webpack进行打包，下面是结果，我们仍然可以看到所有的方法，虽然我们仅仅想引入`add`方法

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190924192611.png)

不过，一旦我们开启 `tree shaking`，就只有我们引入的`add`方法会出现在bundle中

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190929145145.png)

-----


### tree shaking的原理
尽管90年代就有了tree shaking的概念，但是对于前段来说，tree shaking真正可以使用是在引入 `es6-module` 后。因为tree shaking 仅仅能分析静态语法。
在 es6 modules 之前，我们有commonjs规范，可以通过`require()`语法引入，但是，require是动态的，意味着我们可以在if - else 中使用它。
```javascript
var myDynamicModule;

if (condition) {
    myDynamicModule = require("foo");
} else {
    myDynamicModule = require("bar");
}
```

上面的是commonjs模块的语法，不过tree shaking无法使用，因为在程序运行之前无法判断哪个模块会被实际应用。也就是说语法分析不能识别。

es6引入了新的完全静态的语法，使用`import`发育，不在支持动态引入。(后来引入了的`import()`，返回promise，还是支持动态引入的.)

```javascript
// not work
if (condition) {
    import foo from "foo";
} else {
    import bar from "bar";
}
```

相反，我们只能定义所有的引入在if - else之外的全局环境内，

```javascript
import foo from "foo";
import bar from "bar";

if (condition) {
    // do stuff with foo
} else {
    // do stuff with bar
}
```
除了其他的改进好处，新的语法有效的支持了tree shaking，任何代码不需要运行就可以通过语法解析判断出是否真正呗用到，以便进一步减少打包后的体积

### tree shaking 甩掉了什么

webpack中的tree shaking，尽可能的甩掉了所有未使用到的代码，例如，引入了但是没有实际应用的代码会被消除。

```javascript
import { add, multiply } from "./mathUtils";

add(1, 2);
```

上面的代码，multiply因为被实际应用，所以会被消除

即使对象上有定义的属性，但是如果没有被访问，也会被移除

```javascript
// myInfo.js
export const myInfo = {
    name: "Ire Aderinokun",
    birthday: "2 March"
}
```

```javascript
import { myInfo } from "./myInfo.js";

console.log(myInfo.name);
```

before: 

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190929151539.jpg)

after:

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190929151547.png)


不过 tree shaking 并不能消除所有的代码，因为 tree shaking 只会处理方法和变量，看下面的例子

```javascript
// myClass.js
class MyClass {}

MyClass.prototype.saySome = function () {} // 副作用

// 扩展数据的方法
Array.prototype.unique = function () {}

export default MyClass
```

```javascript
import MyClass from './myClass';

console.log('index');
```

这个时候就不会消除类文件myClass，因为会触发getter、setter，而getter、setter是不透明的，可能会有副作用
[详情参考](https://zhuanlan.zhihu.com/p/32831172)

[rollup在线转换](https://rollupjs.cn/repl?version=0.53.3&shareable=JTdCJTIybW9kdWxlcyUyMiUzQSU1QiU3QiUyMm5hbWUlMjIlM0ElMjJtYWluLmpzJTIyJTJDJTIyY29kZSUyMiUzQSUyMmltcG9ydCUyME15Q2xhc3MlMjBmcm9tJTIwJy4lMkZ0ZXN0JyUzQiU1Q24lNUNuY29uc29sZS5sb2coMTIzKSUyMiU3RCUyQyU3QiUyMm5hbWUlMjIlM0ElMjJjb21wb25lbnRzLmpzJTIyJTJDJTIyY29kZSUyMiUzQSUyMmV4cG9ydCUyMGNsYXNzJTIwUGVyc29uJTIwJTdCJTVDbiUyMCUyMGNvbnN0cnVjdG9yJTIwKCU3QiUyMG5hbWUlMkMlMjBhZ2UlMkMlMjBzZXglMjAlN0QpJTIwJTdCJTVDbiUyMCUyMCUyMCUyMHRoaXMuY2xhc3NOYW1lJTIwJTNEJTIwJ1BlcnNvbiclNUNuJTIwJTIwJTIwJTIwdGhpcy5uYW1lJTIwJTNEJTIwbmFtZSU1Q24lMjAlMjAlMjAlMjB0aGlzLmFnZSUyMCUzRCUyMGFnZSU1Q24lMjAlMjAlMjAlMjB0aGlzLnNleCUyMCUzRCUyMHNleCU1Q24lMjAlMjAlN0QlNUNuJTIwJTIwZ2V0TmFtZSUyMCgpJTIwJTdCJTVDbiUyMCUyMCUyMCUyMHJldHVybiUyMHRoaXMubmFtZSU1Q24lMjAlMjAlN0QlNUNuJTdEJTVDbmV4cG9ydCUyMGNsYXNzJTIwQXBwbGUlMjAlN0IlNUNuJTIwJTIwY29uc3RydWN0b3IlMjAoJTdCJTIwbW9kZWwlMjAlN0QpJTIwJTdCJTVDbiUyMCUyMCUyMCUyMHRoaXMuY2xhc3NOYW1lJTIwJTNEJTIwJ0FwcGxlJyU1Q24lMjAlMjAlMjAlMjB0aGlzLm1vZGVsJTIwJTNEJTIwbW9kZWwlNUNuJTIwJTIwJTdEJTVDbiUyMCUyMGdldE1vZGVsJTIwKCklMjAlN0IlNUNuJTIwJTIwJTIwJTIwcmV0dXJuJTIwdGhpcy5tb2RlbCU1Q24lMjAlMjAlN0QlNUNuJTdEJTIyJTdEJTJDJTdCJTIybmFtZSUyMiUzQSUyMnRlc3QuanMlMjIlMkMlMjJjb2RlJTIyJTNBJTIyJTVDbmV4cG9ydCUyMGNsYXNzJTIwTXlDbGFzcyUyMCU3QiU3RCU1Q24lNUNuTXlDbGFzcy5wcm90b3R5cGUuc2F5U29tZSUyMCUzRCUyMGZ1bmN0aW9uJTIwKCklMjAlN0IlN0QlNUNuJTVDbkFycmF5LnByb3RvdHlwZS51bmlxdWUlMjAlM0QlMjBmdW5jdGlvbiUyMCgpJTIwJTdCJTdEJTVDbiU1Q24lMjIlN0QlNUQlMkMlMjJvcHRpb25zJTIyJTNBJTdCJTIyZm9ybWF0JTIyJTNBJTIydW1kJTIyJTJDJTIybW9kdWxlTmFtZSUyMiUzQSUyMm15QnVuZGxlJTIyJTJDJTIyZ2xvYmFscyUyMiUzQSU3QiU3RCUyQyUyMm5hbWUlMjIlM0ElMjJteUJ1bmRsZSUyMiUyQyUyMmFtZCUyMiUzQSU3QiUyMmlkJTIyJTNBJTIyJTIyJTdEJTdEJTJDJTIyZXhhbXBsZSUyMiUzQW51bGwlN0Q=)

也许你会说我们能判断是否是原生方法，进而进行排除，其实不然，我们可以这样

```javascript
let a = 'a';
a += 'rr';
a += 'ay';
```
一句话就是，因为js本身是动态语言，所以情况太多，处理起来会有风险，tree shaking 的本意是优化，而不是影响，所以不是所有的代码都可以tree shaking


### 关于 'side effects'

中文直译：副作用
什么是副作用：对当前包意外产生任意影响就是副作用

一个典型的具有副作用的形式是 pollfills，因为它在window上增加了各种宿主环境不支持的最新方法，所以不能添加side effects

### 如何tree shake

webpack目前支持通过设置mode来开启，比如

```javascript
module.exports = {
    ...,
    mode: "production",
    ...,
};
```

webpack老版本依赖uglifyjs




