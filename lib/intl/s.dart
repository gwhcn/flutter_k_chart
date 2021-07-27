import 'package:flutter/widgets.dart';

import 'delegate.dart';

class KChartS {
  static const delegate = KChartLocalizationsDelegate();

  final String date;
  final String open;
  final String high;
  final String low;
  final String close;
  final String change;
  final String change_;
  final String executed;

  const KChartS({
    this.date = 'Date',
    this.open = 'Open',
    this.high = 'close',
    this.low = 'L',
    this.close = 'Close',
    this.change = 'Change',
    this.change_ = 'Change%',
    this.executed = 'Executed',
  });

  static KChartS of(BuildContext context) {
    return Localizations.of(context, KChartS);
  }
}
