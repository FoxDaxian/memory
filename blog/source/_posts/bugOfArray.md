---
title: js数组中的漏洞
tags: frontend
categories: 原理
---

这边文章介绍了js中各个数组方法是如何处理数组中有空元素的

1.  运行实例
所有的方法都基于下面这个数组：
```javascript
var arr = ['a', , 'b']
```
如你所见，我们创建一个数组，第一位是a，第二位是空，第三位是b

2.  预热
    1.  数组最后一个位置是空
    在本文中，需要注意的是，js会忽略数组中最后的逗号，这意味着，如果你想在数组的最后添加空元素，你需要增加两个逗号：
    ```javascript
    > ['a', 'b', ]
    [ 'a', 'b' ]
    > ['a', 'b', , ]
    [ 'a', 'b', empty ]
    ```
    2.  数组复制
    我们使用sclice创建一个arr的浅克隆副本
    ```javascript
    var arr2 = arr.slice();
    ```
    右边部分等价于：
    ```javascript
      arr.slice(0, arr.length);
    ```
3.  数组方法对待空元素的表现
- foreach会跳过空元素
```javascript
> arr.forEach(function(x, i) {
     console.log(`${i}.${x}`);
    })
    // 输出
    0.a
    2.b
```
- every和some也会跳过
```javascript
> arr.every(function (x) { return x.length === 1 })
    // 输出
    true
```
- map会跳过空元素的那次，但是会保留空元素的位置
```javascript
> arr.map(function (x,i) { return i+'.'+x })
    // 输出
    [ '0.a', , '2.b' ]
```
- filter会移除空元素
```javascript
> arr.filter(function (x) { return true })
    // 输出
    [ 'a', 'b' ]
```
- join会转换undefined和空元素为空的字符串：''
```javascript
 > arr.join('-')
    // 输出
    'a--b'
    > [ 'a', undefined, 'b' ].join('-')
    // 输出
    'a--b'
```
- 其他方法都会保留空元素
4.  循环
for循环不访问数组，for-ion循环正确的列出了所有的键值
```javascript
    > var arr2 = arr.slice()
    > arr2.foo = 123;
    > for(var key in arr2) { console.log(key) }
    // 输出
    0
    2
    foo
    解释：因为数组是对象，所以会打印对象中的key，其他则会忽略非数字key
```
5.   Function.prototype.apply()
apply方法将空元素看做undefined，这样提供了一个非常简单的方法去创建一个由undefined组成的特定长度的数组。
```javascript
    // 元素为undefined
    > Array.apply(null, Array(3))
    // 输出
    [ undefined, undefined, undefined ]
```
如果不指定this，那么：
```javascript
    // 空元素
    > Array(3)
    // 输出
    [ , , , , ]
```
apply很容易的插入空元素到数组中，但是，你不能使用它执行任意数组，因为这些数组可能包含也可能不包含空元素，例如，任意数组[2]不包含空元素，apply应该返回'unchangede'，但是还是创建了一个长度为2的数组，因为Array()解释数组为数组长度，而不是数组元素
```javascript
    > Array.apply(null, [2])
    // 输出
    [ , ,]
```
6.  总结和建议
我们看到js有很多处理漏洞的方式，不过庆幸的是，我们一般不需要关心他是如何处理的，因为这种漏洞应该被避免，漏洞会造成性能问题，几乎百害无一用
7.  扩展阅读
    [稀疏数组和密集数组](http://2ality.com/2012/06/dense-arrays.html)
    [js迭代数组和对象](http://2ality.com/2011/04/iterating-over-arrays-and-objects-in.html)
    [原文链接](http://2ality.com/2013/07/array-iteration-holes.html)