class AliasWordEntry {
  const AliasWordEntry({required this.value, required this.rating});

  final String value;
  final String rating;

  factory AliasWordEntry.fromJson(Map<String, dynamic> json) {
    return AliasWordEntry(
      value: json['value'] as String,
      rating: json['rating'] as String? ?? 'family',
    );
  }
}
