// ignore_for_file: avoid_print

import 'dart:math';

import 'package:party_games_collection/data/models/spy_word_entry.dart';
import 'package:party_games_collection/features/games/spy/spy_party_state.dart';

void main(List<String> args) {
  final runs = args.isNotEmpty ? int.tryParse(args.first) ?? 1000 : 1000;
  const playerCount = 6;
  const spyCount = 1;

  final entries = List<SpyWordEntry>.generate(
    24,
    (index) => SpyWordEntry(
      word: 'word_$index',
      hints: ['hint_${index}_a', 'hint_${index}_b', 'hint_${index}_c'],
      rating: 'family',
    ),
  );

  final starterCounts = <int, int>{
    for (var i = 1; i <= playerCount; i++) i: 0,
  };
  final spyCounts = <int, int>{
    for (var i = 1; i <= playerCount; i++) i: 0,
  };

  for (var seed = 1; seed <= runs; seed++) {
    final state = resolveSpyParty(
      entries: entries,
      seed: seed * 7919 + Random(seed).nextInt(1 << 20),
      playerCount: playerCount,
      spyCount: spyCount,
    );
    starterCounts[state.startingPlayerIndex] =
        (starterCounts[state.startingPlayerIndex] ?? 0) + 1;
    for (final index in state.spyPlayerIndexes) {
      spyCounts[index] = (spyCounts[index] ?? 0) + 1;
    }
  }

  print('Spy fairness report');
  print('runs: $runs, players: $playerCount, spies: $spyCount');
  print('');
  print('Starting player distribution:');
  for (var i = 1; i <= playerCount; i++) {
    print('player $i: ${starterCounts[i]}');
  }
  print('');
  print('Spy distribution:');
  for (var i = 1; i <= playerCount; i++) {
    print('player $i: ${spyCounts[i]}');
  }
}
