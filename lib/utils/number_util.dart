class NumberUtil {
  static String format(double n) {
    double d = n / 10000;
    if (d >= 10000) {
      d /= 1000;
      return "${d.toStringAsFixed(2)}K";
    } else {
      return d.toStringAsFixed(6);
    }
  }
}
