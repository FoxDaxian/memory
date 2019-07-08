---
title:  flutter简析
tags: frontend
categories: 原理
---

# Flutter

### 目录

- 简介
- JIT & AOT
- 比较
- 框架结构
- 数据管理
- 原理简析
- 现状


### 简介
Flutter是谷歌的移动UI框架，主打跨平台、高保真、高性能。可以快速在ios和android上构建高质量的原生用户界面。使用Dart语言开发App。
  - 高性能
      - 开发JIT，发布AOT
      - 使用自己的渲染引擎，无需像rn那样js与native通信
  - 开发效率高
      - 一份代码多平台使用
      - 热重载
  - Dart强类型语言
  
实现思路：通过在不同平台实现统一接口的渲染引擎来绘制UI，而不依赖系统原生控件。所以解决的是UI的跨平台问题，如有涉及其他系统能力，依然需要原生开发。
Flutter也是受到的React启发，很多思想是相同的，所以有必要去了解react。

### JIT & AOT

##### 定义
- JIT(动态解释)
  边运行边编译，边编译边运行。
  ![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/13_flutter/jit.png)
- AOT(静态编译)
  把源代码编译成目标代码(机器码、中间字节码)，然后执行
  ![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/13_flutter/aot.png)
 
 ##### 比较
 JIT优点：
 1. 根据硬件情况编译最优结果
 2. 合理运用内存空间
 
JIT缺点：
1. 编译占用运行时资源
2. 需要在程序路畅和编译时间之间权衡

AOT优点：
1. 避免运行时的性能和内存消耗
2. 大大减少程序启动时间

AOT缺点：
1. 开发效率低

相关推荐： [WebAssembly介绍](https://ppt.baomitu.com/user/center)
 
### 框架结构

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/13_flutter/framework.png)
  
#### Flutter Framework
- framework中最下面两层是dary UI层，对应flutter中的```dart:ui```包，他是flutter引擎暴露的底层ui库，提供动画、手势等绘制能力
- Rendering层，依赖于dart ui层，相当于一个控制器。rendering层会构建出ui树，当ui树有变化的时候，diff，然后更新ui树，在渲染到屏幕上。
- Widgets层是flutter提供的一套基础组件库，在flutter中，可以说一切都是widget

#### Flutter Engine
- 纯c++实现的sdk，其中包括 skia引擎、 dart运行时、 文字排版引擎等等，在调用dart:ui的时候，调用最终会走到Engine，实现绘制逻辑。

#### 扩展 - widgets

**一切皆为widget***

和html不同，flutter没有css(样式)，也没有js(逻辑)，flutter只有一个个的widget，widget可以表示不同的html元素，比如input，button等等，widget也可以像html那样嵌套使用，不过是放到child中。

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/13_flutter/widget.png)

##### 展示Widget
- 你想加载图片，可以使用 ```Image```widget
- 你想居中，可以使用```Center```widget
- 你想采用独特的样式，可以使用```Theme```widget
- 你想添加手势检测，可以使用```GustureDetector```widget
还有常用的```Row```、```Column```、```Container```、```Text```等等

##### 状态Widget

- StatelessWidget
- StateFulWidget

想要管理widget的状态，你需要继承```StateFulWidget```

```javascript
// 有状态计数器demo
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  // 管理自己的状态，重写createState
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              '第一行',
            ),
            new Text(
              '$_counter'
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
```

[无状态demo](https://github.com/FoxDaxian/flutter_weixin/blob/master/lib/page/home/listItem.dart)

### 数据管理

常见的有：
- flutter_redux
- event_bus(推荐)

##### event_bus

事件总线模式、发布订阅模式
减少耦合，统一管理状态

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/13_flutter/event-bus.png)

n步曲
- 创建event bus(支持同步、异步)
```javascript
import 'package:event_bus/event_bus.dart';
EventBus eventBus = EventBus();
```
- 定义类
```javascript
class UserLoggedInEvent {
  User user;

  UserLoggedInEvent(this.user);
}
```
- 订阅
```javascript
eventBus.on<UserLoggedInEvent>().listen((event) {
  print(event.user);
});
// 监听所有
eventBus.on().listen((event) {
  print(event.user);
});
```
- 发布
```javascript
User myUser = User('fox');
eventBus.fire(UserLoggedInEvent(myUser));
```

### [原理简析](https://www.stephenw.cc/2018/05/14/flutter-principle/)

### 现状
今天google i/o大会，flutter团队宣布已支持移动、web、桌面和嵌入式设备。

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/13_flutter/flutternow.jpg)

同时发布了flutter for web的首个技术预览版，宣布flutter正在为包括google home hub在内的google只能平台提供支持。

flutter for web是flutter的代码兼容版本，使用基于标准的web技术(html, css, javascript)进行渲染，通过flutter for web，可以将dart编写的flutter代码编译成嵌入到浏览器，并部署到任何web服务器的客户端版本。开发者可以使用flutter的所有特性而无需浏览器插件。
