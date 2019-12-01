---
title:  使用lerna管理你的项目
tags: frendend
categories: 介绍
---


有段时间没更新博客了，是时候更新一波了。
之前不是vue-next出了吗，然后就去学习了一下，发现整个目录不是那么熟悉了，变成这样了:

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191201163148.png)

于是就这个线索去研究了一下，发下这是用的 lerna + yarn 的架构，不仅vue，包括jest，babel等都是用的这类架构，他们有相同的前缀，比如@babel/xxx，不过这个前缀(scope)是需要付费的。

lerna有什么优点呢？
- 分离一个大型的codebase到多个小的孤立或者公共的repo
- 可以统一管理版本号，一键发布,自动生成changelog([lerna publish](https://github.com/lerna/lerna/blob/master/commands/publish#readme))
- 一键安装依赖，包括link([lerna bootstrap](https://github.com/lerna/lerna/blob/master/commands/bootstrap#readme))
- 目录清晰，像上面vue-next那样。


<div style="align: center">
<img src="https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191201163946.jpg"/>
</div>


-----

所以说！

<div style="align: center">
<img src="https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191201164414.jpg"/>
</div>


### 开整！！！
首先使用lerna + yarn来管理我们的npm工作区：
所以创建一个空的reop，然后`npx lerna init`初始化lerna项目，然后左改改右改改，像下面这样，意思是说用yarn替代lerna的工作区定义，然后pkg中指定workspaces，指定private和root，表明别发布我。

```javascript
// lerna.js
{
    "version": "independent",
    "npmClient": "yarn",
    "useWorkspaces": true
}

```

```javascript
// package.json
{
    "name": "root",
    "private": true,
    "workspaces": [
        "packages/*",
        "demo"
    ]
}
```


<div style="align: center">
<img src="https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191201165050.png"/>
</div>

哈哈哈哈，开个玩笑，不过lerna的初始工作就好了，剩下的就是安装依赖啊，写代码啊，发布啊。用指令表示就是：
- lerna bootstrap(或者增加postinstall hooks自动执行)
- 写代码
- lerna version 指定版本
- lerna publish (前需要登录npm，例如: npm login)

不过，仅仅只有上面这些肯定是不够的，我们还需要增加：

- 本地预览
- 本地unit测试
- 一些自动化脚本
- 格式化检查工具
- 其他(ts、commitlint、[cz](https://github.com/commitizen/cz-cli))


这块就不啰嗦了，直接丢一个[repo: oneForAll](https://github.com/FoxDaxian/oneForAll)供大家参考，欢迎交流哈。
目录如下:

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20191201165826.png)


