---
title: package.json 中的字段
tags: frendend
categories: 介绍
---

- workspace
  将一个大型工程进行模块化，根据单一职责，方便日后的维护，但是这种方法不受用与所有工程，比如一些工程需要将所有仓库放到一个统一的存储库中，方便协作共建维护。这就派生出了 monorepos，对应的方法就是 yarn 的 workspace 或者 lerna，它能够帮你节约每次 cd + install or upgrade 的时间，更方便管理。
  [yarn](https://yarnpkg.com/blog/2017/08/02/introducing-workspaces/)
  [中文](https://hateonion.me/posts/b2b0/)
- resolutions
  强制指定子依赖的版本，防止升级后导致多个版本并存，打包后内容大
  [yarn](https://yarnpkg.com/lang/en/docs/selective-version-resolutions/)
  [demo](https://juffalow.com/javascript/how-yarn-resolutions-can-save-you)
  [中文](https://blog.hakurouken.me/2018/08/05/yarn-versions/)
- private
  如果为 true，那么 npm 将拒绝发布它，用来防止私人存储库意外发布的一种方法
- engines
  指定项目运行的node版本范围
-
