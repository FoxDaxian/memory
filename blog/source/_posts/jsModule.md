---
title: js模块的前生今世
tags: frontend
categories: 原理
---

我曾经做过js讲师，在我的任教过程中，模块系统一直是学生们的薄弱点。有一个充分的理由可以解释这个问题：***模块在javascript中有一段奇怪且不稳定的历史***。这篇文章我们将讨论这段历史，并且，你讲了解过去的模块的相关知识，以更好的理解当前模块的工作原理。
在学习如何在js中创建模块之前，首先需要明白，模块是什么以及为什么会存在模块。环顾你的周边，你会发现，很多复杂的东西都是有一个个分离的部件组合在一起构成，进而形成一个完整的东西。

以一只手表为例：

![手表结构](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/06_js_module/watch-internals.jpg)

可以看到，一只手表由成百上千的内部部件组成，每一个内部部件都有特定的功能和清晰地边界以方便与其他部件协作。把这些部件组合在一起，就组成了这只完整的手表。我不是一个手表制造业的专家，但是我因为这种方法的优点是非常直观的。

#### 可复用性

如果你仔细的观察一些上图中的构造，你会发现有很多部件都是重复的。由于这种模块化为中心的设计，手表中的不同功能也可以用到相同的部件。这种可复用部件的能力简化的工作制造流程，并且提高的利润。

#### 可组合性

这种设计是可组合性的非常直观的案例。通过制定每个部件清晰地边界，能够很好地组合每一个部件，以创造一个功能齐全的手表。

#### 可利用性（或许有更好的解释？）

设想一下制造过程，公司不会制造手表，他们只是将这些部件拼接起来以产出一只完整的手表。他们可以自己制作这些部件，也可以将这些部件外包给其他工厂，这不重要，重要的是这些部件组合在一起就是一只完整的手表，而这些部件来自于哪是无关紧要的。

#### 隔离性

明白手表的整个系统是很困难的，因为它由很多小而复杂的，功能专一的部件组成，每个部件都可以单独考虑，构造和修复。这种隔离性允许人们单独工作，不会成为彼此的负担。并且，如果一个部件循环，仅仅需要更换这个部件看，而不是更换这只表。

#### 组织化

组织是每个独立的拥有清晰边界的部件为了与其他部件组合的副产品，伴随着模块化，自然就会出现这种情况。

随着手表这样的结构不断产出，我们可以越来越清晰地认识到模块化的好处，那么，如果我们换成软件领域呢？其实是一样的。就像手表的设计一样，软件也应该被设计，分割成不同的具有特定功能的部件，并且具有为了与其他部件组合的清晰边界。不过，在软件中，这种部件被叫做模***模块***。到现在为止，模块给我们的感觉可能与react组件和函数大相径庭。那模块到底包含什么呢？

*每一个模块都具有三部分：依赖，代码内容还有导出。*

#### 依赖

当一个模块需要其他模块的功能，它可以```import```这个模块作为依赖，例如，无论什么何时，你想创建一个react组件，你只需要```import react```模块，如果你想使用``` lodash```，你也只需要```impiort lodash```模块。

#### code

确定好你的模块需要的依赖之后，你就可以开始编写这个模块

#### exports

```exports```是当前模块的```接口```，引入这个模块的开发者可以使用你导出的一切功能。

说了这么多概念，下面让我们来点实际的代码。

先来看一个react router的例子，方便起见，可以看一下react提供的[模块目录](https://github.com/ReactTraining/react-router/tree/master/packages/react-router/modules)，在react router中合理的利用模块，事实证明，在大多数情况下，他们直接映射react组件到模块，在react项目中分离组件是很有意义的，重新审查上面的手表结构，将部件换成组件同样有意义。

来看一下```MemoryRouter```模块的代码，现在不要关心代码的含义，只需要集中在代码的结构上。

```javascript
// imports
import React from 'react';
import { createMemoryHistory } from 'history';
import Router from './Router';

// code
class MemoryRouter extends React.Component {
    history = createMemoryHistory(this.props);
    
    render() {
        return (
            <Router
            history={this.history}
            children={this.props.children}
            />;
        )
    }
}

//exports
export default MemoryRouter;
```

你可以注意到这个模块的顶部定义了依赖，和一些使当前模块正产工作的必需的模块。接下来，可以看到一些代码。在这个例子中，创建了一个叫做MemoryRouter的新的react组件，最后，在底部定义了对外导出：MemoryRouter，也就是说，任何导入该模块的模块都会得到MemoryRouter这个组件。

现在，我们对软件中的模块有了一个浅显的认识，让我们回顾一些手表设计带来的好处，在相同设计的软件中有哪些可以可以直接应用。


#### 可复用性

因为模块可以在任何需要它的地方```import```，所以模块的复用性很强，如果模块在程序中用处很多，你可以单独创建一个包。这个包可以包含一个或多个其他模块，并且上传到```npm```开源。``` reacrt```、```lodash```还有```jquery```都是可以从npm上下载的npm包。

#### 可组合性

由于模块定义了导入和导出，所以很容易组合起来，不仅如此。一个软件好的设计应该是低耦合，模块增加了代码的灵活性。

#### 可利用性

npm上有世界上数量最多的免费模块，超过七十万个，如果你需要某个功能的包，就去npm上找吧。

#### 隔离性

这里使用手表的描述也是合适的。不在赘述。

#### 组织化

模块最大的好处也许是组织化了，模块带来的分离，正如你所见的，帮助你避免污染全局命名空间，减少命名冲突。

-----

现在你大概了解了模块的结构和优点。是时候正式构建模块了。对此我们的方法是非常有条理的。原因是之前提到的，javascript中的模块有非常奇怪的历史，即使有更新的方法在javascript中创建模块，你也会时不时的看到一些老的创建方式。如果模块从2018年开始，这个可能没有一点用处，也就是说，我们会回到2010年的```模块```时代。那时，angularjs刚刚发布，jquery还在大范围使用。大部分公司使用javascript去构建复杂的web应用，而管理这些复杂的工具就是--模块。

创建模块的第一个想法可能就是用文件分离代码。

```javascript
// users.js
var users = ['Tyler', 'Sarah', 'Dan'];

function getUsers() {
    return users;
}

// dom.js
function addUserToDom(name) {
    var node = document.createElement('li');
    var text = document.createTextNode(name);
    node.appendChild(text);
    
    document.getElementById('users').appendChild(node);
}

document.getElementById('submit')
    .addEventListener('click', function() {
        var input = document.getElementById('input');
        addUserToDom(input.value);
        input.value = '';
});

var users = window.getUsers();
for (var i = 0; i < users.length; i++) {
    addUserToDom(users[i]);
}
```
```html
<!-- index.html -->
<html>
  <head>
    <title>Users</title>
  </head>

  <body>
    <h1>Users</h1>
    <ul id="users"></ul>
    <input
      id="input"
      type="text"
      placeholder="New User">
    </input>
    <button id="submit">Submit</button>

    <script src="users.js"></script>
    <script src="dom.js"></script>
  </body>
</html>
```

[这里](https://github.com/tylermcginnis/modules/tree/separate-files)查看全部源代码

ok，我们成功的将app分离成不同的功能文件，是不是意味着我们已经实现了模块？不，绝对没有。我们做的只不过是分离代码所在的位置。在js中，只有创建函数才能生成新的作用域。我们未在函数中生命的变量，全都在全局对象上。也就是说，你可以访问他们通过```window```对象。你会注意到我们可以访问到，这是糟糕的。因为当我们更改一些方法时，其实就是在改变我们整个app。我们没有分离我们的代码到模块，只是在物理位置上分离了代码。如果刚开始学习javascript，这个结果可能令你惊讶，不过，这可能是你能想到在js中如何实现模块化的第一个想法。
那么，如果分享分离没有给我们提供模块的功能，那我们要怎么做呢？重复强调一下模块的优点:复用性、组合型、利用性、隔离性还有可组织性。js有没有原始的特性以供我们创造模块，以达到上面说的优点？常规函数？当你思考函数的特点，它的特点和模块优点相似。所以，接下来该怎么做呢？如果我们暴露一个对象来替代直接把整个app暴露在全局对象下，并且命名这个对象为```app```，我们可以吧所有我们app需要用到的方法，挂在在这个```app```对象下。这样会防止我们污染全局变量。我们可以在里面放置任何东西，这样对于其他应用来说依然是不可见得。

```javascript
// users.js
function usersWrapper () {
  var users = ["Tyler", "Sarah", "Dan"]

  function getUsers() {
    return users
  }

  APP.getUsers = getUsers
}

usersWrapper()

// dom.js

function domWrapper() {
  function addUserToDOM(name) {
    const node = document.createElement("li")
    const text = document.createTextNode(name)
    node.appendChild(text)

    document.getElementById("users")
      .appendChild(node)
  }

  document.getElementById("submit")
    .addEventListener("click", function() {
      var input = document.getElementById("input")
      addUserToDOM(input.value)

      input.value = ""
  })

  var users = APP.getUsers()
  for (var i = 0; i < users.length; i++) {
    addUserToDOM(users[i])
  }
}

domWrapper()
```

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
  <head>
    <title>Users</title>
  </head>

  <body>
    <h1>Users</h1>
    <ul id="users"></ul>
    <input
      id="input"
      type="text"
      placeholder="New User">
    </input>
    <button id="submit">Submit</button>

    <script src="app.js"></script>
    <script src="users.js"></script>
    <script src="dom.js"></script>
  </body>
</html>
```

[这里](https://github.com/tylermcginnis/modules/tree/wrappers)查看全部源代码

现在你查看window对象，相比于，只有我们的```app```对象，和我们的包裹函数：```userWrapper```、```domWrapper```。更重要的是，app中非常重要的代码（比如```users```）变得不可更改了。因为它不在在全局环境下了。

让我们更进一步。有没有办法可以丢弃包裹函数？我们只是定义了它们，然后立即调用。给他们一个全局命名的唯一原因就是我们之后可以立即调用它们。如果我们没有给他们全局命名，有没有办法直接直接调用没有名字（匿名）的函数。不卖关子了，当然有了，就是```Immediately Invoked Function Expression```，简写为```IIFE```。

#### IIFE

它看起来像下面这样：
```javascript
(function() {
    console.log('Pronounced IF-EE');
})()
```
注意，这仅仅是一个被小括号```()```包起来的匿名函数。
```javascript
(function() {
    console.log('Pronounced IF-EE');
})
```
然后，就像其他函数一样，为了调用函数，我们增加了一对小括号在函数而最后。
```javascript
(function() {
    console.log('Pronounced IF-EE');
})()
```
现在，为了放弃丑陋的包裹函数和干净的全局命名空间让我们来使用```IIFE```来更新一下代码。

```javascript
// users.js

(function () {
  var users = ["Tyler", "Sarah", "Dan"]

  function getUsers() {
    return users
  }

  APP.getUsers = getUsers
})()

// dom.js

(function () {
  function addUserToDOM(name) {
    const node = document.createElement("li")
    const text = document.createTextNode(name)
    node.appendChild(text)

    document.getElementById("users")
      .appendChild(node)
  }

  document.getElementById("submit")
    .addEventListener("click", function() {
      var input = document.getElementById("input")
      addUserToDOM(input.value)

      input.value = ""
  })

  var users = APP.getUsers()
  for (var i = 0; i < users.length; i++) {
    addUserToDOM(users[i])
  }
})()
```
[这里](https://github.com/tylermcginnis/modules/tree/IIFEs)查看全部源代码

么么哒。现在你在查看window对象，你会发现，我们仅仅挂在了一个app对象在上面，他将作为全局方法的命名空间。

这就是IIFE模块模式。

IIFE模块模式有什么优点呢？首先，最重要的一点是，我们没有污染全局命名空间，这避免了变量冲突，并且提供代码私有性。有利就有弊，我们仍然有一个全局app变量，如果其他框架使用了相同的代码，我们就有麻烦了。第二点，你可能主要到了html文件中的script的顺序，如果顺序不对，那么app直接会挂掉。
不过，就算这不是最完美的。我们依然进步了一大块。我们知道了IIFE模块模式的优点和缺点。如果我们用我们的标准创建并管理模块，它有哪些特性呢？

早些时候，我们对模块分离的第一感觉每个文件都是一个新的模块。就算这种想法在js中不是开箱就用的。我认为对模块来说这是一个非常显著的分离。每个文件就是一个单独的模块，然后我们需要一个特性是每个文件（模块）都能定义自己的导入和导出。并可在其他文件（模块）中导入。

#### 我们的标准

- 基于文件的模块
- 明确的导入
- 明确的导出

现在，我们明确了我们想要的标准，让我们开始开发api。我们需要定义的看起来像是```imports```和```exports```，从exports开始。为了保证更好理解，任何和module相关的我们都称之为```module```对象。然后，我们想从模块导出的内容都放在```module.exports```上，就像下面这样：

```javascript
var users = ["Tyler", "Sarah", "Dan"]

function getUsers() {
  return users
}

module.exports.getUsers = getUsers
```

也可以这样：

```javascript
var users = ["Tyler", "Sarah", "Dan"]

function getUsers() {
  return users
}

module.exports = {
  getUsers: getUsers
}
```

不管有多少个方法，我们都可以添加到```exports```对象上：

```javascript
// users.js

var users = ["Tyler", "Sarah", "Dan"]

module.exports = {
  getUsers: function () {
    return users
  },
  sortUsers: function () {
    return users.sort()
  },
  firstUser: function () {
    return users[0]
  }
}
```

好了，我们解决了如何从模块导出，接下来我们需要解决如何导入。同样一切从简，首先假设我们有一个叫做```require```的函数，它接受一个字符串路径作为第一个参数，然后返回从这个路径下导出的所有内容。接着上面的user.js文件，引入的方式像这样：

```javascript
var users = require('./users')

users.getUsers() // ["Tyler", "Sarah", "Dan"]
users.sortUsers() // ["Dan", "Sarah", "Tyler"]
users.firstUser() // ["Tyler"]
```

哦耶~ 利用假象的```module.exports```和```require```语法，我们不仅保留了模块的所有优点，还摆脱了IIFE模块模式的缺点。舒服。

看完这个标准，有没有灵光一现？这tm不就是commonjs吗？

commonjs小组定义了模块模式去解决js作用域问题，以确保每个模块在他们自己的命名空间执行。通过模块明确导出那些变量来实现，通过其他模块定义的require来正确工作。
如果你之前使用过node，conmonjs你会很熟悉。使用node，你可以开箱即用的使用require和module.exports语法，不过，浏览器并未支持。事实上，就算浏览器支持，浏览器也不会使用commonjs，因为它不是异步加载模块。众所周知，浏览器是单线程。异步才是王道。
简单总结一下，commonjs有两个问题，首先浏览器不支持，第二，浏览器就算支持了也会因为commonjs的同步加载造成很糟糕的用户体验。如果我们能修复这两个问题，这也许是一个好的方案。不过，花费很多的时间去考虑研究commonjs是否对浏览器足够友好有没有意义呢？不管怎么样，这有一个新的解决方案，它叫做模块打包器。

#### 模块打包器

模块打包器的作用是检查你的代码库。寻找所有的imports和exports，然后解析打包成浏览器可以明白的代码到一个单独的新文件。而且你不再用小心翼翼的引入所有script，你应该直接引入打包好的那个文件。

app.js ---> | 
users.js -> | Bundler | -> bundle.js
dom.js ---> | 

所以，模块打包器到底做了什么捏？这个问题很大，我也不能全部解释清楚，不过，这有一个通过webpack打包之后的输出，你可以自己领悟领悟，哈哈。

[这里](https://github.com/tylermcginnis/modules/tree/commonjs)查看所有源代码，你也可以下载下来，执行 npm install，然后执行webpack


```javascript
(function(modules) { // webpackBootstrap
  // 模块缓存
  var installedModules = {};
  // require函数
  function __webpack_require__(moduleId) {
    // 检查module是否有缓存
    if(installedModules[moduleId]) {
      return installedModules[moduleId].exports;
    }
    // 创建一个module并缓存
    var module = installedModules[moduleId] = {
      i: moduleId,
      l: false,
      exports: {}
    };
    // 执行module
    modules[moduleId].call(
      module.exports,
      module,
      module.exports,
      __webpack_require__
    );
    // 设置module为已load
    module.l = true;
    // 返回模块的导出
    return module.exports;
  }
  // 暴露模块对象
  __webpack_require__.m = modules;
  // 暴露模块缓存
  __webpack_require__.c = installedModules;
  // 定义getter函数
  __webpack_require__.d = function(exports, name, getter) {
    if(!__webpack_require__.o(exports, name)) {
      Object.defineProperty(
        exports,
        name,
        { enumerable: true, get: getter }
      );
    }
  };
  // 在导出中定义__esModule
  __webpack_require__.r = function(exports) {
    if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
      Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
    }
    Object.defineProperty(exports, '__esModule', { value: true });
  };
  // 创建假的命名空间对象
  // mode & 1: value是模块id，通过它引入
  // mode & 2: 合并所有属性到ns对象上
  // mode & 4: ns已经存在时，直接返回
  // mode & 8|1: 行为和require一样
  __webpack_require__.t = function(value, mode) {
    if(mode & 1) value = __webpack_require__(value);
    if(mode & 8) return value;
    if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
    var ns = Object.create(null);
    __webpack_require__.r(ns);
    Object.defineProperty(ns, 'default', { enumerable: true, value: value });
    if(mode & 2 && typeof value != 'string')
      for(var key in value)
        __webpack_require__.d(ns, key, function(key) {
          return value[key];
        }.bind(null, key));
    return ns;
  };
  // getDefaultExport function for compatibility with non-harmony modules
  __webpack_require__.n = function(module) {
    var getter = module && module.__esModule ?
      function getDefault() { return module['default']; } :
      function getModuleExports() { return module; };
    __webpack_require__.d(getter, 'a', getter);
    return getter;
  };
  // Object.prototype.hasOwnProperty.call
  __webpack_require__.o = function(object, property) {
      return Object.prototype.hasOwnProperty.call(object, property);
  };
  // __webpack_public_path__
  __webpack_require__.p = "";
  // Load entry module and return exports
  return __webpack_require__(__webpack_require__.s = "./dom.js");
})
/************************************************************************/
({

/***/ "./dom.js":
/*!****************!*\
  !*** ./dom.js ***!
  \****************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

eval(`
  var getUsers = __webpack_require__(/*! ./users */ \"./users.js\").getUsers\n\n
  function addUserToDOM(name) {\n
    const node = document.createElement(\"li\")\n
    const text = document.createTextNode(name)\n
    node.appendChild(text)\n\n
    document.getElementById(\"users\")\n
      .appendChild(node)\n}\n\n
    document.getElementById(\"submit\")\n
      .addEventListener(\"click\", function() {\n
        var input = document.getElementById(\"input\")\n
        addUserToDOM(input.value)\n\n
        input.value = \"\"\n})\n\n
        var users = getUsers()\n
        for (var i = 0; i < users.length; i++) {\n
          addUserToDOM(users[i])\n
        }\n\n\n//# sourceURL=webpack:///./dom.js?`
);}),

/***/ "./users.js":
/*!******************!*\
  !*** ./users.js ***!
  \******************/
/*! no static exports found */
/***/ (function(module, exports) {

eval(`
  var users = [\"Tyler\", \"Sarah\", \"Dan\"]\n\n
  function getUsers() {\n
    return users\n}\n\nmodule.exports = {\n
      getUsers: getUsers\n
    }\n\n//# sourceURL=webpack:///./users.js?`);})
});
```

你可以注意到有很多奇奇怪怪的代码，你可以阅读注释来简单了解一下到底发生了什么。但是，一个很有趣的事是，打包后的代码用一个IIFE包裹起来了。也就是说，他们使用了IIFE模块模式得到了一个相对来说最完美的方案。

javascript的未来是一个活生生的，丰满的语言。TC-31标准委员会，一年内多次讨论如何潜在改善提高javascript语言。换言之，模块是编写可伸缩性、可维护的js代码的关键特性。在2013年甚至更早之前，这种说法很显然是不存在的。js需要一种模块的标准。一种内建的可处理模块的解决方法，这也拉开了实现js模块化的序幕。

如你现在所知道的。如果你之前接受过创建js系统模块的任务，这个模块最终看起来将是什么样的？commonjs？每个文件以一种很清晰的方式定义导入和导出，很显然，这个是重中之重。但是有个问题，commonjs加载模块是同步的。虽然这对服务端没有压力，但是对浏览器不是很友好。一个改变是让commonjs支持异步加载，另一种我们使用语言自己的模块化，也就是```import```和```export```。

这次，我们不需要再假想这种实现了，TC-39标准委员会提出了精确的设计和描述，也就是"ES Modules"。下面让我们以这种标准化的模块创建javascript模块。

#### EM Modules
正如上面所说的，为了指定你要导出的模块，你需要使用```export```关键字。

```javascript
// utils.js

// Not exported
function once(fn, context) {
	var result
	return function() {
		if(fn) {
			result = fn.apply(context || this, arguments)
			fn = null
		}
		return result
	}
}

// Exported
export function first (arr) {
  return arr[0]
}

// Exported
export function last (arr) {
  return arr[arr.length - 1]
}
```

有几种方式可以导入```first```和```last```方法，一种是导入所有从```urils.js```导出的。

```javascript
import * as utils from './utils'

utils.first([1,2,3]) // 1
utils.last([1,2,3]) // 3
```

如果我们不想导入全部导出呢？在这个例子中，如果你只想引入```first```方法，你能使用一种叫做命名导入的办法（看起来很想解构，但其实不是哈）。

```javascript
import { first } from './utils'

first([1,2,3]) // 1
```

还有呢，不仅仅可以指定多个导出，你还可以指定一个```default```导出。

```javascript
// leftpad.js

export default function leftpad (str, len, ch) {
  var pad = '';
  while (true) {
    if (len & 1) pad += ch;
    len >>= 1;
    else break;
  }
  return pad + str;
}
```

当你使用```default```导出这种方式，你的导入方式也会发生变化，代替使用*或者使用命名导入，你可以使用```import name from './patn'```

```javascript
import leftpad from './leftpad'
```

现在，如果你有默认导出，也有其他格式的导出怎么办呢？这不是问题，按照正确的语法写就可以了，ES Module没有这种限制。

```javascript
// utils.js

function once(fn, context) {
	var result
	return function() {
		if(fn) {
			result = fn.apply(context || this, arguments)
			fn = null
		}
		return result
	}
}

// regular export
export function first (arr) {
  return arr[0]
}

// regular export
export function last (arr) {
  return arr[arr.length - 1]
}

// default export
export default function leftpad (str, len, ch) {
  var pad = '';
  while (true) {
    if (len & 1) pad += ch;
    len >>= 1;
    else break;
  }
  return pad + str;
}
```

那导入语法看起来是什么样的？我觉得你可以想象得到。

```javascript
import leftpad, { first, last } from './utils'
```

还是挺爽的是吧？```leftpad```是默认导出，```first```和```last```是常规导出。
ES Modules的关键点在于，它是js语言的一部分，并且现代浏览器已经支持这种写法了。现在，让我们回到一开始的app，不过这次我们使用ES Modules来改写一遍。

[这里](https://github.com/tylermcginnis/modules/tree/esModules)查看所有源代码

```javascript
// users.js

var users = ["Tyler", "Sarah", "Dan"]

export default function getUsers() {
  return users
}

// dom.js

import getUsers from './users.js'

function addUserToDOM(name) {
  const node = document.createElement("li")
  const text = document.createTextNode(name)
  node.appendChild(text)

  document.getElementById("users")
    .appendChild(node)
}

document.getElementById("submit")
  .addEventListener("click", function() {
    var input = document.getElementById("input")
    addUserToDOM(input.value)

    input.value = ""
})

var users = getUsers()
for (var i = 0; i < users.length; i++) {
  addUserToDOM(users[i])
}
```

使用IIFE模式，我们需要使用script引入每个js文件。使用commonjs，我们需要使用webpack等打包器处理我们的代码，然后引入打包后的文件。而ES Modules中，在一些现在浏览器中，我们仅仅需要使用script标签引入我们的未被处理过的入口文件，然后为script标签增加属性:```typr='module'```。


```html
<!DOCTYPE html>
<html>
  <head>
    <title>Users</title>
  </head>

  <body>
    <h1>Users</h1>
    <ul id="users">
    </ul>
    <input id="input" type="text" placeholder="New User"></input>
    <button id="submit">Submit</button>

    <script type=module src='dom.js'></script>
  </body>
</html>
```

#### 死代码消除

到这里，还有一个commonjs与ES Modules的不同没有介绍。
commonjs中，你可以在任何地方引入模块，甚至通过判断。

```javascript
if (pastTheFold === true) {
  require('./parallax')
}
```

ES Modules需要静态解析（参考js词法解析，也会有提升的效果）的，import语句必须在模块顶部，也就是说，他不能再判断语句中或者其他类似的语句中使用。

```javascript
if (pastTheFold === true) {
  import './parallax' // "import' and 'export' may only appear at the top level"
}
```

这是因为加载器会进行模块树的静态解析。找到那些真正被用到的，丢弃那些未被使用到的。这是一个很大的话题。换句话说，这也是为什么ES Modules希望你声明import语句在模块顶部，这样打包器会更快的解析的你依赖树，解析完毕，他才会去真正的工作。

对了，其实你可以使用```import()```来动态导入。请自行查找。

希望通过这篇文章可以帮到你。

[原文链接](https://tylermcginnis.com/javascript-modules-iifes-commonjs-esmodules/)

------

- script标签上加上```type='module'```的加载模式都是```defer```。
- IIFE：匿名函数
- AMD：依赖前置异步模块加载
- CMD：就近依赖异步模块加载
- commonjs(cjs)：服务端通用的模块加载
- UMD：不是单独的标准，是IIFE、AMD(CMD)、commonjs的结合。
- es：js自己的模块打包

| 标准 | 变量问题 |  依赖  |  动态/懒 加载  | 静态分析  |
|--------|--------|--------|--------|--------|
|  IIFE  |  ✔  |  ×  |  ×  |  ×  |
|  AMD  |  ✔  |  ✔  |  ✔  |  ×  |
|  CMD  |  ✔  | ✔  |  ✔  |  ×  |
|  commonjs  |  ✔  |  ✔  |  ✔  |  ×  |
|  es6  |  ✔  |  ✔  |  ✔  |  ✔  |

再强调一点：es6的模块是值的引用，commonjs是值的拷贝。[参考文章](https://zhuanlan.zhihu.com/p/33843378)