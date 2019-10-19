---
title: snabbdom
tags: frendend
categories: 原理浅析
---

### 什么是虚拟 dom

总所周知，操作 dom 有性能成本，而损耗性能的关键就是操作过程中造成的重绘、重排，所以如果我们能减少重绘、重排，就能提升 web 性能，进而改善用户体验，虚拟 dom 也就这么产生了。

虚拟 dom 其实就是一个用来描述 Dom 节点的 json 对象，比如 snabbdom 中的声明是这样的：

```javascript
interface VNode {
  sel: string | undefined; // 选择器 tag + id + classnames，也是sameDom判断条件之一
  data: VNodeData | undefined; // 看下面
  children: Array<VNode | string> | undefined; // 子元素们(与text冲突)
  elm: Node | undefined; // Vnode对应的真实Dom
  text: string | undefined; // 子文本节点(与children冲突)
  key: Key | undefined; // sameDom判断条件之一
}
```

其中 VNodeData 如下：

```javascript
interface VNodeData {
  props?: Props;
  attrs?: Attrs;
  class?: Classes;
  style?: VNodeStyle;
  dataset?: Dataset;
  on?: On;
  hero?: Hero;
  attachData?: AttachData;
  hook?: Hooks;
  key?: Key;
  ns?: string; // for SVGs
  fn?: () => VNode; // for thunks
  args?: Array<any>; // for thunks
  [key: string]: any; // for any other 3rd party module
}
```

上面的结构就是一个个虚拟 dom，东西少，很清晰，也正是因为这种结构的产生，进而衍生了服务端渲染，因为虚拟 dom 不依赖浏览器的 Dom 相关内容，所以可以在几乎任何环境下共存，搞不好以后还能出个 css 同构呢。

剩下的就是如果操作虚拟 dom，进而刷新浏览器的 ui，snabbdom 中，核心方法暂且说成两个，一个是 patch， 一个是 h。

### 方法解析

#### h

一个用来生成 Vnode 的方法，snabble 中定义了使用案例

```javascript
function h(sel: string): VNode;
function h(sel: string, data: VNodeData): VNode;
function h(sel: string, children: VNodeChildren): VNode;
function h(sel: string, data: VNodeData, children: VNodeChildren): VNode;
```

方法内的内容很比较简单，通过对函数参数个数的判断，来取到对应的所需参数，然后调用 Vnode 方法，返回创建的 Vnode 实例。

```javascript
function vnode(
  sel: string | undefined,
  data: any | undefined,
  children: Array<VNode | string> | undefined,
  text: string | undefined,
  elm: Element | Text | undefined
): VNode {
  let key = data === undefined ? undefined : data.key;
  return { sel, data, children, text, elm, key };
}
```

#### patch

功能主要是三个，比对两个 Vnode 的差异，然后赋值 Vnode.elm 和更新到 html 上，并调用注入的全局钩子

- 比较 Vnode 的差异
  使用的是 updateChildren，该方法值取新的和旧的 Vnode 的 child 的 startIdx 和 endIdx，然后进行同级别的比较，之所以这么做是因为对于浏览器的场景是适用的，具体细节不啰嗦，也有很多分享，建议自己去看代码，最后我会把带有注释的代码贴上来，做下记录和分享。
- 赋值并更新 html
  这块更简单了，就是调用 createElm 方法，然后赋值给 Vnode，之后调用 htmldomapi 里面封装好的各种 DOM 操作方法，进行 dom 的增删改查，updateChildren 中也有一些增删改查的操作。
- 调用全局钩子
  这里的钩子是 snabbdom.bound.js 中挂载的，将 用于操作Vnode.data上属性的钩子方法 挂载到 snabbdom.js 中

```javascript
// snabbdom.bound.js
var patch = init([ // Init patch function with choosen modules
  attributesModule,
  classModule,
  propsModule,
  styleModule,
  eventListenersModule
]) as (oldVNode: any, vnode: any) => any;

// attributesModule.js
export const attributesModule = {create: updateAttrs, update: updateAttrs} as Module;
```

```javascript
// snabbdom.js

// 全局钩子们
const hooks: (keyof Module)[] = [
  "create",
  "update",
  "remove",
  "destroy",
  "pre",
  "post"
];
// 声明全局容器
let cbs = {} as ModuleHooks;
    // 循环hooks
    for (i = 0; i < hooks.length; ++i) {
        // 设置cbs的keys，对应value是数组
        cbs[hooks[i]] = [];
        for (j = 0; j < modules.length; ++j) {
            // 取modules中的每一项中的当前钩子，然后全部push到cbs中的对应key中
            const hook = modules[j][hooks[i]];
            if (hook !== undefined) {
                (cbs[hooks[i]] as Array<any>).push(hook);
            }
        }
    }
```

### typescript类型学习

```javascript
function fn (modules: Array<Partial<Module>>){}
// 首先 <> 是泛型，所以 Array<>代表是一个数组的类型
// 其次Partial代表 => type Partial<T> = { [P in keyof T]?: T[P] | undefined; }
// 此处只能卧槽并配以一个demo来解释一下，其中Module是对象，如下
//   {
//     可选的Module中的key?: module当前key对应的value | undefined
//   },
//   ...
// 上面就是Partial代表的意思，大白话解释一下就是，遍历xxx，key为其中的每一个值，因为有问号，所以转换可选，即不一定必须与xxx中的key一一对应，对应value是可选的

// 整个连起来就是: Array<Partial<Module>> => 

// [
//   {
//     可选的Module中的key: module当前key对应的value | undefined
//   },
//   ...
// ]
```


### snabbdom.js 注释版(不是很长，但是注释比较随性，所以看起来可能不是很舒服)

```javascript
/* global module, document, Node */
// 钩子函数的type和interface
import { Module } from "./modules/module";
// 定义了一些type和interface
import { Hooks } from "./hooks";
import vnode, { VNode, VNodeData, Key } from "./vnode";
import * as is from "./is";
import htmlDomApi, { DOMAPI } from "./htmldomapi";

function isUndef(s: any): boolean {
  return s === undefined;
}
function isDef(s: any): boolean {
  return s !== undefined;
}

type VNodeQueue = Array<VNode>;

const emptyNode = vnode("", {}, [], undefined, undefined);

// 通过 key 和 选择器 判断说相同
function sameVnode(vnode1: VNode, vnode2: VNode): boolean {
  return vnode1.key === vnode2.key && vnode1.sel === vnode2.sel;
}

function isVnode(vnode: any): vnode is VNode {
  return vnode.sel !== undefined;
}

type KeyToIndexMap = { [key: string]: number };

type ArraysOf<T> = {
  [K in keyof T]: (T[K])[];
};

// Module {
//   pre: PreHook;
//   create: CreateHook;
//   update: UpdateHook;
//   destroy: DestroyHook;
//   remove: RemoveHook;
//   post: PostHook;
// }

// type[] => [a: type, b: type, ...]
type ModuleHooks = ArraysOf<Module>;
// ModuleHooks => {
//   pre: [prefn1, prefn2],
//   ...
// }

// 遍历 child Vnodes 返回一个 键为 key value 的当前 索引的 对象
function createKeyToOldIdx(
  children: Array<VNode>,
  beginIdx: number,
  endIdx: number
): KeyToIndexMap {
  let i: number,
    map: KeyToIndexMap = {},
    key: Key | undefined,
    ch;
  for (i = beginIdx; i <= endIdx; ++i) {
    ch = children[i];
    if (ch != null) {
      key = ch.key;
      if (key !== undefined) map[key] = i;
    }
  }
  return map;
}

const hooks: (keyof Module)[] = [
  "create",
  "update",
  "remove",
  "destroy",
  "pre",
  "post"
];

export { h } from "./h";
export { thunk } from "./thunk";

// 首先 Array<Partial<Module>> 中的 <> 是泛型，其次 Partial<xxx> 是关键字，相当于 [key in keyof xxx]?: xxx[key] | undefined，
// 大白话解释一下就是，遍历xxx，key为其中的每一个值，因为有问号，所以转换可选，即不一定必须与xxx中的key一一对应，对应value是可选的
// 所以Array<Partial<Module>>的意思就是
// [
//   {
//     可选的Module中的key: module当前key对应的value | undefined
//   },
//   ...
// ]
export function init(modules: Array<Partial<Module>>, domApi?: DOMAPI) {
  // as 或者 <> 表明编码者明确知道该变量的类型，并指定
  let i: number,
    j: number,
    cbs = {} as ModuleHooks;

  // 获取操作dom的所有api
  const api: DOMAPI = domApi !== undefined ? domApi : htmlDomApi;

  for (i = 0; i < hooks.length; ++i) {
    // cb[hooks中的每一个] = []
    cbs[hooks[i]] = [];
    // modules:
    // [{
    //   create: fn
    // }]
    // 遍历modules，将数组的每一项(key为hooks其一)中的每一项统一添加到cbs中
    // 结果为 cbs
    // {
    //   create: [fn1, fn2]
    // }
    for (j = 0; j < modules.length; ++j) {
      // 判断传入的参数modules中有没有当前hooks，有的话则push
      const hook = modules[j][hooks[i]];
      if (hook !== undefined) {
        (cbs[hooks[i]] as Array<any>).push(hook);
      }
    }
  }

  // 返回vnode描述
  function emptyNodeAt(elm: Element) {
    const id = elm.id ? "#" + elm.id : "";
    const c = elm.className ? "." + elm.className.split(" ").join(".") : "";
    return vnode(
      api.tagName(elm).toLowerCase() + id + c,
      {},
      [],
      undefined,
      elm
    );
  }

  // 通过childElm的父元素 移除childElm
  function createRmCb(childElm: Node, listeners: number) {
    return function rmCb() {
      if (--listeners === 0) {
        const parent = api.parentNode(childElm);
        api.removeChild(parent, childElm);
      }
    };
  }

  // 根据 vnode 创建真实的 dom
  function createElm(vnode: VNode, insertedVnodeQueue: VNodeQueue): Node {
    // data 是 描述 DOM Node 节点的对象
    let i: any,
      data = vnode.data;
    if (data !== undefined) {
      if (isDef((i = data.hook)) && isDef((i = i.init))) {
        // 调用hooks的init方法
        i(vnode);
        data = vnode.data;
      }
    }
    // VNode的选择器，nodeName+id+class的组合
    let children = vnode.children,
      sel = vnode.sel;
    // 创建html注释
    if (sel === "!") {
      // <!-- <div></div> -->
      if (isUndef(vnode.text)) {
        vnode.text = "";
      }
      vnode.elm = api.createComment(vnode.text as string);
    } else if (sel !== undefined) {
      /* 如果有选择器 */ // Parse selector
      // 获取id的索引值
      const hashIdx = sel.indexOf("#");
      // 从id的索引位置开始，或许class的索引值
      const dotIdx = sel.indexOf(".", hashIdx);
      // 如果有id或class那么返回对应的索引，否则为长度
      const hash = hashIdx > 0 ? hashIdx : sel.length;
      const dot = dotIdx > 0 ? dotIdx : sel.length;
      // 获取dom的tagname
      const tag =
        hashIdx !== -1 || dotIdx !== -1
          ? sel.slice(0, Math.min(hash, dot))
          : sel;
      // 创建真实的el或者elns，赋值给当前vnode的elm属性上，又赋值给elm，因为是对象，所以是引用类型，可以在之后直接使用
      const elm = (vnode.elm =
        isDef(data) && isDef((i = (data as VNodeData).ns))
          ? api.createElementNS(i, tag)
          : api.createElement(tag));

      // 设置  id  和 class
      if (hash < dot) elm.setAttribute("id", sel.slice(hash + 1, dot));
      if (dotIdx > 0)
        elm.setAttribute("class", sel.slice(dot + 1).replace(/\./g, " "));

      // 调用create hook
      for (i = 0; i < cbs.create.length; ++i) cbs.create[i](emptyNode, vnode);

      // 处理 dom 的子dom元素们
      if (is.array(children)) {
        for (i = 0; i < children.length; ++i) {
          const ch = children[i];
          if (ch != null) {
            api.appendChild(elm, createElm(ch as VNode, insertedVnodeQueue));
          }
        }
      } else if (is.primitive(vnode.text)) {
        api.appendChild(elm, api.createTextNode(vnode.text));
      }
      i = (vnode.data as VNodeData).hook; // Reuse variable
      if (isDef(i)) {
        if (i.create) i.create(emptyNode, vnode);
        if (i.insert) insertedVnodeQueue.push(vnode);
      }
    } /* 否则创建文本节点 */ else {
      vnode.elm = api.createTextNode(vnode.text as string);
    }
    // 返回创建后的 真实dom
    return vnode.elm;
  }

  // 插入Vnodes
  function addVnodes(
    parentElm: Node,
    before: Node | null,
    vnodes: Array<VNode>,
    startIdx: number,
    endIdx: number,
    insertedVnodeQueue: VNodeQueue
  ) {
    for (; startIdx <= endIdx; ++startIdx) {
      const ch = vnodes[startIdx];
      if (ch != null) {
        api.insertBefore(parentElm, createElm(ch, insertedVnodeQueue), before);
      }
    }
  }

  function invokeDestroyHook(vnode: VNode) {
    let i: any,
      j: number,
      data = vnode.data;
    if (data !== undefined) {
      // 调用Vnode的销毁hooks
      if (isDef((i = data.hook)) && isDef((i = i.destroy))) i(vnode);
      for (i = 0; i < cbs.destroy.length; ++i) cbs.destroy[i](vnode);
      // 递归子元素
      if (vnode.children !== undefined) {
        for (j = 0; j < vnode.children.length; ++j) {
          i = vnode.children[j];
          if (i != null && typeof i !== "string") {
            invokeDestroyHook(i);
          }
        }
      }
    }
  }

  function removeVnodes(
    parentElm: Node,
    vnodes: Array<VNode>,
    startIdx: number,
    endIdx: number
  ): void {
    // 循环remore传入的Vnodes
    for (; startIdx <= endIdx; ++startIdx) {
      let i: any,
        listeners: number,
        rm: () => void,
        ch = vnodes[startIdx];
      if (ch != null) {
        // 如果是有选择器
        if (isDef(ch.sel)) {
          invokeDestroyHook(ch);
          listeners = cbs.remove.length + 1;
          rm = createRmCb(ch.elm as Node, listeners);
          for (i = 0; i < cbs.remove.length; ++i) cbs.remove[i](ch, rm);
          if (
            isDef((i = ch.data)) &&
            isDef((i = i.hook)) &&
            isDef((i = i.remove))
          ) {
            i(ch, rm);
          } else {
            rm();
          }
        } else {
          // Text node
          api.removeChild(parentElm, ch.elm as Node);
        }
      }
    }
  }

  // updateChildren接受的第一个参数是oldVnode的elm，更新的就是这个elm，更新的结果elm还是旧的，不过里面的child发生了变化
  function updateChildren(
    parentElm: Node,
    oldCh: Array<VNode>,
    newCh: Array<VNode>,
    insertedVnodeQueue: VNodeQueue
  ) {
    // old child是待更新的vnode
    // 两个初始值为0的startindex
    let oldStartIdx = 0,
      newStartIdx = 0;

    // 如果长度为0，那么length - 1 为 -1，然后下面的while条件就不会通过了
    // 获取old child的长度
    let oldEndIdx = oldCh.length - 1;
    // 获取old child的第一个vnode
    let oldStartVnode = oldCh[0];
    // 获取old child的最后一个vnode
    let oldEndVnode = oldCh[oldEndIdx];
    // 获取new child的最后长度 => 也就是最后一个vnode的索引
    let newEndIdx = newCh.length - 1;
    // 获取new child的第一个vnode
    let newStartVnode = newCh[0];
    // 获取new child的最后一个vnode
    let newEndVnode = newCh[newEndIdx];

    let oldKeyToIdx: any;
    let idxInOld: number;
    let elmToMove: VNode;
    let before: any;

    /* ======while的开始====== */
    while (oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
      /* ======一个if的开始====== */
      // 获取old child的第一个Vnode
      if (oldStartVnode == null) {
        oldStartVnode = oldCh[++oldStartIdx]; // Vnode might have been moved left
      } else if (oldEndVnode == null) {
        /* 获取old child 最后一个Vnode */ oldEndVnode = oldCh[--oldEndIdx];
      } else if (newStartVnode == null) {
        /* 获取new child 第一个Vnode */ newStartVnode = newCh[++newStartIdx];
      } else if (newEndVnode == null) {
        /* 获取new child 最后一个Vnode */ newEndVnode = newCh[--newEndIdx];
        // 上面几步是获取合法的 old child 和 new child的第一个和最后一个Vnode
        // 下面进行old child 和 new chile 的更新，并更新 oldStartVnode 和 newStartVnode
        // ！！！！！！ 下面两个比较是同步推进，也就是说 正序 和 倒叙比较 new child 和 old child
      } else if (sameVnode(oldStartVnode, newStartVnode)) {
        patchVnode(oldStartVnode, newStartVnode, insertedVnodeQueue);
        oldStartVnode = oldCh[++oldStartIdx];
        newStartVnode = newCh[++newStartIdx];
      } else if (sameVnode(oldEndVnode, newEndVnode)) {
        /* 同上，不过对比的是最后一组Vnode */ patchVnode(
          oldEndVnode,
          newEndVnode,
          insertedVnodeQueue
        );
        oldEndVnode = oldCh[--oldEndIdx];
        newEndVnode = newCh[--newEndIdx];
      } else if (sameVnode(oldStartVnode, newEndVnode)) {
        /* 比较的是 old child 的第一个 和 new child的最后一个 */ // Vnode moved right
        patchVnode(oldStartVnode, newEndVnode, insertedVnodeQueue);
        api.insertBefore(
          parentElm,
          oldStartVnode.elm as Node,
          api.nextSibling(oldEndVnode.elm as Node)
        );
        oldStartVnode = oldCh[++oldStartIdx];
        newEndVnode = newCh[--newEndIdx];
      } else if (sameVnode(oldEndVnode, newStartVnode)) {
        /* 同上 */ // Vnode moved left
        patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue);
        api.insertBefore(
          parentElm,
          oldEndVnode.elm as Node,
          oldStartVnode.elm as Node
        );
        oldEndVnode = oldCh[--oldEndIdx];
        newStartVnode = newCh[++newStartIdx];
      } else {
        if (oldKeyToIdx === undefined) {
          // 获取childVnodes中的 每一个key对应的位置
          oldKeyToIdx = createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx);
        }
        // 获取new的Vnode的位置(索引)
        idxInOld = oldKeyToIdx[newStartVnode.key as string];

        if (isUndef(idxInOld)) {
          // New element
          api.insertBefore(
            parentElm,
            createElm(newStartVnode, insertedVnodeQueue),
            oldStartVnode.elm as Node
          );
          newStartVnode = newCh[++newStartIdx];
        } else {
          elmToMove = oldCh[idxInOld];
          if (elmToMove.sel !== newStartVnode.sel) {
            api.insertBefore(
              parentElm,
              createElm(newStartVnode, insertedVnodeQueue),
              oldStartVnode.elm as Node
            );
          } else {
            patchVnode(elmToMove, newStartVnode, insertedVnodeQueue);
            oldCh[idxInOld] = undefined as any;
            api.insertBefore(
              parentElm,
              elmToMove.elm as Node,
              oldStartVnode.elm as Node
            );
          }
          newStartVnode = newCh[++newStartIdx];
        }
      }
      /* ======一个if的结束====== */
    }
    /* ======while的结束====== */

    // 这两个 || 代表  至少长度为1，因为如果为0的话 endIdx 为 -1， -1 不会小于等于0，也就是说
    // old child 或者 new child 至少一个长度部位0，如果满足的话进入if
    if (oldStartIdx <= oldEndIdx || newStartIdx <= newEndIdx) {
      // 如果old child为空数组，也就是没有child(不代表没有Text)
      if (oldStartIdx > oldEndIdx) {
        before = newCh[newEndIdx + 1] == null ? null : newCh[newEndIdx + 1].elm;
        addVnodes(
          parentElm,
          before,
          newCh,
          newStartIdx,
          newEndIdx,
          insertedVnodeQueue
        );
      } else {
        removeVnodes(parentElm, oldCh, oldStartIdx, oldEndIdx);
      }
    }
  }

  /* ==========patchVnode开始========== */
  function patchVnode(
    oldVnode: VNode,
    vnode: VNode,
    insertedVnodeQueue: VNodeQueue
  ) {
    let i: any, hook: any;

    // 如果有，那么获取vnode.data中的 prepatch(patch前的钩子函数)
    if (
      isDef((i = vnode.data)) &&
      isDef((hook = i.hook)) &&
      isDef((i = hook.prepatch))
    ) {
      i(oldVnode, vnode);
    }

    const elm = (vnode.elm = oldVnode.elm as Node);
    // 旧的子dom们
    let oldCh = oldVnode.children;
    // 新的子dom们
    let ch = vnode.children;

    // 引用类型的(指针)判断相等
    if (oldVnode === vnode) return;

    if (vnode.data !== undefined) {
      for (i = 0; i < cbs.update.length; ++i) cbs.update[i](oldVnode, vnode);
      i = vnode.data.hook;
      if (isDef(i) && isDef((i = i.update))) i(oldVnode, vnode);
    }

    // 如果 不是text 类型
    if (isUndef(vnode.text)) {
      // 如果新旧vnode都有child
      if (isDef(oldCh) && isDef(ch)) {
        // 并且不相等
        if (oldCh !== ch)
          // 进行更新
          updateChildren(
            elm,
            oldCh as Array<VNode>,
            ch as Array<VNode>,
            insertedVnodeQueue
          );
      } else if (isDef(ch)) {
        /* new child 有子节点 old child 没有 */ if (isDef(oldVnode.text))
          api.setTextContent(elm, "");
        // 直接新增
        addVnodes(
          elm,
          null,
          ch as Array<VNode>,
          0,
          (ch as Array<VNode>).length - 1,
          insertedVnodeQueue
        );
      } else if (isDef(oldCh)) {
        /* old child有子节点，new child 没有 */ // 直接删除
        removeVnodes(
          elm,
          oldCh as Array<VNode>,
          0,
          (oldCh as Array<VNode>).length - 1
        );
      } else if (isDef(oldVnode.text)) {
        /* 新旧都没有子节点 */ // 通过textContent设置文本内容，textContent本身会防止XSS攻击
        // https://developer.mozilla.org/zh-CN/docs/Web/API/Node/textContent
        api.setTextContent(elm, "");
      }
    } else if (oldVnode.text !== vnode.text) {
      /* 如果text节点不一样 */ // 如果old child 有 chile 那么remove
      if (isDef(oldCh)) {
        removeVnodes(
          elm,
          oldCh as Array<VNode>,
          0,
          (oldCh as Array<VNode>).length - 1
        );
      }
      // 设置为new Vnode 的text
      api.setTextContent(elm, vnode.text as string);
    }
    // 调用postpath钩子
    if (isDef(hook) && isDef((i = hook.postpatch))) {
      i(oldVnode, vnode);
    }
  }
  /* ==========patchVnode结束========== */

  return function patch(oldVnode: VNode | Element, vnode: VNode): VNode {
    let i: number, elm: Node, parent: Node;

    const insertedVnodeQueue: VNodeQueue = [];

    for (i = 0; i < cbs.pre.length; ++i) cbs.pre[i]();

    if (!isVnode(oldVnode)) {
      oldVnode = emptyNodeAt(oldVnode);
    }

    if (sameVnode(oldVnode, vnode)) {
      patchVnode(oldVnode, vnode, insertedVnodeQueue);
    } else {
      elm = oldVnode.elm as Node;
      parent = api.parentNode(elm);

      createElm(vnode, insertedVnodeQueue);

      if (parent !== null) {
        api.insertBefore(parent, vnode.elm as Node, api.nextSibling(elm));
        removeVnodes(parent, [oldVnode], 0, 0);
      }
    }

    for (i = 0; i < insertedVnodeQueue.length; ++i) {
      (((insertedVnodeQueue[i].data as VNodeData).hook as Hooks).insert as any)(
        insertedVnodeQueue[i]
      );
    }
    for (i = 0; i < cbs.post.length; ++i) cbs.post[i]();
    return vnode;
  };
}

```




