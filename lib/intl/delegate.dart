import 'package:flutter/widgets.dart';

import 's.dart';

KChartS _loadEn() => KChartS();
KChartS _loadZhHans() => KChartS(
      date: '时间',
      open: '开',
      high: '高',
      low: '低',
      close: '收',
      change: '涨跌额',
      change_: '涨跌幅',
      executed: '成交量',
    );
KChartS _loadZhHant() => KChartS(
      date: '時間',
      open: '開',
      high: '高',
      low: '低',
      close: '收',
      change: '漲跌額',
      change_: '漲跌幅',
      executed: '成交量',
    );

KChartS _loadMessages(Locale locale) {
  print(locale);
  switch (locale.languageCode) {
    case 'zh':
      switch (locale.scriptCode) {
        case 'Hans':
          return _loadZhHans();
        case 'Hant':
          return _loadZhHant();
      }
      switch (locale.countryCode) {
        case 'CN':
        case 'SG':
          return _loadZhHans();
        case 'HK':
        case 'MO':
        case 'TW':
          return _loadZhHant();
      }
      return _loadZhHans();
    default:
      return _loadEn();
  }
}

class KChartLocalizationsDelegate extends LocalizationsDelegate<KChartS> {
  static const supportedLanguage = ['en', 'zh'];

  const KChartLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return supportedLanguage.contains(locale.languageCode);
  }

  @override
  Future<KChartS> load(Locale locale) async {
    return _loadMessages(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<KChartS> old) {
    return false;
  }
}
