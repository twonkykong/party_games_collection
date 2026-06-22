class AliasPartyState {
  const AliasPartyState({
    required this.words,
    required this.teamCount,
    required this.roundSeconds,
    required this.targetScore,
  });

  final List<String> words;
  final int teamCount;
  final int roundSeconds;
  final int targetScore;
}
