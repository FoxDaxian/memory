---
title:  webpack4分包方案
tags: frontend
categories: 经验总结
---

webpack4放弃了 commonsChunkPlugin，使用更方便灵活智能的 splitChunks 来做分包的操作。

下面有几个例子，并且我们假设所有的chunks大小至少为30kb(采用splitChunks默认配置)

### vendors

##### 入口

chunk-a: react react-dom 其他组件
chunk-b: react react-dom 其他组件
chunk-c: angular 其他组件
chunk-d: angular 其他组件

##### 产出

vendors~chunk-a~chunk-b: react react-dom
vendors~chunk-c~chunk-d: angular
chunk-a 至 chunk-d: 对应的其他组件


### 重复的vendors

##### 入口

chunk-a: react react-dom 其他组件
chunk-b: react react-dom lodash 其他组件
chunk-c: react react-dom lodash 其他组件

##### 产出

vendors~chunk-a~chunk-b~chunk-c: react react-dom
vendors~chunk-b~chunk-c: lodash
chunk-a 至 chunk-c: 对应的其他组件

### 模块

##### 入口

chunk-a: vue 其他组件 shared组件
chunk-b: vue 其他组件 shared组件
chunk-c: vue 其他组件 shared组件

假设这里的shared体积超过30kb，这时候webpack会创建vendors和commons两个块

##### 产出

vendors~chunk-a~chunk-b~chunk-c: vue
commons~chunk-a~chunk-b~chunk-c: shared组件
chunk-a 至 chunk-c: 对应的其他组件

如果shared提交小于30kb，webpack不会特意提出来，webpack认为如果仅仅为了减少下载体积的话，这样做是不值得的。

### 多个共享模块

##### 入口

chunk-a: react react-dom 其他组件 react组件
chunk-b: react react-dom angular 其他组件
chunk-c: react react-dom angular 其他组件 react组件 angular组件
chunk-d: angular 其他组件 angular组件

##### 产出

vendors~chunk-a~chunk-b~chunk-c: react react-dom
vendors~chunk-b~chunk-c~chunk-d: angular
commons~chunk-a~chunk-c: react组件
commons~chunk-c~chunk-d: angular组件
chunk-a 至 chunk-d: 对应的其他组件


### 关于webpack默认配置

```javascript
splitChunks: {
    chunks: "async",
    minSize: 30000,
    minChunks: 1,
    maxAsyncRequests: 5,
    maxInitialRequests: 3,
    automaticNameDelimiter: '~',
    name: true,
    cacheGroups: {
      vendors: {
          test: /[\\/]node_modules[\\/]/,
          priority: -10
      },
      default: {
              minChunks: 2,
              priority: -20,
              reuseExistingChunk: true
      }
    }
}
```

- chunks: 表示从哪些chunks里抽取代码，有三个值：
    1. initial：初始块，分开打包异步\非异步模块
    2. async：按需加载块, 类似initial，但是不会把同步引入的模块提取到vendors中
    3. all：全部块，无视异步\非异步，如果有异步，统一为异步，也就是提取成一个块，而不是放到入口文件打包内容中
    
[通过import()控制模块的一些属性](https://www.webpackjs.com/api/module-methods/#import-)

initial情况下，如果两个入口一个是同步引入，一个是异步引入，那么会分开打包，同步的直接将引入包打到入口文件的打包文件里，异步的会分出单独的块，按需引入
all情况下，如果一个异步一个同步，会统一分出一个单独的块，然后引入

- minSize代表最小块大小，如果超出那么则分包，该值为压缩前的。也就是先分包，再压缩
- minchunks表示最小引用次数，默认为1
- maxAsyncRequests: 按需加载时候最大的并行请求数，默认为5
- maxInitialRequests: 一个入口最大的并行请求数，默认为3
- automaticNameDelimiter表示打包后人口文件名之间的连接符
- name表示拆分出来块的名字
- cacheGroups：缓存组，除了上面所有属性外，还包括
  - test：匹配条件，只有满足才会进行相应分包，支持函数 正则 字符串
  - priority：执行优先级，默认为0
  - reuseExistingChunk：如果当前代码块包含的模块已经存在，那么不在生成重复的块


### 几种配置示例（依赖优先级priority）
##### 个人感觉其实只要玩好cacheGroups，就能完成各种各样的分包
```javascript
// 将所有node_modules中应用2次以上的抽成common块
optimization: {
  splitChunks: {
    cacheGroups: {
      common: {
        test: /[\\/]node_modules[\\/]/,
        name: 'common',
        chunks: 'initial',
        priority: 2,
        minChunks: 2
      }
    }
  }
}
```

```javascript
// 把所有超过2次的达成common，不局限于node_modules
optimization: {
  cacheGroups: {
    common: {
      name: 'common',
      chunks: 'initial',
      priority: 2,
      minChunks: 2,
    }
  }
}
```
```javascript
// 额外提取react相关基础模块，然后抽取引入超过两次的模块到common
optiomization: {
  cacheGroups: {
    reactBase: {
      name: 'reactBase',
      test: (module) => {
          return /react|redux|prop-types/.test(module.context);
      },
      chunks: 'initial',
      priority: 10,
    },
    common: {
      name: 'common',
      chunks: 'initial',
      priority: 2,
      minChunks: 2,
    }
  }
}
```

```javascript
// 如果提取出来的包依然很大，你又想利用好缓存，你可以这样做
// 这样你的每一个node_modules包都是一个chunks，对缓存很友好，会节约很多用户流量，虽然流量已经不之前
optimization: {
  cacheGroups: {
    vendor: {
      test: /[\\/]node_modules[\\/]/,
      name(module) {
        const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1];
        // 避免服务端不支持@
        return `npm.${packageName.replace('@', '')}`;
      },
    },
  }
}
```

### 相关文章
[Code Splitting, chunk graph and the splitChunks optimization](https://medium.com/webpack/webpack-4-code-splitting-chunk-graph-and-the-splitchunks-optimization-be739a861366)
[webpack4 splitchunks实践探索](https://imweb.io/topic/5b66dd601402769b60847149)
[chunks解释](https://medium.com/dailyjs/webpack-4-splitchunks-plugin-d9fbbe091fd0)
[vendors过大的解决方案](https://medium.com/hackernoon/the-100-correct-way-to-split-your-chunks-with-webpack-f8a9df5b7758#id_token=eyJhbGciOiJSUzI1NiIsImtpZCI6IjYwZjQwNjBlNThkNzVmZDNmNzBiZWZmODhjNzk0YTc3NTMyN2FhMzEiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJuYmYiOjE1NjYyMTI5OTEsImF1ZCI6IjIxNjI5NjAzNTgzNC1rMWs2cWUwNjBzMnRwMmEyamFtNGxqZGNtczAwc3R0Zy5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjExMTA4NzYzNDY0Nzc3OTk5MDIyNCIsImVtYWlsIjoiOTQ1MDM5MDM2QHFxLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhenAiOiIyMTYyOTYwMzU4MzQtazFrNnFlMDYwczJ0cDJhMmphbTRsamRjbXMwMHN0dGcuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJuYW1lIjoi5Yav5LiW6ZuoIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS8tanVBdFJLck93ZjgvQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQUNIaTNyZkVWU253cW1TSG81LTh1eWQ3Y0J5dnlUSnBuZy9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoi5LiW6ZuoIiwiZmFtaWx5X25hbWUiOiLlhq8iLCJpYXQiOjE1NjYyMTMyOTEsImV4cCI6MTU2NjIxNjg5MSwianRpIjoiZjhmMzdhZWFjMjA0NTVjMTNkNDU1ZjU2NjYxYjBiZDcwMmViNmNiYiJ9.r4nXLCswsDW8a4TDA4CEDu-8tN2Ez4NMmpKiR4Lw7uPq5ecvKH6fx8IZ-80V3l7P3AZ_hw-37f-6caTJBjiKT_MHLTt_qSSDIlvkhy2DU19X7-JxZfVoBRXgoMuPUJpOUPoak972TB-6w2pXtGxt0Dyk6jc4IKO4DMT1O9YvyiD-gwBggrhoi82DvLeyPLH6tkcav458gfU475J6U1l1p8T8Sk21QZB_ASraptxFTTaQdwGCDxYPGBpyuESmh5F5QTcq81qwb2dnpZN75-nd7FW1rggAaWpVAi4C3WDILR_TwEjkCf_wAv8UfF4fogy4Xr1acHuwNaLc9RoFBJHbNA)