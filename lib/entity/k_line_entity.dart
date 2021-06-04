


import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  double? amount;
  int? count;
  int? id;

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toDouble();
    high = json['high']?.toDouble();
    low = json['low']?.toDouble();
    close = json['close']?.toDouble();
    vol = json['vol']?.toDouble();
    amount = json['amount']?.toDouble();
    count = json['count']?.toInt();
    id = json['id']?.toInt();
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['count'] = this.count;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }
}
