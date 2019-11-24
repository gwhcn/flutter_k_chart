import 'dart:math';

import '../entity/k_line_entity.dart';

class DataUtil {
  static calculate(List<KLineEntity> dataList) {
    if (dataList == null) return;
    _calcMA(dataList);
    _calcBOLL(dataList);
    _calcVolumeMA(dataList);
    _calcKDJ(dataList);
    _calcMACD(dataList);
    _calcRSI(dataList);
    _calcWR(dataList);
  }

  static _calcMA(List<KLineEntity> dataList, [bool isLast = false]) {
    double ma5 = 0;
    double ma10 = 0;
    double ma20 = 0;
    double ma30 = 0;
//    double ma60 = 0;

    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      ma5 = data.MA5Price * 5;
      ma10 = data.MA10Price * 10;
      ma20 = data.MA20Price * 20;
      ma30 = data.MA30Price * 30;
//      ma60 = data.MA60Price * 60;
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      ma5 += closePrice;
      ma10 += closePrice;
      ma20 += closePrice;
      ma30 += closePrice;
//      ma60 += closePrice;

      if (i == 4) {
        entity.MA5Price = ma5 / 5;
      } else if (i >= 5) {
        ma5 -= dataList[i - 5].close;
        entity.MA5Price = ma5 / 5;
      } else {
        entity.MA5Price = 0;
      }
      if (i == 9) {
        entity.MA10Price = ma10 / 10;
      } else if (i >= 10) {
        ma10 -= dataList[i - 10].close;
        entity.MA10Price = ma10 / 10;
      } else {
        entity.MA10Price = 0;
      }
      if (i == 19) {
        entity.MA20Price = ma20 / 20;
      } else if (i >= 20) {
        ma20 -= dataList[i - 20].close;
        entity.MA20Price = ma20 / 20;
      } else {
        entity.MA20Price = 0;
      }
      if (i == 29) {
        entity.MA30Price = ma30 / 30;
      } else if (i >= 30) {
        ma30 -= dataList[i - 30].close;
        entity.MA30Price = ma30 / 30;
      } else {
        entity.MA30Price = 0;
      }
//      if (i == 59) {
//        entity.MA60Price = ma60 / 60;
//      } else if (i >= 60) {
//        ma60 -= dataList[i - 60].close;
//        entity.MA60Price = ma60 / 60;
//      } else {
//        entity.MA60Price = 0;
//      }
    }
  }

  static void _calcBOLL(List<KLineEntity> dataList, [bool isLast = false]) {
    int i = 0;
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
    }
    for (; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i < 19) {
        entity.mb = 0;
        entity.up = 0;
        entity.dn = 0;
      } else {
        int n = 20;
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.MA20Price;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.mb = entity.MA20Price;
        entity.up = entity.mb + 2.0 * md;
        entity.dn = entity.mb - 2.0 * md;
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
      dif = data.dif;
      dea = data.dea;
      macd = data.macd;
      ema12 = data.ema12;
      ema26 = data.ema26;
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
    if (isLast && dataList.length > 1) {
      i = dataList.length - 1;
      var data = dataList[dataList.length - 2];
      volumeMa5 = data.MA5Volume * 5;
      volumeMa10 = data.MA10Volume * 10;
    }

    for (; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.MA5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol;
        entry.MA5Volume = volumeMa5 / 5;
      } else {
        entry.MA5Volume = 0;
      }

      if (i == 9) {
        entry.MA10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol;
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
      rsi = data.rsi;
      rsiABSEma = data.rsiABSEma;
      rsiMaxEma = data.rsiMaxEma;
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
      k = data.k;
      d = data.d;
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

  //增量更新时计算最后一个数据
  static addLastData(List<KLineEntity> dataList, KLineEntity data) {
    if (dataList == null || data == null) return;
    dataList.add(data);
    _calcMA(dataList, true);
    _calcBOLL(dataList, true);
    _calcVolumeMA(dataList, true);
    _calcKDJ(dataList, true);
    _calcMACD(dataList, true);
    _calcRSI(dataList, true);
    _calcWR(dataList, true);
  }

  //更新最后一条数据
  static updateLastData(List<KLineEntity> dataList) {
    if (dataList == null) return;
    _calcMA(dataList, true);
    _calcBOLL(dataList, true);
    _calcVolumeMA(dataList, true);
    _calcKDJ(dataList, true);
    _calcMACD(dataList, true);
    _calcRSI(dataList, true);
    _calcWR(dataList, true);
  }
}
