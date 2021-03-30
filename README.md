# flutter_k_chart

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)

## 介绍
一个仿火币的flutter图表库包含深度图，支持各种指标及放大缩小、平移等操作

[webdemo演示](https://flutter-widget.live/packages/flutter_k_chart)
Demo v0.1.0：[下载 APK](https://github.com/415593725/flutter_k_chart/blob/master/k_chart.apk)

## 演示

![chart_imge](https://github.com/gwhcn/flutter_k_chart/blob/master/example/images/k_chart.2019-09-01%202010_19_56.gif)
![depth_image](https://github.com/gwhcn/flutter_k_chart/blob/master/example/images/depth.2019-09-01%202010_21_31.gif)
![image1](https://github.com/gwhcn/flutter_k_chart/blob/master/example/images/screenshots.png)

## 简单用例
#### 1.在 pubspec.yaml 中添加依赖
本项目数据来自火币openApi，火币的接口可能需要翻墙，接口失败后会加载本地json。由于项目没有很好的封装，建议使用本地方式使用
```yaml
//本地导入方式
dependencies:
  flutter_k_chart:
    path: 项目路径
```

#### 2.在布局文件中添加
```dart
import 'package:flutter_k_chart/flutter_k_chart.dart';
....
Container(
  height: 450,
  width: double.infinity,
  child: KChartWidget(
    datas,//数据
    isLine: isLine,//是否显示折线图
    mainState: _mainState,//控制主视图指标线
    secondaryState: _secondaryState,//控制副视图指标线
    volState: VolState.VOL,//控制成交量指标线
    fractionDigits: 4,//保留小数位数
  ),
 )
 
 //深度图使用
 Container(
   height: 230,
   width: double.infinity,
   child: DepthChart(_bids, _asks),
 )         
```
#### 3.修改样式
可在chart_style.dart里面修改图表样式

#### 4.数据处理
```dart
//接口获取数据后，计算数据
DataUtil.calculate(datas);
//更新最后一条数据
DataUtil.updateLastData(datas);
//添加数据
DataUtil.addLastData(datas,kLineEntity);
```

#### 国际化 l10n
```dart
import 'package:flutter_k_chart/generated/l10n.dart' as k_chart;
MaterialApp(
      localizationsDelegates: [
        k_chart.S.delegate//国际化
      ],
);
```

#### 5.[修改日志](https://github.com/415593725/flutter_k_chart/blob/master/CHANGELOG.md)

## 问题
使用中如果有问题可以加QQ群：114563912

#### 请咖啡☕️
🙏感谢🙏

![微信](https://user-images.githubusercontent.com/20394691/102620051-61587480-4178-11eb-89e9-53686bb1c0f1.jpg)
