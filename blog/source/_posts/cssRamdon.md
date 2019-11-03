---
title: css实现伪随机数
tags: frendend
categories: 黑魔法
---

### 前言时间急，任务重，直接上原理和代码。

### 原理和问题
前提是需要label和input，这样才能让css知道当前选中了哪个，也就是checked属性。
然后利用z-index的keyframes实现一个有规律但是delay各不相同的animation。

![alt](https://res.cloudinary.com/css-tricks/image/upload/c_scale,w_400,f_auto,q_auto/v1571697450/random-01_tavjbx.gif)

有一个小问题是，浏览器触发click和press事件的前提是，mousedown 和 mouseup都作用于同一个element对象才行，你可以自己实践一下，就是在一个可点击的元素上，按下鼠标左键，然后鼠标移出这个可点击的元素，松开鼠标左键，看看会不会触发这个元素本身的行为。
这个问题会导致一种看起来点击失效的问题，不过我们可以通过点击重置element的position行为，然后提供一个z-index最高的可视区mask，这样就保证了我们mouseup和mousedown始终在同一个element对象上了。

### 代码

```css
* {
    user-select: none;
}

@keyframes zindex {
    0% {
        z-index: 9;
    }

    100% {
        z-index: 1;
    }
}

.randomBox {
    height: 100px;
}

.randomBox>label {
    top: 100px;
    left: 8px;
    width: 200px;
    height: 100px;
    box-sizing: border-box;
    border: 1px solid red;
    position: absolute;
}

.randomBox .one {
    animation: zindex 0.3s 0s infinite;
}

.randomBox .two {
    animation: zindex 0.3s -0.1s infinite;
}

.randomBox .three {
    animation: zindex 0.3s -0.2s infinite;
}

input {
    position: absolute;
    visibility: hidden;
}

.value {
    margin-top: 50px;
}

input#one:checked~.value .one {
    background-color: red;
}

input#two:checked~.value .two {
    background-color: red;
}

input#three:checked~.value .three {
    background-color: red;
}

label:active {
    position: static;
    margin-left: -1000px;
}

label:active::before {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    left: 0;
    bottom: 0;
    z-index: 10;
}
```

```html
<h2>css实现随机数</h2>
<input type="radio" id="one" name="random">
<input type="radio" id="two" name="random">
<input type="radio" id="three" name="random">

<div class="randomBox">
    <label for="one" class="one">随机一个数</label>
    <label for="two" class="two">随机一个数</label>
    <label for="three" class="three">随机一个数</label>
</div>
<div class="value">
    <div class="one">1</div>
    <div class="two">2</div>
    <div class="three">3</div>
</div>
<!-- 下面的js用来验证点击是否按照预期触发 -->
<script>
    const labels = document.querySelectorAll('label');
    labels.forEach((label, index) => label.addEventListener('click', function (e) {
        console.log(`${index}被点击了`);  
    }))
</script>
```

### 总结

上面就实现了一个最简单的css随机数，当然这个效果可能不是很明显，如果更复杂就会更逼真，比如这个[例子](https://codepen.io/alvaromontoro/pen/BaaBYyz)


-------

[参考](https://css-tricks.com/are-there-random-numbers-in-css/)



