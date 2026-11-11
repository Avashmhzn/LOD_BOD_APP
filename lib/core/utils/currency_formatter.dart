import 'package:intl/intl.dart';

final NumberFormat _nprNumberFormat = NumberFormat('#,##0.##', 'en_US');

String formatNpr(num amount) => 'Rs. ${_nprNumberFormat.format(amount)}';
