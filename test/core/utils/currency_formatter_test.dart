import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/core/utils/currency_formatter.dart';

void main() {
  test('formats whole and fractional NPR values consistently', () {
    expect(formatNpr(18000), 'Rs. 18,000');
    expect(formatNpr(29500.5), 'Rs. 29,500.5');
  });
}
