---
title:  string.prototype.replace 特殊符号
date: 2019-08-05 12:00
tags: frontend
categories: 介绍
---

1. $$ => 代表 $

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190805193728.png)

2. $& => 代表匹配的内容

   $n => 代表正则匹配的第n个括号内的内容，意味着replace第一个参数为必须为正则
    
![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190805194116.png)

3. $` => 代表匹配之前的所有内容

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190805194258.png)

4. $' => 代表匹配之后的所有内容

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190805194509.png)