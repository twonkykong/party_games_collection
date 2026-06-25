import '../../../core/services/deterministic_random.dart';
import '../../../data/models/spy_word_entry.dart';

class SpyPartyState {
  const SpyPartyState({
    required this.entry,
    required this.hint,
    required this.spyPlayerIndexes,
    required this.startingPlayerIndex,
  });

  final SpyWordEntry entry;
  final String hint;
  final Set<int> spyPlayerIndexes;
  final int startingPlayerIndex;

  bool isSpy(int playerIndex) => spyPlayerIndexes.contains(playerIndex);
}

int _mixSeed(int seed, int salt) {
  var state = (seed ^ salt) & 0xFFFFFFFF;
  state = (1664525 * state + 1013904223) & 0xFFFFFFFF;
  state ^= (state << 13) & 0xFFFFFFFF;
  state ^= state >> 17;
  state ^= (state << 5) & 0xFFFFFFFF;
  return state & 0xFFFFFFFF;
}

SpyPartyState resolveSpyParty({
  required List<SpyWordEntry> entries,
  required int seed,
  required int playerCount,
  required int spyCount,
}) {
  final wordRandom = DeterministicRandom(_mixSeed(seed, 0x51A7));
  final hintRandom = DeterministicRandom(_mixSeed(seed, 0x917A));
  final spyRandom = DeterministicRandom(_mixSeed(seed, 0x5A11));
  final starterRandom = DeterministicRandom(_mixSeed(seed, 0x57A4));

  final entry = entries[wordRandom.nextInt(entries.length)];
  final hint = entry.hints[hintRandom.nextInt(entry.hints.length)];
  final players = List<int>.generate(playerCount, (index) => index + 1);
  final spies = spyRandom.shuffled(players).take(spyCount).toSet();
  final startingPlayerIndex = players[starterRandom.nextInt(players.length)];
  return SpyPartyState(
    entry: entry,
    hint: hint,
    spyPlayerIndexes: spies,
    startingPlayerIndex: startingPlayerIndex,
  );
}
