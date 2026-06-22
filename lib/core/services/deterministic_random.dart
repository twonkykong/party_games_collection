class DeterministicRandom {
  DeterministicRandom(int seed) : _state = (seed ^ 0x9E3779B9) & _mask;

  static const _mask = 0xFFFFFFFF;
  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'Must be positive.');
    }
    _state = (1664525 * _state + 1013904223) & _mask;
    return _state % max;
  }

  List<T> shuffled<T>(List<T> source) {
    final list = List<T>.from(source);
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final current = list[i];
      list[i] = list[j];
      list[j] = current;
    }
    return list;
  }
}
