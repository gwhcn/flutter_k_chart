import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'chart_style.dart';
import 'flutter_k_chart.dart';
import 'renderer/base_chart_painter.dart';

class KChartWatermarkWidget extends SingleChildRenderObjectWidget {
  final BaseChartPainter chartPainter;

  KChartWatermarkWidget({
    Key? key,
    required this.chartPainter,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _WatermarkRenderBox createRenderObject(BuildContext context) {
    return _WatermarkRenderBox(chartPainter: chartPainter);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _WatermarkRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);

    renderObject..chartPainter = chartPainter;
  }
}

class _WatermarkRenderBox extends RenderProxyBox {
  BaseChartPainter chartPainter;

  _WatermarkRenderBox({
    required this.chartPainter,
  });

  @override
  void performLayout() {
    size = constraints.biggest;

    final child = this.child;
    if (child != null) {
      // Calculation process is similar to [BaseChartPainter.initRect].
      // Updated [BaseChartPainter.initRect] should also update following.
      final displayHeight =
          size.height - ChartStyle.topPadding - ChartStyle.bottomDateHigh;
      final mainHeight;
      if (chartPainter.volState == VolState.NONE &&
          chartPainter.secondaryState == SecondaryState.NONE) {
        mainHeight = displayHeight;
      } else if (chartPainter.volState == VolState.NONE ||
          chartPainter.secondaryState == SecondaryState.NONE) {
        mainHeight = displayHeight * 0.8;
      } else {
        mainHeight = displayHeight * 0.6;
      }
      final childConstraints = constraints.tighten(
        height: mainHeight + ChartStyle.topPadding,
      );

      child.layout(childConstraints);
    }
  }
}
