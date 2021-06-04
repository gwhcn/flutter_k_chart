import 'dart:math';

import '../entity/k_line_entity.dart';

class DataUtil {
  static const int n = 20, k = 2;

  static calculate(List<KLineEntity>? dataList, List<int> maDayList) {
    if (dataList == null) return;
    _calcMA(dataList, maDayList);
    _calcBOLL(dataList, n, k);
    _calcVolumeMA(dataList);
    _calcKDJ(dataList);
    _calcMACD(dataList);
    _calcRSI(dataList);
    _calcWR(dataList);
    _calcCCI(dataList);
  }

  static _calcMA(List<KLineEntity> dataList, List<int> maDayList) {
    List<double> ma = List<double>.filled(maDayList.length, 0);

    if (dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        KLineEntity entity = dataList[i];
        final closePrice = entity.close;
        entity.maValueList = List<double>.filled(maDayList.length, 0);

        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= dataList[i - maDayList[j]].close;
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else {
            entity.maValueList?[j] = 0;
          }
        }
      }
    }
  }

  static void _calcBOLL(List<KLineEntity> dataList, int n, int k) {
    _calcBOLLMA(n, dataList);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i >= n) {
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.BOLLMA!;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.mb = entity.BOLLMA!;
        entity.up = entity.mb! + k * md;
        entity.dn = entity.mb! - k * md;
      }
    }
  }

  static void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      ma += entity.close;
      if (i == day - 1) {
        entity.BOLLMA = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.BOLLMA = ma / day;
      } else {
        entity.BOLLMA = null;
      }
    }
  }

  static void _calcMACD(List<KLineEntity> dataList, [bool isLast = false]) {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      dif = data.dif!;
      dea = data.dea!;
      macd = data.macd!;
      ema12 = data.ema12!;
      ema26 = data.ema26!;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * 8 / 10 + dif * 2 / 10;
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
      entity.ema12 = ema12;
      entity.ema26 = ema26;
    }
  }

  static void _calcVolumeMA(List<KLineEntity> dataList, [bool isLast = false]) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    int i = 0;
    if (isLast && dataList.length > 10) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      volumeMa5 = data.MA5Volume! * 5;
      volumeMa10 = data.MA10Volume! * 10;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol.toDouble();
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol.toDouble();
        entry.MA10Volume = volumeMa10 / 10;
      } else {
        entry.MA10Volume = 0;
      }
    }
  }

  static void _calcRSI(List<KLineEntity> dataList, [bool isLast = false]) {
    double rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      rsi = data.rsi!;
      rsiABSEma = data.rsiABSEma!;
      rsiMaxEma = data.rsiMaxEma!;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double Rmax = max(0, closePrice - dataList[i - 1].close);
        double RAbs = (closePrice - dataList[i - 1].close).abs();

        rsiMaxEma = (Rmax + (14 - 1) * rsiMaxEma) / 14;
        rsiABSEma = (RAbs + (14 - 1) * rsiABSEma) / 14;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < 13) rsi = 0;
      if (rsi.isNaN) rsi = 0;
      entity.rsi = rsi;
      entity.rsiABSEma = rsiABSEma;
      entity.rsiMaxEma = rsiMaxEma;
    }
  }

  static void _calcKDJ(List<KLineEntity> dataList, [bool isLast = false]) {
    double k = 0;
    double d = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      k = data.k!;
      d = data.d!;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      int startIndex = i - 13;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = -double.maxFinite;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, dataList[index].high);
        min14 = min(min14, dataList[index].low);
      }
      double rsv = 100 * (closePrice - min14) / (max14 - min14);
      if (rsv.isNaN) {
        rsv = 0;
      }
      if (i == 0) {
        k = 50;
        d = 50;
      } else {
        k = (rsv + 2 * k) / 3;
        d = (k + 2 * d) / 3;
      }
      if (i < 13) {
        entity.k = 0;
        entity.d = 0;
        entity.j = 0;
      } else if (i == 13 || i == 14) {
        entity.k = k;
        entity.d = 0;
        entity.j = 0;
      } else {
        entity.k = k;
        entity.d = d;
        entity.j = 3 * k - 2 * d;
      }
    }
  }

  //WR(N) = 100 * [ HIGH(N)-C ] / [ HIGH(N)-LOW(N) ]
  static void _calcWR(List<KLineEntity> dataList, [bool isLast = false]) {
    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      int startIndex = i - 14;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = -double.maxFinite;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, dataList[index].high);
        min14 = min(min14, dataList[index].low);
      }
      if (i < 13) {
        entity.r = 0;
      } else {
        if ((max14 - min14) == 0) {
          entity.r = 0;
        } else {
          entity.r = 100 * (max14 - dataList[i].close) / (max14 - min14);
        }
      }
    }
  }

  static void _calcCCI(List<KLineEntity> dataList) {
    final size = dataList.length;
    final count = 14;
    for (int i = 0; i < size; i++) {
      final kline = dataList[i];
      final tp = (kline.high + kline.low + kline.close) / 3;
      final start = max(0, i - count + 1);
      var amount = 0.0;
      var len = 0;
      for (int n = start; n <= i; n++) {
        amount += (dataList[n].high + dataList[n].low + dataList[n].close) / 3;
        len++;
      }
      final ma = amount / len;
      amount = 0.0;
      for (int n = start; n <= i; n++) {
        amount +=
            (ma - (dataList[n].high + dataList[n].low + dataList[n].close) / 3)
                .abs();
      }
      final md = amount / len;
      kline.cci = ((tp - ma) / 0.015 / md);
      if (kline.cci!.isNaN) {
        kline.cci = 0.0;
      }
    }
  }

  //增量更新时计算最后一个数据
  static addLastData(
      List<KLineEntity>? dataList, KLineEntity? data, List<int> maDayList) {
    if (dataList == null || data == null) return;
    dataList.add(data);
    _calcMA(dataList, maDayList);
    _calcBOLL(dataList, n, k);
    _calcVolumeMA(dataList);
    _calcKDJ(dataList);
    _calcMACD(dataList);
    _calcRSI(dataList);
    _calcWR(dataList);
    _calcCCI(dataList);
  }

  //更新最后一条数据
  static updateLastData(List<KLineEntity>? dataList, List<int> maDayList) {
    if (dataList == null) return;
    _calcMA(dataList, maDayList);
    _calcBOLL(dataList, n, k);
    _calcVolumeMA(dataList);
    _calcKDJ(dataList);
    _calcMACD(dataList);
    _calcRSI(dataList);
    _calcWR(dataList);
    _calcCCI(dataList);
  }
}
