import '../../../core/services/deterministic_random.dart';
import '../../../data/models/spy_word_entry.dart';

class SpyPartyState {
  const SpyPartyState({
    required this.entry,
    required this.hint,
    required this.spyPlayerIndexes,
  });

  final SpyWordEntry entry;
  final String hint;
  final Set<int> spyPlayerIndexes;

  bool isSpy(int playerIndex) => spyPlayerIndexes.contains(playerIndex);
}

SpyPartyState resolveSpyParty({
  required List<SpyWordEntry> entries,
  required int seed,
  required int playerCount,
  required int spyCount,
}) {
  final random = DeterministicRandom(seed);
  final entry = entries[random.nextInt(entries.length)];
  final hint = entry.hints[random.nextInt(entry.hints.length)];
  final players = List<int>.generate(playerCount, (index) => index + 1);
  final spies = random.shuffled(players).take(spyCount).toSet();
  return SpyPartyState(entry: entry, hint: hint, spyPlayerIndexes: spies);
}
