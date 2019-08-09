---
title:  分析babel的输出
date: 2019-08-09 12:00
tags: frontend
categories: 解析
---


```javascript
  (function(modules) {
    // 缓存对象
    var installedModules = {};

    // require方法
    function __webpack_require__(moduleId) {
        // 是否命中缓存
        if (installedModules[moduleId]) {
            return installedModules[moduleId].exports;
        }
        // 新建 + 缓存
        var module = (installedModules[moduleId] = {
            i: moduleId,
            l: false,
            exports: {}
        });

        // 执行module方法
        modules[moduleId].call(
            module.exports,
            module,
            module.exports,
            __webpack_require__
        );

        // 标志是否已加载模块，之后缓存里会走
        module.l = true;

        return module.exports;
    }

    // expose the modules object (__webpack_modules__)
    __webpack_require__.m = modules;

    // expose the module cache
    __webpack_require__.c = installedModules;


    // 设置commonjs导出的对象上的a的值
    __webpack_require__.d = function(exports, name, getter) {
        if (!__webpack_require__._hasOwnProperty(exports, name)) {
            // 利用 getter 可以通过a获取到module的值
            Object.defineProperty(exports, name, {
                enumerable: true,
                get: getter
            });
        }
    };

    // 定义 __esModule 标志
    __webpack_require__.r = function(exports) {
        if (typeof Symbol !== 'undefined' && Symbol.toStringTag) {
            Object.defineProperty(exports, Symbol.toStringTag, {
                value: 'Module'
            });
        }
        Object.defineProperty(exports, '__esModule', {value: true});
    };

    // 适配commonjs规范
    // 导出的为 require.a => 执行 getter函数 获得导出的内容
    __webpack_require__.n = function(module) {
        var getter =
            module && module.__esModule
                ? function getDefault() {
                      return module['default'];
                  }
                : function getModuleExports() {
                      return module;
                  };
        __webpack_require__.d(getter, 'a', getter);
        return getter;
    };

    // Object.prototype.hasOwnProperty.call
    __webpack_require__._hasOwnProperty = function(object, property) {
        return Object.prototype.hasOwnProperty.call(object, property);
    };
})({})
```
概述下上面打包后的代码，是一个立即执行函数，接受的参数是一个对象，对象的key为引入的模块路径，对应的value为导出的内容，不过babel会根据ejs or cjs来进行不同的适配导出。
iife函数内为：
1. installedModules 闭包环境缓存模块对象
2. __webpack_require__ 变种的require方法
3. __webpack_require__.d 适配commonjs的转换方法
4. __webpack_require__.r 给babel转换的es6模块增加标志，也就是通过该方法来设置区分ejs 和 cjs的标志
5. __webpack_require_.n 根据 __esModule 导出


举例说明:

我们有以下几个文件，内容都很简单。
```javascript
// es6.js
export default {
    type: 'esjs'
}
```

```javascript
// commonjs.js
module.exports = {
    type: 'commonjs'
}
```

```javascript
// index.js
import es6 from './es6';
import conmon from './commonjs';

console.log(require('./es6'));
console.log(es6, 'import来的');

console.log(require('./commonjs'));
console.log(conmon, 'import来的');
```

通过webpack打包后的输出内容我们只取上面iife函数的参数部分，并去掉eval来提升可读性。
```javascript
// bundle.js

(function(modules){
// ******
// 巴拉巴拉
// ******
    // Load entry module and return exports
    return __webpack_require__((__webpack_require__.s = './index.js'));
})({
    './commonjs.js': function(module, exports) {
        module.exports = {type: 'commonjs'};
    },
    './es6.js': function(module, __webpack_exports__, __webpack_require__) {
        __webpack_require__.r(__webpack_exports__);
        
        // 相当于 module.exports.default，这就是为什么我们require的时候，需要加上 .default
        __webpack_exports__['default'] = {
            type: 'esjs'
        };
    },
    './index.js': function(module, __webpack_exports__, __webpack_require__) {
        __webpack_require__.r(__webpack_exports__);
        var es6FromImport = __webpack_require__('./es6.js');
        var commonjsFromImport = __webpack_require__(
            './commonjs.js'
        );
        var commonjsFromImport_default = __webpack_require__.n(
            commonjsFromImport
        );
        console.log(__webpack_require__('./es6.js'));
        console.log(es6FromImport['default'], 'import来的');

        console.log(__webpack_require__('./commonjs.js'));
        console.log(
            commonjsFromImport_default.a,
            'import来的'
        );
    }
})
```
一点点分析，从入口开始 => __webpack_require__('./index.js')
首先会查看是否命中缓存，如果命中，那理所当然直接返回，否则进行新建 + 缓存的操作，边边角角直接略过，咱们看下面这个方法：
```javascript

  // 新建
  var module = (installedModules[moduleId] = {
      i: moduleId,
      l: false,
      exports: {} 
  });
  
  // 赋值
  modules[moduleId].call(
      module.exports,
      module,
      module.exports,
      __webpack_require__
  );
  
  // 导出
  return module.exports;
  
```
首先新建，并创建默认的导出对象，这也就说明了为什么文件没有导出，默认是{}的问题，然后，利用call传递函数执行上下文环境，并传入module, module.exports, __webpack_require__ 参数，最后return了module中的exports的值。

来看关键的赋值这一步。
针对es6js，因为你是export default，所以babel会增加一个__esModule变量，进行ejs的标识，因为我们导出的时候，会根据ejs规范，导出得对象赋值到default上，如下

```javascript
// 赋值 __esModule
__webpack_require__.r(__webpack_exports__);
__webpack_exports__['default'] = {
    type: 'esjs'
};
```
当我们使用ejs规范import的时候，babel会进行default的读取，所以我们可以直接获取到我们想要的值，然后如果你使用require的话，babel会按照commonjs直接进行读取，所以会导致我们需要 .default 才能拿到我们真正想要的值，结果如下

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190809213447.png)


针对cjs，由于使用cjs规范，所以我们的导出是不涉及default的，即
```javascript
    module.exports = { type: 'commonjs' }
```
其实我们直接导出即可，因为 __webpack_require__ 的返回值就是 module.exports。
不过打包后的代码用 __webpack_require__.n 对commonjs的导出做了处理，判断是否为 es6 规范的导出，如果是那么导出default，不是直接导出module.exports，然后使用 getter 设置返回函数的a属性，获取a属性即返回cjs module的导出，猜测这是对es6 import的统一处理。

```javascript
  // require
  var commonjsFromImport = __webpack_require__('./commonjs.js');
  // 设置getter
  var commonjsFromImport_default = __webpack_require__.n(commonjsFromImport);

  console.log(commonjsFromImport_default.a, 'import来的');
```

结果如下：

![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190809215548.png)


### 简单总结

require 对 ejs 规范的导出不是很友好，换句话说，考虑的很单一，所以会有default的问题
import 适配的 ejs 和 cjs，会根据 __esModule 进行导出的判断，返回使用者真正想要的

不过进步一认证，发现如果是ejs的导出，会直接导出__webpack_export__['default']，也就是 module.export.defualt，看起来不需要处理 __esModule 的请求，暂时还不清楚到底是怎么回事。有缘窃听下回分解吧。

具体babel是怎么解析的，暂时不涉及，只分析结果，得出一点点结论。




#### 小提示

类似这种的代码 (0, foo.bar)() 相当于 foo.bar.call(winodw|global|this)  改变执行时的上下文环境