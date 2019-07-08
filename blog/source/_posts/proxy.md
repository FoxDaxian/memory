---
title:  proxy简析
tags: frontend
categories: 原理
---

# Proxy

使用proxy，你可以把老虎伪装成猫的外表，这有几个例子，希望能让你感受到proxy的威力。
proxy 用来定义自定义的基本操作行为，比如查找、赋值、枚举性、函数调用等。

proxy接受一个待代理目标对象和一些包含元操作的对象，为待代理目标创建一个‘屏障’，并拦截所有操作，重定向到自定义的元操作对象上。

proxy通过```new Proxy```来创建，接受两个参数：
1. 待代理目标对象
2. 元操作对象

闲话少说，直接看例子。

#### 最简单的只代理一个方功能，在这个例子里，我们让```get```操作，永远返回一个固定的值

```javascript
let target = {
  name: 'fox',
  age: 23
}
let handler = {
  get: (obj, k) => 233
}
target = new Proxy(target, handler);
target.a // 233
target.b // 233
target.c // 233
```
无论你```taget.x```、```target[x]```、```Reflect.get(target, 'x')```都会返回233
当然，代理```get```仅仅是其中一种操作，还有：
    - [get](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/get)
    - [set](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/set)
    - [has](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/has)
    - [apply](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/apply)
    - [construct](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/construct)
    - [ownKeys](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/ownKeys)
    - [deleteProperty](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/deleteProperty)
    - [defineProperty](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/defineProperty)
    - [isExtensible](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/isExtensible)
    - [preventExtensions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/preventExtensions)
    - [getPrototypeOf](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/getPrototypeOf)
    - [setPrototypeOf](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/setPrototypeOf)
    - [getOwnPropertyDescriptor](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy/handler/getOwnPropertyDescriptor)

#### 改变默认值为0
在其他语言中，如果访问对象中没有的属性，默认会返回0，这在某些场景下很有用，很方便，比如坐标系，一般来说z轴默认是0.
但是在js中，对象中不存在的key的默认值是undefined，而不是合法的初始值。
不过可以使用proxy解决这个问题
```javascript
const defaultValueObj = (target, defaultValue) => new Proxy(target, {
  get: (obj, k) => Reflect.has(obj, k) ? obj[k] : defaultValue
})
```
建议根据不同类型返回不同的默认值，Number => 0 String => '' Object => {} Array => []等等

#### 数组负索引取值
js中，获取数组的最后一个元素是相对麻烦的，容易出错的。这就是为什么TC39提案定义一个方便的属性，```Array.lastItem```去获取最后一个元素。
其他语言比如python，和ruby提供了访问数组最后一个元素的方法，例如使用arr[-1]代替arr[arr.length - 1]
不过，我们有proxy，负索引在js中也可以实现。
```javascript
const negativeArray = els => new Proxy(els, {
  get: (target, k) => Reflect.get(target, +k < 0 ? String(target.length + +k) : k)
})
```
需要注意的一点是，get操作会字符串化所有的操作，所以我们需要转换成number在进行操作，
这个运用也是```negative-array```的原理

#### 隐藏属性
js未能实现私有属性，尽管之后引入了```Symbol```去设置独一无二的属性，但是这个被后来的```Object.getOwnPropertySumbols```淡化了
长期以来，人们使用下划线_来表示属性的私有，这意味着不运行外部操作该属性。不过，proxy提供了一种更好的方法来实现类似的私有属性
```javascript
const enablePrivate = (target, prefix = '_') => new Proxy(target, {
  has: (obj, k) => (!k.startsWith(prefix) && k in obj),
  ownKeys: (obj, k) => Reflece.ownKeys(obj).filter(k => (typeof k !== 'string' || !k.startsWith(prefix))),
  get: (obj, k, rec) => (k in rec) ? obj[k] : undefined
})
```
结果
```javascript
let userData = enablePrivate({
  firstName: 'Tom',
  mediumHandle: '@tbarrasso',
  _favoriteRapper: 'Drake'
})

userData._favoriteRapper        // undefined
('_favoriteRapper' in userData) // false
Object.keys(userData)           // ['firstName', 'mediumHandle']
```
如果你打印该proxy代理对象，会在控制台看到，不过无所谓。

#### 缓存失效
服务端和客户端同步一个状态可能会出现问题，这很常见，在整个操作周期内，数据都有可能被改变，并且很难去掌握需要重新同步的时机。
proxy提供了一种新的办法，可以让属性在必要的时候失效，所有的访问操作，都会被检查判断，是否返回缓存还是进行其他行为的响应。
```javascript
const timeExpired = (target, ttl = 60) => {
  const created_at = Date.now();
  const isExpired = () => (Date.now - created_at) > ttl * 1000;
  return new Proxy(tarvet, {
    get: (target, k) => isExpired() ? undefined : Reflect.get(target, k);
  })
}
```
上面的功能很简单，他在一定时间内正常返回访问的属性，当超出ttl时间后，会返回undefined。
```javascript
let timeExpired = ephemeral({
  balance: 14.93
}, 10)

console.log(bankAccount.balance)    // 14.93

setTimeout(() => {
  console.log(bankAccount.balance)  // undefined
}, 10 * 1000)
```
上面的例子会输出undefined在十秒后，更多的骚操作还请自行斟酌。

#### 只读
尽管```Object.freeze```可以让对象变得只读，但是我们可以提供更好的方法，让开发者在操作属性的时候获取明确的提示
```javascript
const nope = () => {
  throw new Error('不能改变只读属性')
}
const read_only = (obj) => new Proxy(obj, {
  set: nope,
  defineProperty: nope,
  deleteProperty: nope,
  preentExtensions: nope,
  setPrototypeOf: nope
});
```

#### 枚举
结合上面的只读方法
```javascript
const createEnum = (target) => read_only(new Proxy(target, {
  get: (obj, k) = {
    if (k in obj) {
      return Reflect.get(obj, k)
    }
    throw new ReferenceError(`找不到属性${k}`)
  }
}))
```
我们得到了一个对象，如果你访问不存在的属性，不会得到undefined，而是抛出一个指向异常错误，折让调试变得更方便。
这也是一个代理代理的例子，需要保证被代理的代理是一个合法的代理对象，这个有助于混合一些复杂的功能。

#### 重载操作符
最神奇的可能就是重载某些操作符了，比如使用```handler.has```重载```in```。
in用来判断指定的属性是否指定对象或者对象的原型链上，这种行为可以很优雅的被重载，比如创建一个用于判断目标数字是否在制定范围内的代理
```javascript
const range = (min, max) => new Proxy(Object.create(null), {
  has: (obj, k) => (+k > min && +k < max)
})
```
```javascript
const X = 10.5
const nums = [1, 5, X, 50, 100]

if (X in range(1, 100)) { // true
  // ...
}

nums.filter(n => n in range(1, 10)) // [1, 5]
```
上面的例子，虽然不是什么复杂的操作，也没有解决什么复杂的问题，但是这种清晰，可读，可复用的方式相信也是值得推崇的。
当然除了in操作符，还有delete 和 new;

#### 其他
- 兼容性一般，不过谷歌开发的[proxy-polyfill](https://github.com/GoogleChrome/proxy-polyfill)目前已经支持get、set、apply、construct到ie9了
- 目前浏览器没有办法判断对象是否被代理，不过在node版本10以上，可以使用```util.types.isProxy```来判断
- proxy的第一个参数必须是对象，不能代理原始值
- 性能，proxy的一个缺点就是性能，但是这个也因人/浏览器而异，不过，proxy绝对不适合用在性能关键点的代码上，当然，你可以衡量proxy带来的遍历和可能损耗的性能，进行合理的中和，来达到最佳的开发体验和用户体验

