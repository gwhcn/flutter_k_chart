mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  double? MA5Price;
  double? MA10Price;
  double? MA20Price;
  double? MA30Price;

//  上轨线
  double? up;

//  中轨线
  double? mb;

//  下轨线
  double? dn;
}
