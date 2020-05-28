import 'package:flutter/material.dart' show Color;

class ChartColors {
  ChartColors._();

  //背景颜色
  static const Color bgColor = Color(0xff0D141E);
  static const Color kLineColor = Color(0xff4C86CD);
  static const Color gridColor = Color(0xff4c5c74);
  static const List<Color> kLineShadowColor = [Color(0x554C86CD), Color(0x00000000)]; //k线阴影渐变
  static const Color ma5Color = Color(0xffC9B885);
  static const Color ma10Color = Color(0xff6CB0A6);
  static const Color ma30Color = Color(0xff9979C6);
  static const Color upColor = Color(0xff4DAA90);
  static const Color dnColor = Color(0xffC15466);
  static const Color volColor = Color(0xff4729AE);

  static const Color macdColor = Color(0xff4729AE);
  static const Color difColor = Color(0xffC9B885);
  static const Color deaColor = Color(0xff6CB0A6);

  static const Color kColor = Color(0xffC9B885);
  static const Color dColor = Color(0xff6CB0A6);
  static const Color jColor = Color(0xff9979C6);
  static const Color rsiColor = Color(0xffC9B885);

  static const Color yAxisTextColor = Color(0xff60738E); //右边y轴刻度
  static const Color xAxisTextColor = Color(0xff60738E); //下方时间刻度

  static const Color maxMinTextColor = Color(0xffffffff); //最大最小值的颜色

  //深度颜色
  static const Color depthBuyColor = Color(0xff60A893);
  static const Color depthSellColor = Color(0xffC15866);

  //选中后显示值边框颜色
  static const Color markerBorderColor = Color(0xff6C7A86);

  //选中后显示值背景的填充颜色
  static const Color markerBgColor = Color(0xff0D1722);

  //实时线颜色等
  static const Color realTimeBgColor = Color(0xff0D1722);
  static const Color rightRealTimeTextColor = Color(0xff4C86CD);
  static const Color realTimeTextBorderColor = Color(0xffffffff);
  static const Color realTimeTextColor = Color(0xffffffff);

  //实时线
  static const Color realTimeLineColor = Color(0xffffffff);
  static const Color realTimeLongLineColor = Color(0xff4C86CD);

  static const Color simpleLineUpColor = Color(0xff6CB0A6);
  static const Color simpleLineDnColor = Color(0xffC15466);


}

class ChartStyle {
  ChartStyle._();

  //点与点的距离
  static const double pointWidth = 11.0;

  //蜡烛宽度
  static const double candleWidth = 8.5;

  //蜡烛中间线的宽度
  static const double candleLineWidth = 1.5;

  //vol柱子宽度
  static const double volWidth = 8.5;

  //macd柱子宽度
  static const double macdWidth = 3.0;

  //垂直交叉线宽度
  static const double vCrossWidth = 8.5;

  //水平交叉线宽度
  static const double hCrossWidth = 0.5;

  //网格
  static const int gridRows = 3, gridColumns = 4;

  static const double topPadding = 30.0, bottomDateHigh = 20.0, childPadding = 25.0;

  static const double defaultTextSize = 10.0;
}
