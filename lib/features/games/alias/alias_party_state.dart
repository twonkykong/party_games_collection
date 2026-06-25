import '../../../core/services/deterministic_random.dart';

class AliasPartyState {
  const AliasPartyState({
    required this.words,
    required this.teamCount,
    required this.roundSeconds,
    required this.targetScore,
    required this.startingTeamIndex,
  });

  final List<String> words;
  final int teamCount;
  final int roundSeconds;
  final int targetScore;
  final int startingTeamIndex;
}

int _mixSeed(int seed, int salt) {
  var state = (seed ^ salt) & 0xFFFFFFFF;
  state = (1664525 * state + 1013904223) & 0xFFFFFFFF;
  state ^= (state << 13) & 0xFFFFFFFF;
  state ^= state >> 17;
  state ^= (state << 5) & 0xFFFFFFFF;
  return state & 0xFFFFFFFF;
}

AliasPartyState resolveAliasParty({
  required List<String> words,
  required int seed,
  required int teamCount,
  required int roundSeconds,
  required int targetScore,
}) {
  final deckRandom = DeterministicRandom(_mixSeed(seed, 0xA11A5));
  final starterRandom = DeterministicRandom(_mixSeed(seed, 0x57A4));
  final teams = List<int>.generate(teamCount, (index) => index + 1);
  final deck = deckRandom.shuffled(words).take(120).toList(growable: false);
  return AliasPartyState(
    words: deck,
    teamCount: teamCount,
    roundSeconds: roundSeconds,
    targetScore: targetScore,
    startingTeamIndex: teams[starterRandom.nextInt(teams.length)],
  );
}
