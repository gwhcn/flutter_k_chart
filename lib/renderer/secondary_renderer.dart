import 'dart:ui';

import 'package:flutter/material.dart';
import '../entity/macd_entity.dart';
import '../widget/k_chart_widget.dart' show SecondaryState;

import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  double get mMACDWidth => chartStyle.macdWidth;
  SecondaryState state;

  SecondaryRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.state,
    double scaleX, {
    required ChartColors chartColors,
    required ChartStyle chartStyle,
  }) : super(
          chartColors: chartColors,
          chartStyle: chartStyle,
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          scaleX: scaleX,
        );

  @override
  void drawChart(MACDEntity lastPoint, MACDEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    switch (state) {
      case SecondaryState.MACD:
        drawMACD(curPoint, canvas, curX, lastPoint, lastX);
        break;
      case SecondaryState.KDJ:
        if (lastPoint.k != 0)
          drawLine(lastPoint.k!, curPoint.k!, canvas, lastX, curX,
              chartColors.kColor);
        if (lastPoint.d != 0)
          drawLine(lastPoint.d!, curPoint.d!, canvas, lastX, curX,
              chartColors.dColor);
        if (lastPoint.j != 0)
          drawLine(lastPoint.j!, curPoint.j!, canvas, lastX, curX,
              chartColors.jColor);
        break;
      case SecondaryState.RSI:
        if (lastPoint.rsi != 0)
          drawLine(lastPoint.rsi!, curPoint.rsi!, canvas, lastX, curX,
              chartColors.rsiColor);
        break;
      case SecondaryState.WR:
        if (lastPoint.r != 0)
          drawLine(lastPoint.r!, curPoint.r!, canvas, lastX, curX,
              chartColors.rsiColor);
        break;
      default:
        break;
    }
  }

  void drawMACD(MACDEntity curPoint, Canvas canvas, double curX,
      MACDEntity lastPoint, double lastX) {
    double macdY = getY(curPoint.macd!);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (curPoint.macd! > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = chartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = chartColors.dnColor);
    }
    if (lastPoint.dif != 0) {
      drawLine(lastPoint.dif!, curPoint.dif!, canvas, lastX, curX,
          chartColors.difColor);
    }
    if (lastPoint.dea != 0) {
      drawLine(lastPoint.dea!, curPoint.dea!, canvas, lastX, curX,
          chartColors.deaColor);
    }
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    List<TextSpan> children;
    switch (state) {
      case SecondaryState.MACD:
        children = [
          TextSpan(
              text: "MACD(12,26,9)    ",
              style: getTextStyle(chartColors.yAxisTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "MACD:${format(data.macd!)}    ",
                style: getTextStyle(chartColors.macdColor)),
          if (data.dif != 0)
            TextSpan(
                text: "DIF:${format(data.dif!)}    ",
                style: getTextStyle(chartColors.difColor)),
          if (data.dea != 0)
            TextSpan(
                text: "DEA:${format(data.dea!)}    ",
                style: getTextStyle(chartColors.deaColor)),
        ];
        break;
      case SecondaryState.KDJ:
        children = [
          TextSpan(
              text: "KDJ(14,1,3)    ",
              style: getTextStyle(chartColors.yAxisTextColor)),
          if (data.macd != 0)
            TextSpan(
                text: "K:${format(data.k!)}    ",
                style: getTextStyle(chartColors.kColor)),
          if (data.dif != 0)
            TextSpan(
                text: "D:${format(data.d!)}    ",
                style: getTextStyle(chartColors.dColor)),
          if (data.dea != 0)
            TextSpan(
                text: "J:${format(data.j!)}    ",
                style: getTextStyle(chartColors.jColor)),
        ];
        break;
      case SecondaryState.RSI:
        children = [
          TextSpan(
              text: "RSI(14):${format(data.rsi!)}    ",
              style: getTextStyle(chartColors.rsiColor)),
        ];
        break;
      case SecondaryState.WR:
        children = [
          TextSpan(
              text: "WR(14):${format(data.r!)}    ",
              style: getTextStyle(chartColors.rsiColor)),
        ];
        break;
      default:
        children = <TextSpan>[];
        break;
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawRightText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${format(maxValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${format(minValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
