---
title:  微信分享功能实战
tags: frontend
categories: 原理
---

1. 引入wx的npm（weixin-js-sdk）包
2. 判断是否为微信或qq环境
3. 接口请求微信配置相关参数，注意接口传入的参数须和当前分享页的地址相同（不包括#以及后面的）
4. 配置需要的微信jsapi相关信息
5. wx.ready => wx.checkJsApi 检查api可行性
6. 判断并调用wx[相关方法](配置内容)


```javascript
import wx from 'weixin-js-sdk';

export default ({分享配置参数} = {}) => {
    if (weixin || qq) {
        getWxConfApi.then(() => {
            const wxApiData = {
                forFriend: 'updateAppMessageShareData',
                forGroup: 'updateTimelineShareData'
            };
            const wxApi = Object.values(wxApiData);
            wx.config({
                debug: process.env.NODE_ENV === 'development',
                appId, // 必填，公众号的唯一标识
                timestamp, // 必填，生成签名的时间戳
                nonceStr, // 必填，生成签名的随机串
                signature, // 必填，签名
                jsApiList: wxApi // 必填，需要使用的JS接口列表
            });
            wx.ready(() => {
                wx.checkJsApi({
                    jsApiList: wxApi,
                    success: function (res) {
                        for (let i = 0, len = wxApi.length; i < len; i++) {
                            switch (api检查通过 && wxApi[i]) {
                                case wxApiData.forFriend:
                                    // 调用分享给朋友wx api
                                    break;
                                case wxApiData.forGroup:
                                    // 调用分享给朋友圈wx api
                                    break;
                                default:
                                    console.log('部分功能不支持，请使用最新版微信');
                                    break;
                            }
                        }
                    }
                });
            });
            wx.error(res => {
                console.log("配置初始化错误");
            });
        });
    }
};

```

### 微信分享本地测试方法
1. 获取微信平台安全域名，比如test.com
2. 修改本地host配置
    1. xxx.xxx.xx.xx test.com（xxx.xxx.xx.xx你的ip地址，mac下使用ifconfig | grep "inet " | grep -v 127.0.0.1获取）
3. nginx代理test.com:80 => localhost:port(你的本地服务，locate nginx.conf查看nginx配置文件在哪)
    ![](https://raw.githubusercontent.com/FoxDaxian/FoxDaxian.github.io/master/assets/picgo/20190702161827.png)
4. 手机连接和电脑相同的wifi，连接charles
5. 手机扫码打开h5，即可进行微信分享


### 一些问题
1. 签名错误，按照以下顺序查找问题
    1. 检查签名是否正确[校验地址](http://mp.weixin.qq.com/debug/cgi-bin/sandbox?t=jsapisign)
    2. 检查wx.config的字段大小写拼写是否正确
    3. 确定url的完整性，仅仅不包括#以及#后面的
    4. 确认 config 中的 appid 与用来获取 jsapi_ticket 的 appid 一致。
    5. 检查获取wx config字段的接口的url是否和当前待分享页url一致，并且属于安全域名
2. 配置好本地测试后，如果遇到其他接口504 gate way time-out，请检查配置的host时候与api地址冲突