import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  static final DateFormat shortDate = DateFormat('dd MMM yyyy');
}
