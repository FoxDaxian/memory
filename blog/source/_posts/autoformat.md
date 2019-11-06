---
title: 根据eslint自动格式化
tags: frendend
categories: 效率
---

# prettier + eslint

1. 重置 vscode 的配置，采用.prettierrc 文件
2. 编写 eslint 规则和.eslintignore
3. 添加 package.json 的 lint 相关的命令
4. 增加 prettier-eslint-cli，配置 format 命令
5. 集成所有命令

### prettier-eslin 优先读取 eslint 的配置，如果被禁用那么去读 .prettierrc

### demo

```javascript
// .prettierrc
{
    "trailingComma": "none",
    "tabWidth": 4,
    "semi": true,
    "singleQuote": true,
    "jsxSingleQuote": true,
    "bracketSpacing": false
}
```

```javascript
"scripts": {
    "lint": "./node_modules/.bin/eslint .",
    "format": "./node_modules/.bin/prettier-eslint --write \"utils/**/*.js\" \"components/**/*.?(vue|js)\""
},
"husky": {
    "hooks": {
        "pre-commit": "npm run format && git add ."
    }
}

```

[eslint 配置文件参数说明](https://gist.github.com/rswanderer/29dc65efc421b3b5b0442f1bd3dcd046)
