import 'dart:async';

import 'package:flutter/material.dart';
import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart';
import 'utils/number_util.dart';

enum MainState { MA, BOLL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

class KChartWidget extends StatefulWidget {
  List<KLineEntity> datas;
  MainState mainState;
  SecondaryState secondaryState;
  bool isLine;

  KChartWidget(this.datas,
      {this.mainState = MainState.MA, this.secondaryState = SecondaryState.MACD, this.isLine});

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> {
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  StreamController<InfoWindowEntity> mInfoWindowStream;
  double mWidth = 0;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    return GestureDetector(
      onHorizontalDragDown: (details) {
        isDrag = true;
      },
      onHorizontalDragUpdate: (details) {
        if (isScale || isLongPress) return;
        mScrollX = (details.primaryDelta / mScaleX + mScrollX).clamp(0.0, ChartPainter.maxScrollX);
        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        isDrag = false;
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
        mInfoWindowStream?.sink?.add(null);
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
                secondaryState: widget.secondaryState,
                isLine: widget.isLine,
                sink: mInfoWindowStream?.sink),
          ),
          _buildInfoDialog()
        ],
      ),
    );
  }

  void notifyChanged() => setState(() {});

  List<String> infoNames = ["时间", "开", "高", "低", "收", "涨跌额", "涨幅", "成交量"];
  List infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress || widget.isLine == true || !snapshot.hasData || snapshot.data.kLineEntity == null)
            return Container();
          KLineEntity entity = snapshot.data.kLineEntity;
          double upDown = entity.close - entity.open;
          double upDownPercent = upDown / entity.open * 100;
          infos = [
            getDate(entity.id),
            entity.open,
            entity.high,
            entity.low,
            entity.close,
            "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(2)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            NumberUtil.format(entity.vol)
          ];
          return Container(
            margin: EdgeInsets.only(left: snapshot.data.isLeft ? 4 : mWidth - mWidth / 3 - 4, top: 25),
            width: mWidth / 3,
            decoration: BoxDecoration(
                color: ChartColors.selectFillColor,
                border: Border.all(color: ChartColors.selectBorderColor, width: 0.5)),
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: infoNames.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildItem(infos[index].toString(), infoNames[index]);
              },
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: Text("$infoName", style: const TextStyle(color: Colors.white, fontSize: 10.0))),
        Text(info, style: TextStyle(color: color, fontSize: 10.0)),
      ],
    );
  }

  String getDate(int date) {
    return dateFormat(
        DateTime.fromMillisecondsSinceEpoch(date * 1000), [yy, '-', mm, '-', dd, ' ', HH, ':', nn]);
  }
}
