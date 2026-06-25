enum WordSourceMode {
  builtIn('built_in', 'Встроенные'),
  mixed('mixed', 'Встроенные + свои'),
  customOnly('custom_only', 'Только свои');

  const WordSourceMode(this.code, this.label);

  final String code;
  final String label;

  static WordSourceMode fromCode(String? code) {
    return WordSourceMode.values.firstWhere(
      (value) => value.code == code,
      orElse: () => WordSourceMode.builtIn,
    );
  }
}
