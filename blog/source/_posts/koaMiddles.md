---
title:  koa 中间件原理
tags: backend
categories: 源码分析
---


```javascript
'use strict';

module.exports = compose;

function compose(middleware) {
    if (!Array.isArray(middleware))
        throw new TypeError('Middleware stack must be an array!');
    for (const fn of middleware) {
        if (typeof fn !== 'function')
            throw new TypeError('Middleware must be composed of functions!');
    }

    return function(context, next) {
        let index = -1;
        return dispatch(0);
        function dispatch(i) {
            if (i <= index)
                return Promise.reject(
                    new Error('next() called multiple times')
                );
            index = i;
            let fn = middleware[i];
            if (i === middleware.length) fn = next;
            if (!fn) return Promise.resolve();
            try {
                return Promise.resolve(fn(context, dispatch.bind(null, i + 1)));
            } catch (err) {
                return Promise.reject(err);
            }
        }
    };
}
```

### 代码很短，咱们直接分析：
- 本身是一个高阶函数，返回一个函数
- compose函数接收一个数组形式middleware的参数，如果不为数组或者数组中有非函数的项，抛出异常
- 返回的函数接收koa上下文环境参数 - ctx 和  下一个middleware， 不管怎样，该函数返回一个promise对象。以供之后进行下一步异步操作
  
### 分下compose返回的函数
- 初始化index，用户判断是否多次调用next，因为每调用一次next，都会是i + 1，而 index 只会同步为 i 一次
- 包含一个递归的dispatch函数，接收当前要执行的middle的索引，默认从0开始
- 之后获取当前要执行的middleware
- 如果为middleware的长度那么说明无可执行的middleware（因为数组的长度比真实的项索引多1），重新赋值为next（手动设置最后一个中间件）
- 如果fn为空，return promise
- try cache 执行的fn，并将fn的返回值作为promise的成功结果，dispatch.bind(null, next middleow) 为next，当你调用next的时候即调用下一个
- 捕获错误，返回err

koa中间件是一个可选的、灵活的，不一定要执行完所有的中间件，你可以只执行某几个，中间件可以操作ctx上的所有数据，可以通过koa中的respond处理ctx的相关属性，来进行数据展示等操作

