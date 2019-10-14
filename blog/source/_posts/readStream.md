---
title: node可读流
tags: node
categories: 初出茅庐
---



### 概念

流（stream）是 Node.js 中处理流式数据的抽象接口。 stream 模块用于构建实现了流接口的对象。

Node.js 提供了多种流对象。 例如，HTTP 服务器的请求和 process.stdout 都是流的实例。

流可以是可读的、可写的、或者可读可写的。 所有的流都是 EventEmitter 的实例。

访问 stream 模块：

```javascript
const stream = require('stream');
```
尽管理解流的工作方式很重要，但是 stream 模块主要用于开发者创建新类型的流实例。 对于以消费流对象为主的开发者，极少需要直接使用 stream 模块。

Node.js 中有四种基本的流类型：

- Writable - 可写入数据的流（例如 fs.createWriteStream()）。
- Readable - 可读取数据的流（例如 fs.createReadStream()）。
- Duplex - 可读又可写的流（例如 net.Socket）。
- Transform - 在读写过程中可以修改或转换数据的 Duplex 流（例如 zlib.createDeflate()）。


此外，该模块还包括实用函数 stream.pipeline()、stream.finished() 和 stream.Readable.from()。

盗图
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191014212453.jpg)


### 如何获取内存中的流
可写流和可读流都会在内部的缓冲器中存储数据，可以分别使用的 writable.writableBuffer 或 readable.readableBuffer 来获取。
[细节](http://nodejs.cn/api/stream.html#stream_buffering)

### 可读流

#### 两种模式

- 流动模式(不用打，自己动)：数据`自动`从底层系统读取，并通过EventEmitter接口的事件尽可能快的提供刚给应用程序
- 暂停模式(打一下，动一下)：必须显示调用`stream.read()`读取数据块

其实，所有可读流`初始`的时候都处于`暂停模式`，不过可以通过以下方法切换到流动模式

- 添加 `data` 事件句柄。
- 调用 `stream.resume()` 方法。
- 调用 `stream.pipe()` 方法将数据发送到可写流。

当然，能切到`暂停模式`，肯定也能切到`流动模式`

- 如果没有管道目标，则调用 `stream.pause()`
- 如果有管道目标，则移除所有的管道目标。调用`stream.unpipe()`可以移除多个管道目标。


为了向后兼容，移除 'data' 事件句柄不会自动地暂停流。

如果有管道目标，一旦目标变为 drain 状态并请求接收数据时，则调用 stream.pause() 也不能保证流会保持暂停模式。

如果可读流切换到流动模式，且没有可用的消费者来处理数据，则数据将会丢失。 例如，当调用 readable.resume() 时，没有监听 'data' 事件或 'data' 事件句柄已移除。


添加 `readable` 事件句柄会使流自动停止流动，并通过 `readable.read()` 消费数据。 如果 `readable` 事件句柄被移除，且存在 `data` 事件句柄，则流会再次开始流动

### demo

#### 流动模式

```javascript
const fs = require('fs')
const path = require('path')
const rs = fs.createReadStream(path.join(__dirname, './1.txt'))

rs.setEncoding('utf8')

rs.on('data', (data) => {
    console.log(data)
})
```

#### 暂停模式
```javascript
const fs = require('fs')
const path = require('path')
const rs = fs.createReadStream(path.join(__dirname, './1.txt'))

rs.setEncoding('utf8')

rs.on('readable', () => {
    let d = rs.read(1) // 要读取的数据的字节数。
    console.log(d)
})
```

### read方法： 参数 可选 [size]
如果没有指定 size 参数，则返回内部缓冲中的所有数据。

使用 `readable.read()` 处理数据时， while 循环是必需的。 
read方法消耗的是内存中的数据

当read方法返回的是`null`的时候，会触发 流监听的 `end` 事件
不使用read消耗内存中的流数据，则不会触发end

预览一波

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191014220028.png)

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191014220036.png)



### 遇到的问题

```javascript
process.stdin.setEncoding('utf8');

process.stdin.on('readable', () => {
    let chunk;
    while ((chunk = process.stdin.read()) !== null) {
        process.stdout.write(`数据: ${chunk}长度${chunk.length}\n`);
    }
});

process.stdin.on('end', () => {
    process.stdout.write('结束\n');
    process.exit(1);
});
```

上面的代码作用是读取用户在terminal上的输出，然后输出内容和长度，但是执行的时候，总是无法执行到end，不仅如此，就算内容为空，返回的长度也不为0，这让我很疑惑。

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191014220334.gif)

最后发现是坚挺的`end`事件，只有当read方法返回为null的时候才会触发，所以没有触发，而问题就在于返回的内容是换行符，不同系统下换行符不一样，mac下是`\n`，所以我们需要处理一下read返回的内容，然后手动end
查看字符串中回车符可以使用:
```javascript
console.log(JSON.stringify(chunk));
```

修正后的代码为:

```javascript
process.stdin.setEncoding('utf8');

process.stdin.on('readable', () => {
    let chunk;
    while ((chunk = process.stdin.read()) !== null) {
        chunk = chunk.replace(/\n/g, '');
        if (!chunk.length) {
            console.log('输入为空');
            return process.stdin.emit('end');
        }
        process.stdout.write(`数据: ${chunk}长度${chunk.length}\n`);
    }
});

process.stdin.on('end', () => {
    process.stdout.write('结束\n');
    process.exit(1);
});
```

执行结果: 
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191014221044.gif)

[中文文档](http://nodejs.cn/api/stream.html#stream_readable_streams)