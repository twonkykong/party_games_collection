class WhoAmIWordEntry {
  const WhoAmIWordEntry({required this.value, required this.rating});

  final String value;
  final String rating;

  factory WhoAmIWordEntry.fromJson(Map<String, dynamic> json) {
    return WhoAmIWordEntry(
      value: json['value'] as String,
      rating: json['rating'] as String,
    );
  }
}
