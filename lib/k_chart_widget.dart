import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_k_chart/generated/l10n.dart';

import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart' hide S;
import 'utils/number_util.dart';

enum MainState { MA, BOLL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, CCI, NONE }

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final MainState mainState;
  final bool volHidden;
  final SecondaryState secondaryState;
  final bool isLine;
  final Function()? onSecondaryTap;
  final List<String> timeFormat;

  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool)? onLoadMore;
  final List<Color>? bgColor;
  final List<int> maDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;

  KChartWidget(
    this.datas, {
    this.volHidden = false,
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.isLine = false,
    this.bgColor,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.onLoadMore,
    this.onSecondaryTap,
    int fractionDigits = 2,
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
  StreamController<InfoWindowEntity?>? mInfoWindowStream;
  double mWidth = 0;
  late AnimationController _scrollXController;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity?>();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 850), vsync: this);
    _animation = Tween(begin: 0.9, end: 0.1).animate(_controller.view)
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
    _scrollXController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        isDrag = false;
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
    if (oldWidget.datas != widget.datas) mScrollX = mSelectX = 0.0;
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller.dispose();
    _scrollXController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
      onHorizontalDragDown: (details) {
        _stopAnimation();
        isDrag = true;
      },
      onHorizontalDragUpdate: (details) {
        if (isScale || isLongPress) return;
        mScrollX = (details.primaryDelta! / mScaleX + mScrollX)
            .clamp(0.0, ChartPainter.maxScrollX)
            .toDouble();
        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        // isDrag = false;
        final Tolerance tolerance = Tolerance(
          velocity:
              1.0 / (0.050 * WidgetsBinding.instance!.window.devicePixelRatio),
          // logical pixels per second
          distance: 1.0 /
              WidgetsBinding
                  .instance!.window.devicePixelRatio, // logical pixels
        );

        ClampingScrollSimulation simulation = ClampingScrollSimulation(
          position: mScrollX,
          velocity: details.primaryVelocity!,
          tolerance: tolerance,
        );
        _scrollXController.animateWith(simulation);
      },
      onHorizontalDragCancel: () => isDrag = false,
      onScaleStart: (_) {
        isScale = true;
      },
      onScaleUpdate: (details) {
        if (isDrag || isLongPress) return;
        mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
        notifyChanged();
      },
      onScaleEnd: (_) {
        isScale = false;
        _lastScale = mScaleX;
      },
      onLongPressStart: (details) {
        isLongPress = true;
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx;
          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (mSelectX != details.globalPosition.dx) {
          mSelectX = details.globalPosition.dx;
          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        isLongPress = false;
        mInfoWindowStream?.sink.add(null);
        notifyChanged();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: ChartPainter(
              datas: widget.datas,
              scaleX: mScaleX,
              scrollX: mScrollX,
              selectX: mSelectX,
              isLongPass: isLongPress,
              mainState: widget.mainState,
              volHidden: widget.volHidden,
              secondaryState: widget.secondaryState,
              isLine: widget.isLine,
              sink: mInfoWindowStream?.sink,
              opacity: _animation.value,
              controller: _controller,
              bgColor: widget.bgColor,
              maDayList: widget.maDayList,
            ),
          ),
          _buildInfoDialog()
        ],
      ),
    );
  }

  void _stopAnimation() {
    if (_scrollXController.isAnimating) {
      _scrollXController.stop();
      isDrag = false;
      notifyChanged();
    }
  }

  void notifyChanged() => setState(() {});

  List<String> infoNames = [
    S.current.date,
    S.current.open,
    S.current.high,
    S.current.low,
    S.current.close,
    S.current.change,
    S.current.change_,
    S.current.executed,
  ];
  late List infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress ||
              widget.isLine == true ||
              !snapshot.hasData ||
              snapshot.data?.kLineEntity == null) return Container();
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
              margin: EdgeInsets.only(left: 10, right: 10, top: 25),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                  color: ChartColors.markerBgColor,
                  border: Border.all(
                      color: ChartColors.markerBorderColor, width: 0.5)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(infoNames.length,
                    (i) => _buildItem(infos[i].toString(), infoNames[i])),
              ),
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = Colors.white;
    if (info.startsWith("+"))
      color = Colors.green;
    else if (info.startsWith("-"))
      color = Colors.red;
    else
      color = Colors.white;
    return Container(
      constraints: BoxConstraints(
          minWidth: 95, maxWidth: 110, maxHeight: 14.0, minHeight: 14.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("$infoName",
              style: TextStyle(
                  color: Colors.white, fontSize: ChartStyle.defaultTextSize)),
          SizedBox(width: 5),
          Text(info,
              style: TextStyle(
                  color: color, fontSize: ChartStyle.defaultTextSize)),
        ],
      ),
    );
  }

  String getDate(int date) {
    return dateFormat(DateTime.fromMillisecondsSinceEpoch(date * 1000),
        [yy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }
}
