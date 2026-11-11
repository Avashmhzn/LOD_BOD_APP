import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/features/shipment/domain/utils/shipment_reference.dart';

void main() {
  group('ShipmentReference.next', () {
    test('starts the first request at LOD-1001', () {
      expect(ShipmentReference.next(const []), 'LOD-1001');
    });

    test('increments from the highest existing numbered request', () {
      expect(
        ShipmentReference.next(['LOD-1001', 'LOD-1003', 'LOD-1002']),
        'LOD-1004',
      );
    });

    test('ignores legacy timestamp-based references', () {
      expect(ShipmentReference.next(['LOD-12345678']), 'LOD-1001');
    });
  });
}
