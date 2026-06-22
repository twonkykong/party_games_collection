class SpyWordEntry {
  const SpyWordEntry({
    required this.word,
    required this.hints,
    required this.rating,
  });

  final String word;
  final List<String> hints;
  final String rating;

  factory SpyWordEntry.fromJson(Map<String, dynamic> json) {
    return SpyWordEntry(
      word: json['word'] as String,
      hints: List<String>.from(json['hints'] as List<dynamic>),
      rating: json['rating'] as String,
    );
  }
}
