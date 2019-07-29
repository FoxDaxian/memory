---
title:  cookieless记录用户信息？
date: 2019-07-29 12:00
tags: frontend
categories: 畅想
---

#### cookie是什么：
cookie是由web服务器保存在用户浏览器（客户端）上的小文件，它可以包含用户信息，用户操作信息等等，无论何时访问服务器，只要同源，就能携带到服务端

#### 常见方式
1. 一般：请求一个接口，返回是否登录，如果登录成功，服务器(set-cookie)设置cookie到浏览器，以后请求api会继续请求
2. jwt：将用户id.payload.签证进行加密，并且注入到客户端cookie，之后每次请求会在服务端解析该cookie，并获取对应的用户数据，由于存在客户端，所以解放了服务端，减少服务端压力。也可以将该cookie放到根域名下，这样就可以登录一次，遍地开花。

#### 可以看到，常见的方式都是利用cookie（或者浏览器storage），这样你的信息还是会被看到，如果别人获取到你的cookie也有办法进行破解甚至直接复制登录。那么有没有办法不借用cookie来记录用户信息的？

---- 


#### 利用缓存存储用户信息
1. 优点：安全可靠
2. 缺点：依赖服务端

#### 原理概述：
请求一个资源，如果设置cache-control、lastmodify、etag等，会进行缓存相关的判定：
1. cache-control：是否强缓存，如果命中直接读取浏览器缓存的上次返回内容
2. last-modify：如果未命中强缓存，进行时间的判断，如果有if-modified-since并且和last-modify那么读取缓存，否则重新拉取资源
3. etag：如果未命中强缓存，通过etag唯一标志福来判断是否需要拉取最新资源，etag一般用文件内容的hash加密后内容，如果是大文件，个人建议使用文件大小+最后修改时间作为唯一标志
综上所述，如果我们请求一个很小的资源文件，例如1字节的图片，服务端设置cache-control: max-age=0，跳过强缓存，服务端设置etag，保证每次都做协商缓存，然后根据etag的变化来决定是否需要拉新(记录用户信息)，如果etag没有变化，那么就读取缓存(缓存记录用户信息)

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190729114108.png)

#### 代码示例
```javascript
const Koa = require('koa');
const KoaBody = require('koa-body');
const fs = require('fs');
const path = require('path');
const glob = require('glob');

const baseDate = {
    visitCount: 1,
    date: undefined,
    info: ''
};

const app = new Koa();

app.use(KoaBody());

app.use(async ctx => {
    // 更新资源
    if (ctx.req.url === '/updateInfo' && ctx.req.method === 'POST') {
        const session = require('./session.json');
        session.info = ctx.request.body.info;
        await writeFile('session.json', JSON.stringify(session));
        ctx.body = {
            code: 1
        };
    }

    const imgType = glob
        .sync('*.+(jpg|png)')
        .map(file => path.resolve('/', file));

    if ((fileIndex = imgType.indexOf(ctx.req.url)) !== -1) {
        const res = ctx.response;
        const req = ctx.req;
        res.type = path.extname(imgType[fileIndex]).slice(1);
        const filePath = path.join('./', imgType[fileIndex]);
        res.set('cache-control', 'public, max-age=0');

        let session;
        try {
            session = require('./session.json');
        } catch (e) {
            session = {...baseDate};
            session.date = new Date().toLocaleString();
            await writeFile('session.json', JSON.stringify(session));
        } finally {
            // use force refresh to clear etag, because if serve set etag,
            // browser will carry if-none-match field in request header. and we can use if-none-match to judge somethine
            // etag 大文件一般用文件大小 + 修改时间 来生成，而不是读取文件内容
            md5 = convertMd5(JSON.stringify(session));
            res.etag = md5;
            if (req.headers['if-none-match']) {
                // console.log('缓存');
                session.visitCount = +session.visitCount + 1;
                session.date = new Date().toLocaleString();
                await writeFile('./session.json', JSON.stringify(session));
                res.status = 304;
            } else {
                // console.log('清除缓存');
                session.visitCount = 1;
                session.date = new Date().toLocaleString();
                session.info = '';
                await writeFile('./session.json', JSON.stringify(session));
                ctx.body = fs.createReadStream(filePath);
            }
        }
    }
});

app.listen(3000);

```

#### 运行demo

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190729114709.gif)

有问题欢迎交流