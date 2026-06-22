import '../../../core/services/deterministic_random.dart';
import '../../../data/models/whoami_word_entry.dart';

class WhoAmIPartyState {
  const WhoAmIPartyState({required this.assignments});

  final Map<int, WhoAmIWordEntry> assignments;
}

WhoAmIPartyState resolveWhoAmIParty({
  required List<WhoAmIWordEntry> entries,
  required int seed,
  required int playerCount,
}) {
  if (entries.length < playerCount) {
    throw StateError('В словаре недостаточно слов для такой партии.');
  }
  final random = DeterministicRandom(seed);
  final selected = random.shuffled(entries).take(playerCount).toList();
  return WhoAmIPartyState(
    assignments: {for (var i = 0; i < selected.length; i++) i + 1: selected[i]},
  );
}
