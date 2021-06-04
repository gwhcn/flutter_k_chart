import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_k_chart/flutter_k_chart.dart';
import 'package:flutter_k_chart/generated/l10n.dart' as k_chart;
import 'package:flutter_k_chart/k_chart_widget.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // supportedLocales: [const Locale('zh', 'CN')],
      localizationsDelegates: [
        k_chart.S.delegate //国际话
      ],
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<KLineEntity>? datas;
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = true;
  List<DepthEntity>? _bids, _asks;
  List<int> maDayList = [];
  bool volHidden = false;

  @override
  void initState() {
    super.initState();
    getData('1day');
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      final tick = parseJson['tick'] as Map<String, dynamic>;
      final List<DepthEntity> bids = (tick['bids'] as List<dynamic>)
          .map<DepthEntity>(
              (item) => DepthEntity(item[0] as double, item[1] as double))
          .toList();
      final List<DepthEntity> asks = (tick['asks'] as List<dynamic>)
          .map((item) => DepthEntity(item[0] as double, item[1] as double))
          .toList()
          .cast<DepthEntity>();
      initDepth(bids, asks);
    });
  }

  void initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    bids.sort((left, right) => left.price.compareTo(right.price));
    for (final item in bids.reversed) {
      amount += item.amount;
      item.amount = amount;
      _bids!.insert(0, item);
    }

    amount = 0.0;
    asks.sort((left, right) => left.price.compareTo(right.price));
    for (final item in asks) {
      amount += item.amount;
      item.amount = amount;
      _asks!.add(item);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          Stack(children: <Widget>[
            Container(
              height: 450,
              width: double.infinity,
              child: KChartWidget(
                datas,
                isLine: isLine,
                volHidden: volHidden,
                mainState: _mainState,
                secondaryState: _secondaryState,
                maDayList: maDayList,
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
              ),
            ),
            if (showLoading)
              Container(
                  width: double.infinity,
                  height: 450,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator()),
          ]),
          buildButtons(),
          if (_bids != null && _asks != null)
            Container(
              height: 230,
              width: double.infinity,
              child: DepthChart(_bids!, _asks!),
            )
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button('kLine', onPressed: () => isLine = !isLine),
        button('volHidden', onPressed: () => volHidden = !volHidden),
        button('MA',
            onPressed: () => _mainState =
                (_mainState == MainState.NONE) ? MainState.MA : MainState.NONE),
        button('BOLL',
            onPressed: () => _mainState = (_mainState == MainState.NONE)
                ? MainState.BOLL
                : MainState.NONE),
        button('MACD',
            onPressed: () => _secondaryState =
                (_secondaryState == SecondaryState.NONE)
                    ? SecondaryState.MACD
                    : SecondaryState.NONE),
        button('KDJ',
            onPressed: () => _secondaryState =
                (_secondaryState == SecondaryState.NONE)
                    ? SecondaryState.KDJ
                    : SecondaryState.NONE),
        button('RSI',
            onPressed: () => _secondaryState =
                (_secondaryState == SecondaryState.NONE)
                    ? SecondaryState.RSI
                    : SecondaryState.NONE),
        button('WR',
            onPressed: () => _secondaryState =
                (_secondaryState == SecondaryState.NONE)
                    ? SecondaryState.WR
                    : SecondaryState.NONE),
        button('CCI',
            onPressed: () => _secondaryState =
                (_secondaryState == SecondaryState.NONE)
                    ? SecondaryState.CCI
                    : SecondaryState.NONE),
        button('update', onPressed: () {
          //更新最后一条数据
          datas!.last.close =
              datas!.last.close + (Random().nextInt(100) - 50).toDouble();
          datas!.last.high = max(datas!.last.high, datas!.last.close);
          datas!.last.low = min(datas!.last.low, datas!.last.close);
          DataUtil.updateLastData(datas, maDayList);
        }),
        button('addData', onPressed: () {
          // Sao chép một đối tượng, sửa đổi dữ liệu
          final kLineEntity = KLineEntity.fromJson(datas!.last.toJson());
          kLineEntity.id = kLineEntity.id! + 60 * 60 * 24;
          kLineEntity.open = kLineEntity.close;
          kLineEntity.close =
              kLineEntity.close + (Random().nextInt(100) - 50).toDouble();
          datas!.last.high = max(datas!.last.high, datas!.last.close);
          datas!.last.low = min(datas!.last.low, datas!.last.close);
          DataUtil.addLastData(datas, kLineEntity, maDayList);
        }),
        button('1month', onPressed: () async {
//              showLoading = true;
//              setState(() {});
          //getData('1mon');
          final String result = await rootBundle.loadString('assets/kmon.json');
          final parseJson = json.decode(result) as Map<String, dynamic>;
          final list = parseJson['data'] as List<dynamic>;
          datas = list
              .map((item) => KLineEntity.fromJson(item as Map<String, dynamic>))
              .toList()
              .reversed
              .toList()
              .cast<KLineEntity>();
          DataUtil.calculate(datas, maDayList);
        }),
        button('1Day', onPressed: () {
          showLoading = true;
          setState(() {});
          getData('1day');
        }),
      ],
    );
  }

  Widget button(String text, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      child: Text(text),
      style: TextButton.styleFrom(
        primary: Colors.white,
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void getData(String period) async {
    late String result;
    try {
      result = await getIPAddress(period);
    } catch (e) {
      print('Không lấy được dữ liệu, lấy dữ liệu cục bộ');
      result = await rootBundle.loadString('assets/kline.json');
    } finally {
      final parseJson = json.decode(result) as Map<String, dynamic>;
      final list = parseJson['data'] as List<dynamic>;
      datas = list
          .map((item) => KLineEntity.fromJson(item as Map<String, dynamic>))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      DataUtil.calculate(datas, maDayList);
      showLoading = false;
      setState(() {});
    }
  }

  Future<String> getIPAddress(String? period) async {
    //Huobi api, cần khắc phục bức tường
    final url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    String result;
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 7));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      return Future.error('Nhận thất bại');
    }
    return result;
  }
}
