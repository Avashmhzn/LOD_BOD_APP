class ShipmentReference {
  static const _firstNumber = 1001;
  static const _lastSupportedNumber = 999999;

  static String next(
    Iterable<String?> references, {
    int lastNumber = _firstNumber - 1,
  }) {
    var highestNumber = lastNumber < _firstNumber - 1
        ? _firstNumber - 1
        : lastNumber;
    final pattern = RegExp(r'^LOD-(\d+)$', caseSensitive: false);

    for (final reference in references) {
      final match = pattern.firstMatch(reference?.trim() ?? '');
      final number = int.tryParse(match?.group(1) ?? '');
      if (number != null &&
          number >= _firstNumber &&
          number <= _lastSupportedNumber &&
          number > highestNumber) {
        highestNumber = number;
      }
    }

    return 'LOD-${(highestNumber + 1).toString().padLeft(4, '0')}';
  }
}
