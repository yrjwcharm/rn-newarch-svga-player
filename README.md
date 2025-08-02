## **这是一款使用 ReactNative 新架构 加载`Android/iOS` Svga 动画的开源插件**[三端 Svga 动画统一使用点击这里](https://github.com/yrjwcharm/react-native-ohos/tree/feature/rnoh/svgaplayer)

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

> [!TIP] 注意 ⚠️ 本库 android/ios 仅给予 Fabric 新架构 支持，旧架构不在跟进，若需旧架构支持请移步<https://github.com/yrjwcharm/react-native-svga-player>

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
-    "rn-newarch-svga-player":"^latest"
+   "react-native-svga-player":"npm:rn-newarch-svga-player@latest"
  },
```

android 需要

```bash
 ./gradlew generateCodegenArtifactsFromSchema
```

ios 需要

```bash
  cd ios
  bundle install && bundle exec pod install
```

### ios react-native 0.76 以上 AppDelegate.mm 需要显示注册该组件

```diff
#import "AppDelegate.h"
#import "RCTSvgaPlayer.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge+Private.h>

@implementation AppDelegate
// ...

+ - (NSDictionary<NSString *,Class<RCTComponentViewProtocol>> *)thirdPartyFabricComponents
+ {
+  NSMutableDictionary * dictionary = [super thirdPartyFabricComponents].mutableCopy;
+  dictionary[@"RNSvgaPlayer"] = [RCTSvgaPlayer class];
+  return dictionary;
+ }

@end
```

## API 参考

### Props

| 属性              | 类型                      | 默认值      | 描述                                                  |
| ----------------- | ------------------------- | ----------- | ----------------------------------------------------- |
| `source`          | `SvgaSource`              | -           | SVGA 文件源                                           |
| `autoPlay`        | `boolean`                 | `true`      | 是否自动播放                                          |
| `loops`           | `number`                  | `0`         | 循环播放次数，默认值：0 表示无限循环                  |
| `clearsAfterStop` | `boolean`                 | `true`      | 动画停止后是否清空画布                                |
| `fillMode`        | `'Forward' \| 'Backward'` | `'Forward'` | 填充模式：Forward 停留在最后一帧，Backward 回到第一帧 |
| `onFinished`      | `function`                | -           | 播放完成时的回调函数                                  |
| `onFrame`         | `function`                | -           | 帧变化时的回调函数                                    |
| `onPercentage`    | `function`                | -           | 播放进度变化时的回调函数                              |

### Ref 方法

| 方法                                                 | 描述                                            |
| ---------------------------------------------------- | ----------------------------------------------- |
| `startAnimation()`                                   | 从第 0 帧开始播放动画                           |
| `startAnimationWithRange(location, length, reverse)` | 在指定范围内播放动画，可选择反向播放            |
| `pauseAnimation()`                                   | 暂停动画，停留在当前帧                          |
| `stopAnimation()`                                    | 停止动画，根据 clearsAfterStop 决定是否清空画布 |
| `stepToFrame(frame, andPlay)`                        | 跳转到指定帧，可选择是否从该帧开始播放          |
| `stepToPercentage(percentage, andPlay)`              | 跳转到指定百分比位置 (0.0-1.0)，可选择是否播放  |

下面的代码展示了这个库的基本使用场景：

```js
import React from "react";
import { View, Dimensions, StyleSheet } from "react-native";
import { RNSvgaPlayer } from "react-native-svga-player";

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

更多详情用法参考 [三端 Svga 动画统一使用点击这里](https://github.com/yrjwcharm/react-native-ohos/tree/feature/rnoh/svgaplayer)

#### 开源不易，希望您可以动一动小手点点小 ⭐⭐

#### 👴 希望大家如有好的需求踊跃提交,如有问题请提交 issue，空闲时间会扩充与修复优化

## 开源协议

本项目基于 [The MIT License (MIT)](https://github.com/yrjwcharm/react-native-ohos-svgaplayer/blob/master/LICENSE) ，请自由地享受和参与开源。
