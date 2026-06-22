enum DictionaryMode {
  family('family', 'Обычные'),
  mixed('mixed', 'Любые'),
  dirty('dirty', 'Без цензуры');

  const DictionaryMode(this.code, this.label);

  final String code;
  final String label;

  bool allows(String rating) {
    switch (this) {
      case DictionaryMode.family:
        return rating == 'family';
      case DictionaryMode.mixed:
        return true;
      case DictionaryMode.dirty:
        return rating == 'dirty';
    }
  }

  static DictionaryMode fromCode(String code) {
    return DictionaryMode.values.firstWhere((value) => value.code == code);
  }
}
