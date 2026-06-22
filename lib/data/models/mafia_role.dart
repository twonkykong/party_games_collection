class MafiaRole {
  const MafiaRole({
    required this.id,
    required this.title,
    required this.team,
    required this.description,
    required this.difficulty,
  });

  final String id;
  final String title;
  final String team;
  final String description;
  final String difficulty;

  factory MafiaRole.fromJson(Map<String, dynamic> json) {
    return MafiaRole(
      id: json['id'] as String,
      title: json['title'] as String,
      team: json['team'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String? ?? 'easy',
    );
  }
}
