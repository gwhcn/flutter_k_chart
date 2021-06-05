// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'k_line_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KLineEntity _$KLineEntityFromJson(Map<String, dynamic> json) {
  return KLineEntity(
    open: (json['open'] as num).toDouble(),
    high: (json['high'] as num).toDouble(),
    low: (json['low'] as num).toDouble(),
    close: (json['close'] as num).toDouble(),
    vol: (json['vol'] as num).toDouble(),
    amount: (json['amount'] as num?)?.toDouble(),
    count: json['count'] as int?,
    id: json['id'] as int?,
  )
    ..k = (json['k'] as num?)?.toDouble()
    ..cci = (json['cci'] as num?)?.toDouble()
    ..r = (json['r'] as num?)?.toDouble()
    ..rsi = (json['rsi'] as num?)?.toDouble()
    ..d = (json['d'] as num?)?.toDouble()
    ..j = (json['j'] as num?)?.toDouble()
    ..rsiABSEma = (json['rsiABSEma'] as num?)?.toDouble()
    ..rsiMaxEma = (json['rsiMaxEma'] as num?)?.toDouble()
    ..MA5Volume = (json['MA5Volume'] as num?)?.toDouble()
    ..MA10Volume = (json['MA10Volume'] as num?)?.toDouble()
    ..maValueList = (json['maValueList'] as List<dynamic>?)
        ?.map((e) => (e as num).toDouble())
        .toList()
    ..dea = (json['dea'] as num?)?.toDouble()
    ..dif = (json['dif'] as num?)?.toDouble()
    ..macd = (json['macd'] as num?)?.toDouble()
    ..ema12 = (json['ema12'] as num?)?.toDouble()
    ..ema26 = (json['ema26'] as num?)?.toDouble()
    ..up = (json['up'] as num?)?.toDouble()
    ..mb = (json['mb'] as num?)?.toDouble()
    ..dn = (json['dn'] as num?)?.toDouble()
    ..BOLLMA = (json['BOLLMA'] as num?)?.toDouble();
}

Map<String, dynamic> _$KLineEntityToJson(KLineEntity instance) =>
    <String, dynamic>{
      'k': instance.k,
      'cci': instance.cci,
      'r': instance.r,
      'rsi': instance.rsi,
      'd': instance.d,
      'j': instance.j,
      'rsiABSEma': instance.rsiABSEma,
      'rsiMaxEma': instance.rsiMaxEma,
      'MA5Volume': instance.MA5Volume,
      'MA10Volume': instance.MA10Volume,
      'maValueList': instance.maValueList,
      'dea': instance.dea,
      'dif': instance.dif,
      'macd': instance.macd,
      'ema12': instance.ema12,
      'ema26': instance.ema26,
      'up': instance.up,
      'mb': instance.mb,
      'dn': instance.dn,
      'BOLLMA': instance.BOLLMA,
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'vol': instance.vol,
      'amount': instance.amount,
      'count': instance.count,
      'id': instance.id,
    };
