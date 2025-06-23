## ***这是一款使用ReactNative  加载`Android/iOS` Svga动画的播放器插件*** [三端Svga动画统一使用点击这里](https://github.com/yrjwcharm/react-native-ohos/tree/feature/rnoh/svgaplayer)

> ### 版本：latest

<p align="center">
  <h1 align="center"> <code>rn-newarch-svga-player</code> </h1>
</p>
<p align="center">
    <a href="https://github.com/wonday/react-native-pdf/blob/master/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License" />
    </a>
</p>

> [!TIP] [Github 地址](https://github.com/yrjwcharm/rn-newarch-svga-player)

## 安装与使用

> [!TIP] 注意 ⚠️ 本库 android/ios 仅给予 Fabric 新架构支持，旧架构不在跟进，若需旧架构支持请移步<https://github.com/yrjwcharm/react-native-svga-player>

**确保你的 Android/iOS 已经开启了新架构支持 <https://reactnative.cn/docs/0.72/the-new-architecture/use-app-template>**


#### **npm**

```bash
npm install rn-newarch-svga-player
```

#### **yarn**

```bash
yarn add rn-newarch-svga-player
```

> 若想更改库的别名 react-native-svga-player 来导入。你则需要把 rn-newarch-svga-player 库修改下，重新 yarn 执行

```diff
+  "dependencies": {
    "@react-native-oh/react-native-harmony": "0.72.48",
    "patch-package": "^8.0.0",
    "postinstall-postinstall": "^2.1.0",
    "react": "18.2.0",
    "react-native": "0.72.5",
-    "rn-newarch-svga-player":"^1.0.2"
+   "react-native-svga-player":"npm:rn-newarch-svga-player@1.0.2",
    "react-native-ohos-svgaplayer": "^1.1.7"
  },
```

ios 需要
```bash
 cd ios
 bundle install && bundle exec pod install
```

下面的代码展示了这个库的基本使用场景：

```js
import React from "react";
import { View, Dimensions, StyleSheet } from "react-native";
import RNSvgaPlayer from "react-native-svga-player";

export function App() {
  return (
    <RNSvgaPlayer
      source="https://raw.githubusercontent.com/yyued/SVGAPlayer-iOS/master/SVGAPlayer/Samples/Goddess.svga"
      style={{
        width: 300,
        height: 150,
      }}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "flex-start",
    alignItems: "center",
  },
});
```

#### 新架构[Android/iOS]demo 请参考 <https://github.com/yrjwcharm/react-native-ohos/tree/feature/newarch/svgaplayer>

更多详情用法参考 [三端 Svga 动画统一使用点击这里](https://github.com/yrjwcharm/react-native-ohos/tree/feature/rnoh/svgaplayer)


#### 开源不易，希望您可以动一动小手点点小 ⭐⭐

#### 👴 希望大家如有好的需求踊跃提交,如有问题请提交 issue，空闲时间会扩充与修复优化

## 开源协议

本项目基于 [The MIT License (MIT)](https://github.com/yrjwcharm/react-native-ohos-svgaplayer/blob/master/LICENSE) ，请自由地享受和参与开源。
