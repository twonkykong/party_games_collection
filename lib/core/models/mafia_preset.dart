enum MafiaPreset {
  classic('classic', 'Классика'),
  expanded('expanded', 'Расширенная');

  const MafiaPreset(this.code, this.label);

  final String code;
  final String label;

  static MafiaPreset fromCode(String code) {
    return MafiaPreset.values.firstWhere((value) => value.code == code);
  }
}
