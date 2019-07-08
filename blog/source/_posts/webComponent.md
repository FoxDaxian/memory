---
title: web component
tags: frontend
categories: 原理
---

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Document</title>
</head>

<body>

    <my-btn click-fnname="whenClick">
        <div slot="text" class="text">123</div>
    </my-btn>
    <template class="template">
        <style>
            /* 指代当前宿主 */
            :host {
                display: block;
                width: 100px;
                height: 40px;
                border: 1px solid rgba(0, 0, 0, .4);
                border-radius: 10px;
                text-align: center;
                line-height: 40px;
                cursor: pointer;
            }

            :host(:hover) {
                border-color: blue;
            }

            .slotBox {
                color: red;
            }
        </style>
        <div class="slotBox">
            <slot name="text" class=".slotText">默认的slot展示</slot>
        </div>
    </template>
    <script>
        const config = {
            // ...
            funcs: {
                whenClick() {
                    console.log('我被点击了');
                }
            }
            // ...
        };
        const customTemplate = (function (config) {
            return class extends HTMLElement {
                // 监听可以更新的属性
                static get observedAttributes() {
                    return ['click-fnname'];
                }
                constructor() {
                    super();
                    this._clickFnname = () => {
                        console.log('默认点击事件');
                    }
                    // this 就是当前这个自定义的标签
                    this.template = document.querySelector('.template');
                    this.shadow = this.attachShadow({
                        mode: 'open'
                    })
                    // 添加template到shadow dom
                    this.shadow.appendChild(document.importNode(this.template.content, true))
                }
                // 当被添加的时候会被触发
                connectedCallback() {
                    console.log('调用了');
                    this.addEventListener('click', this._clickFnname)
                }
                // 接绑的时候调用
                disconnectedCallback() {
                    console.log('disconnectedCallback');

                }
                // 自定义标签属性改变时触发
                attributeChangedCallback(name, oldValue, newValue) {
                    switch (name) {
                        case 'click-fnname':
                            // 获取全局下的事件
                            this._clickFnname = config.funcs[newValue];
                            break;
                        default:
                            break;
                    }
                }
            }
        })(config);
        customElements.define('my-btn', customTemplate);

    </script>
</body>

</html>
```
参考链接: [英文](https://hacks.mozilla.org/2018/11/the-power-of-web-components/) | [中文](https://www.zcfy.cc/article/an-introduction-to-custom-elements-dev-community) | [一些例子](https://github.com/mdn/web-components-examples)