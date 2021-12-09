import 'package:flutter/material.dart';
import 'package:flutter_k_chart/chart_style.dart';
import 'package:flutter_k_chart/utils/number_util.dart';
export '../chart_style.dart';

abstract class BaseChartRenderer<T> {
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  double maxValue, minValue;
  late double scaleY, scaleX;
  double topPadding;
  Rect chartRect;
  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = Colors.red;
  final Paint gridPaint;

  BaseChartRenderer({
    required this.chartColors,
    required this.chartStyle,
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.scaleX,
  }) : gridPaint = Paint()
          ..isAntiAlias = true
          ..filterQuality = FilterQuality.high
          ..strokeWidth = 0.5
          ..color = chartColors.gridColor {
    if (maxValue == minValue) {
      maxValue += 0.5;
      minValue -= 0.5;
    }
    scaleY = chartRect.height / (maxValue - minValue);
  }

  double getY(double value) {
    final dy = (maxValue - value) * scaleY + chartRect.top;
    if (chartStyle.klineOverflow) {
      return dy;
    }
    return dy.clamp(chartRect.top, chartRect.bottom);
  }

  double getValue(double dy) {
    return maxValue - (dy - chartRect.top) / scaleY;
  }

  String format(double n) {
    return NumberUtil.format(n);
  }

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawRightText(canvas, textStyle, int gridRows);

  void drawChart(T lastPoint, T curPoint, double lastX, double curX, Size size,
      Canvas canvas);

  void drawLine(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX, Color color) {
    double lastY = getY(lastPrice);
    double curY = getY(curPrice);
    canvas.drawLine(
        Offset(lastX, lastY), Offset(curX, curY), chartPaint..color = color);
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: chartStyle.defaultTextSize, color: color);
  }
}
