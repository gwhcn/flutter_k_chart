import 'package:flutter/material.dart' show Color, Colors, Gradient;

class ChartColors {
  //背景颜色
  final Color bgColor;
  final Color kLineColor;
  final Color gridColor;
  //k线阴影渐变
  final List<Color> kLineShadowColor;
  final Color ma5Color;
  final Color ma10Color;
  final Color ma30Color;
  final Color upColor;
  final Color dnColor;
  final Color volColor;

  final Color macdColor;
  final Color difColor;
  final Color deaColor;

  final Color kColor;
  final Color dColor;
  final Color jColor;
  final Color rsiColor;

  final Color defaultTextColor;

  //右边y轴刻度
  final Color yAxisTextColor;
  //下方时间刻度
  final Color xAxisTextColor;

  //最大最小值的颜色
  final Color maxMinTextColor;

  //深度颜色
  final Color depthBuyColor;
  final Color depthSellColor;

  //选中后显示值边框颜色
  final Color markerBorderColor;

  //选中后显示值背景的填充颜色
  final Color markerBgColor;

  final Color makerNormalColor;
  final Color makerTitleColor;
  final Color makerUpColor;
  final Color makerDnColor;

  //实时线颜色等
  final Color realTimeBgColor;
  final Color rightRealTimeTextColor;
  final Color realTimeTextBorderColor;
  final Color realTimeTextColor;

  //实时线
  final Color realTimeLineColor;
  final Color realTimeLongLineColor;

  final Color simpleLineUpColor;
  final Color simpleLineDnColor;

  final Color hCrossColor;
  final Gradient? vCrossGradient;
  final Color crossTextColor;

  const ChartColors({
    this.bgColor = const Color(0xff0D141E),
    this.kLineColor = const Color(0xff4C86CD),
    this.gridColor = const Color(0xff4c5c74),
    this.kLineShadowColor = const [
      Color(0x554C86CD),
      Color(0x00000000),
    ],
    this.ma5Color = const Color(0xffC9B885),
    this.ma10Color = const Color(0xff6CB0A6),
    this.ma30Color = const Color(0xff9979C6),
    this.upColor = const Color(0xff4DAA90),
    this.dnColor = const Color(0xffC15466),
    this.volColor = const Color(0xff4729AE),
    this.macdColor = const Color(0xff4729AE),
    this.difColor = const Color(0xffC9B885),
    this.deaColor = const Color(0xff6CB0A6),
    this.kColor = const Color(0xffC9B885),
    this.dColor = const Color(0xff6CB0A6),
    this.jColor = const Color(0xff9979C6),
    this.rsiColor = const Color(0xffC9B885),
    this.defaultTextColor = const Color(0xff60738E),
    this.yAxisTextColor = const Color(0xff60738E),
    this.xAxisTextColor = const Color(0xff60738E),
    this.maxMinTextColor = Colors.white,
    this.depthBuyColor = const Color(0xff60A893),
    this.depthSellColor = const Color(0xffC15866),
    this.markerBorderColor = const Color(0xff6C7A86),
    this.markerBgColor = const Color(0xff0D1722),
    this.makerNormalColor = Colors.white,
    this.makerTitleColor = Colors.white,
    this.makerUpColor = const Color(0xff00ff00),
    this.makerDnColor = const Color(0xffff0000),
    this.realTimeBgColor = const Color(0xff0D1722),
    this.rightRealTimeTextColor = const Color(0xff4C86CD),
    this.realTimeTextBorderColor = Colors.white,
    this.realTimeTextColor = Colors.white,
    this.realTimeLineColor = Colors.white,
    this.realTimeLongLineColor = const Color(0xff4C86CD),
    this.simpleLineUpColor = const Color(0xff6CB0A6),
    this.simpleLineDnColor = const Color(0xffC15466),
    this.hCrossColor = Colors.white,
    this.vCrossGradient,
    this.crossTextColor = Colors.white,
  });
}

class ChartStyle {
  //点与点的距离
  final double pointWidth;

  //蜡烛宽度
  final double candleWidth;

  //蜡烛中间线的宽度
  final double candleLineWidth;

  //vol柱子宽度
  final double volWidth;

  //macd柱子宽度
  final double macdWidth;

  //垂直交叉线宽度
  final double vCrossWidth;

  //水平交叉线宽度
  final double hCrossWidth;

  //网格
  final int gridRows, gridColumns;

  final double topPadding, bottomDateHigh, childPadding;

  final double defaultTextSize;

  final bool klineOverflow;

  const ChartStyle({
    this.pointWidth = 11.0,
    this.candleWidth = 8.5,
    this.candleLineWidth = 1.5,
    this.volWidth = 8.5,
    this.macdWidth = 3.0,
    this.vCrossWidth = 8.5,
    this.hCrossWidth = 0.5,
    this.gridRows = 3,
    this.gridColumns = 4,
    this.topPadding = 30.0,
    this.bottomDateHigh = 20.0,
    this.childPadding = 25.0,
    this.defaultTextSize = 10.0,
    this.klineOverflow = true,
  });
}
