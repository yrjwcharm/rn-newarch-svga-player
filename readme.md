## **_这是一款使用 ReactNative 加载`Android/iOS` Svga 动画的播放器插件_** [三端 Svga 动画统一使用点击这里](https://github.com/yrjwcharm/react-native-ohos/tree/feature/rnoh/svgaplayer)

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
-    "rn-newarch-svga-player":"^1.1.2"
+   "react-native-svga-player":"npm:rn-newarch-svga-player@1.1.2"
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

下面的代码展示了这个库的基本使用场景：

```js
import React, { useRef, useState } from "react";
import {
  Button,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from "react-native";
import { RNSvgaPlayer, SvgaPlayerRef } from "react-native-svga-player";
const App = () => {
  const svgaPlayerRef = useRef < SvgaPlayerRef > null;
  //播放网络资源
  const [source, setSource] = useState(
    "https://raw.githubusercontent.com/yyued/SVGAPlayer-iOS/master/SVGAPlayer/Samples/Goddess.svga"
  );
  //播放本地资源
  // const [source, setSource] = useState(
  //   'homePage_studyPlanner_computer_welcome.svga',
  // );
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle={"dark-content"} />
      <ScrollView showsVerticalScrollIndicator={false}>
        <Text style={styles.welcome}>Svga</Text>
        <RNSvgaPlayer
          ref={svgaPlayerRef}
          source={source}
          autoPlay={true}
          loops={1} // 循环次数，默认 0无限循环
          clearsAfterStop={false} // 停止后清空画布，默认 true
          style={styles.svgaStyle}
          onFinished={() => {
            console.log("播放完成");
          }} // 播放完成回调
          onLoaded={() => {
            console.log("动画加载完成");
          }}
        />
        <View style={styles.flexAround}>
          <Button
            title="开始动画"
            onPress={() => {
              svgaPlayerRef.current?.startAnimation();
            }}
          />
          <Button
            title="暂停动画"
            onPress={() => {
              // svgaPlayerRef.current?.pauseAnimation();
            }}
          />
          <Button
            title="停止动画"
            onPress={() => {
              svgaPlayerRef.current?.stopAnimation();
            }}
          />
        </View>
        <View style={[styles.flexAround, { marginTop: 20 }]}>
          <Button
            title="手动加载动画"
            onPress={() => {
              setSource(
                "https://raw.githubusercontent.com/yyued/SVGAPlayer-iOS/master/SVGAPlayer/Samples/matteBitmap.svga"
              );
            }}
          />
          <Button
            title="指定帧开始"
            onPress={() => {
              // svgaPlayerRef.current?.stepToFrame(20, true);
            }}
          />
          <Button
            title="指定百分比开始"
            onPress={() => {
              // svgaPlayerRef.current?.stepToPercentage(1, true);
            }}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};
export default App;
const styles = StyleSheet.create({
  flexAround: { flexDirection: "row", justifyContent: "space-around" },
  container: {
    flex: 1,
  },
  svgaStyle: {
    width: 150,
    height: 150,
    marginTop: 30,
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 10,
    marginTop: 80,
  },
  instructions: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5,
  },
});
```

#### 新架构[Android/iOS]demo 请参考 <https://github.com/yrjwcharm/react-native-ohos/tree/feature/newarch/svgaplayer>

更多详情用法参考 [三端 Svga 动画统一使用点击这里](https://github.com/yrjwcharm/react-native-ohos/tree/feature/rnoh/svgaplayer)

#### 开源不易，希望您可以动一动小手点点小 ⭐⭐

#### 👴 希望大家如有好的需求踊跃提交,如有问题请提交 issue，空闲时间会扩充与修复优化

## 开源协议

本项目基于 [The MIT License (MIT)](https://github.com/yrjwcharm/react-native-ohos-svgaplayer/blob/master/LICENSE) ，请自由地享受和参与开源。
