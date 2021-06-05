import 'package:json_annotation/json_annotation.dart';

import '../entity/k_entity.dart';

part 'k_line_entity.g.dart';

@JsonSerializable()
class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  double? amount;
  int? count;
  int? id;

  KLineEntity({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.vol,
    this.amount,
    this.count,
    this.id,
  });

  factory KLineEntity.fromJson(Map<String, dynamic> json) =>
      _$KLineEntityFromJson(json);

  Map<String, dynamic> toJson() => _$KLineEntityToJson(this);

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, id: $id}';
  }
}
