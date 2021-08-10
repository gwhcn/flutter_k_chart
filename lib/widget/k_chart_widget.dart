import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_k_chart/entity/info_window_entity.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:flutter_k_chart/renderer/chart_painter.dart';
import 'package:flutter_k_chart/utils/date_format_util.dart';
import 'package:flutter_k_chart/utils/number_util.dart';

import 'k_chart_watermark_widget.dart';

enum MainState { MA, BOLL, NONE }
enum VolState { VOL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

class KChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  final MainState mainState;
  final VolState volState;
  final SecondaryState secondaryState;
  final bool isLine;
  final double initialScaleX;
  final void Function(double)? onScaleXUpdated;
  // 当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final void Function(bool)? onLoadMore;
  final Widget? watermark;

  KChartWidget(
    this.datas, {
    this.chartColors = const ChartColors(),
    this.chartStyle = const ChartStyle(),
    this.mainState = MainState.MA,
    this.volState = VolState.VOL,
    this.secondaryState = SecondaryState.MACD,
    this.isLine = false,
    int fractionDigits = 2,
    this.initialScaleX = 1.0,
    this.onScaleXUpdated,
    this.onLoadMore,
    this.watermark,
  }) {
    NumberUtil.fractionDigits = fractionDigits;
  }

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  late StreamController<InfoWindowEntity?> mInfoWindowStream;
  double mWidth = 0;
  late AnimationController _scrollXController;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isLongPress = false;
  bool _showSelect = false;

  // 记录最后两次事件，用以在Up时计算滑动距离
  final _pointerEventSet = PointerEventSet();

  @override
  void initState() {
    super.initState();

    mScaleX = widget.initialScaleX;
    mInfoWindowStream = StreamController();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 850), vsync: this);
    _animation = Tween(begin: 0.9, end: 0.1).animate(_controller)
      ..addListener(() => setState(() {}));
    _scrollXController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity);
    _scrollListener();
  }

  void _scrollListener() {
    _scrollXController.addListener(() {
      mScrollX = _scrollXController.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        _stopAnimation();
      } else {
        notifyChanged();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
  }

  @override
  void didUpdateWidget(KChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.datas != widget.datas) {
      mScrollX = mSelectX = 0.0;
      _showSelect = false;
      mInfoWindowStream.add(null);
    }
  }

  @override
  void dispose() {
    mInfoWindowStream.close();
    _controller.dispose();
    _scrollXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = widget.initialScaleX;
      widget.onScaleXUpdated?.call(widget.initialScaleX);
    }

    final painter = ChartPainter(
      datas: widget.datas,
      chartColors: widget.chartColors,
      chartStyle: widget.chartStyle,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      showSelect: _showSelect,
      mainState: widget.mainState,
      volState: widget.volState,
      secondaryState: widget.secondaryState,
      isLine: widget.isLine,
      sink: mInfoWindowStream.sink,
      opacity: _animation.value,
      controller: _controller,
    );
    Widget child = Stack(
      children: <Widget>[
        RepaintBoundary(
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: painter,
            child: KChartWatermarkWidget(
              chartPainter: painter,
              child: widget.watermark,
            ),
          ),
        ),
        _buildInfoDialog()
      ],
    );
    child = GestureDetector(
      onScaleUpdate: (details) {
        if (isLongPress) return;
        mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
        widget.onScaleXUpdated?.call(mScaleX);
        notifyChanged();
      },
      onScaleEnd: (details) {
        _lastScale = mScaleX;
      },
      onLongPressStart: (details) {
        isLongPress = true;
        _showSelect = true;
        if (mSelectX != details.localPosition.dx) {
          mSelectX = details.localPosition.dx;
          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (mSelectX != details.localPosition.dx) {
          mSelectX = details.localPosition.dx;
          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        isLongPress = false;
      },
      child: child,
    );

    return Listener(
      onPointerDown: (event) {
        _pointerEventSet.add(event);

        if (_showSelect) {
          _showSelect = false;
          mInfoWindowStream.add(null);
          notifyChanged();
        }
        _stopAnimation();
      },
      onPointerMove: (event) {
        _pointerEventSet.add(event);

        if (!isLongPress) {
          mScrollX = (event.delta.dx / mScaleX + mScrollX)
              .clamp(0.0, ChartPainter.maxScrollX)
              .toDouble();
          notifyChanged();
        }
      },
      onPointerUp: (event) {
        final prevEvent = _pointerEventSet.getPrevious(event.device);
        if (prevEvent != null) {
          final velocity = const Duration(seconds: 1).inMicroseconds /
              (event.timeStamp - prevEvent.timeStamp).inMicroseconds *
              (event.position - prevEvent.position).dx;
          final devicePixelRatio =
              WidgetsBinding.instance!.window.devicePixelRatio;
          final simulation = ClampingScrollSimulation(
            position: mScrollX,
            velocity: velocity,
            tolerance: Tolerance(
              velocity: 1.0 / (0.050 * devicePixelRatio),
              // logical pixels per second
              distance: 1.0 / devicePixelRatio, // logical pixels
            ),
          );
          _scrollXController.animateWith(simulation).whenCompleteOrCancel(() {
            final scrollX = _scrollXController.value;
            if (scrollX <= 0) {
              widget.onLoadMore?.call(true);
            } else if (scrollX >= ChartPainter.maxScrollX) {
              widget.onLoadMore?.call(false);
            }
          });
        }

        _pointerEventSet.clear(event.device);
      },
      onPointerCancel: (event) {
        _pointerEventSet.clear(event.device);
      },
      child: child,
    );
  }

  void _stopAnimation() {
    if (_scrollXController.isAnimating) {
      _scrollXController.stop();
      notifyChanged();
    }
  }

  void notifyChanged() => setState(() {});

  late List infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream.stream,
        builder: (context, snapshot) {
          final s = KChartS.of(context);
          final infoNames = [
            s.date,
            s.open,
            s.high,
            s.low,
            s.close,
            s.change,
            s.change_,
            s.executed,
          ];

          if (widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return const SizedBox();
          KLineEntity entity = snapshot.data!.kLineEntity;
          double upDown = entity.close - entity.open;
          double upDownPercent = upDown / entity.open * 100;
          infos = [
            getDate(entity.id!),
            NumberUtil.format(entity.open),
            NumberUtil.format(entity.high),
            NumberUtil.format(entity.low),
            NumberUtil.format(entity.close),
            "${upDown > 0 ? "+" : ""}${NumberUtil.format(upDown)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            NumberUtil.volFormat(entity.vol)
          ];
          return Align(
            alignment:
                snapshot.data!.isLeft ? Alignment.topLeft : Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 25),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                  color: widget.chartColors.markerBgColor,
                  border: Border.all(
                      color: widget.chartColors.markerBorderColor, width: 0.5)),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(infoNames.length,
                      (i) => _buildItem(infos[i].toString(), infoNames[i])),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    final Color color;
    if (info.startsWith("+"))
      color = widget.chartColors.makerUpColor;
    else if (info.startsWith("-"))
      color = widget.chartColors.makerDnColor;
    else
      color = widget.chartColors.makerNormalColor;
    return Container(
      constraints:
          const BoxConstraints(minWidth: 95, maxHeight: 14.0, minHeight: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "$infoName",
            style: TextStyle(
              color: widget.chartColors.makerTitleColor,
              fontSize: widget.chartStyle.defaultTextSize,
            ),
          ),
          SizedBox(width: 5),
          Text(
            info,
            style: TextStyle(
              color: color,
              fontSize: widget.chartStyle.defaultTextSize,
            ),
          ),
        ],
      ),
    );
  }

  String getDate(int date) {
    return dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000),
        [yy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }
}

class PointerEventSet {
  late final set = <int, List<PointerEvent>>{};

  List<PointerEvent> add(PointerEvent event) {
    final histories = set.putIfAbsent(event.device, () => []);
    if (histories.length > 1) {
      histories.removeAt(0);
    }
    histories.add(event);

    return histories;
  }

  PointerEvent? getPrevious(int device) {
    return set[device]?.firstOrNull;
  }

  List<PointerEvent>? clear(int device) {
    return set.remove(device);
  }
}
