import '../../../core/services/deterministic_random.dart';
import '../../../data/models/whoami_word_entry.dart';

class WhoAmIPartyState {
  const WhoAmIPartyState({
    required this.assignments,
    required this.startingPlayerIndex,
  });

  final Map<int, WhoAmIWordEntry> assignments;
  final int startingPlayerIndex;
}

int _mixSeed(int seed, int salt) {
  var state = (seed ^ salt) & 0xFFFFFFFF;
  state = (1664525 * state + 1013904223) & 0xFFFFFFFF;
  state ^= (state << 13) & 0xFFFFFFFF;
  state ^= state >> 17;
  state ^= (state << 5) & 0xFFFFFFFF;
  return state & 0xFFFFFFFF;
}

WhoAmIPartyState resolveWhoAmIParty({
  required List<WhoAmIWordEntry> entries,
  required int seed,
  required int playerCount,
}) {
  if (entries.length < playerCount) {
    throw StateError('В словаре недостаточно слов для такой партии.');
  }
  final random = DeterministicRandom(_mixSeed(seed, 0x41C3));
  final starterRandom = DeterministicRandom(_mixSeed(seed, 0x57A4));
  final selected = random.shuffled(entries).take(playerCount).toList();
  final players = List<int>.generate(playerCount, (index) => index + 1);
  return WhoAmIPartyState(
    assignments: {for (var i = 0; i < selected.length; i++) i + 1: selected[i]},
    startingPlayerIndex: players[starterRandom.nextInt(players.length)],
  );
}
