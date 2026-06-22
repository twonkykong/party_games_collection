import 'package:flutter_test/flutter_test.dart';

import 'package:party_games_collection/core/models/dictionary_mode.dart';
import 'package:party_games_collection/core/models/game_type.dart';
import 'package:party_games_collection/core/models/party_code_version.dart';
import 'package:party_games_collection/core/models/party_configuration.dart';
import 'package:party_games_collection/core/services/party_code_codec.dart';
import 'package:party_games_collection/data/models/spy_word_entry.dart';
import 'package:party_games_collection/data/models/whoami_word_entry.dart';
import 'package:party_games_collection/features/games/spy/spy_party_state.dart';
import 'package:party_games_collection/features/games/whoami/whoami_party_state.dart';

void main() {
  test('legacy v1 party code keeps stable configuration payload', () {
    const codec = PartyCodeCodec();
    const configuration = PartyConfiguration(
      version: PartyCodeVersion.v1,
      gameType: GameType.spy,
      playerCount: 7,
      dictionaryMode: DictionaryMode.mixed,
      seed: 123456789,
      spyCount: 2,
    );

    final encoded = codec.encode(configuration);
    final decoded = codec.decode(encoded);

    expect(decoded.version, configuration.version);
    expect(decoded.gameType, configuration.gameType);
    expect(decoded.playerCount, configuration.playerCount);
    expect(decoded.dictionaryMode, configuration.dictionaryMode);
    expect(decoded.seed, configuration.seed);
    expect(decoded.spyCount, configuration.spyCount);
    expect(encoded.length, 11);
  });

  test('v2 party code is variable-length and decodes stably', () {
    const codec = PartyCodeCodec();
    const configuration = PartyConfiguration(
      version: PartyCodeVersion.v2,
      gameType: GameType.whoAmI,
      playerCount: 6,
      dictionaryMode: DictionaryMode.family,
      seed: 987654321,
    );

    final encoded = codec.encode(configuration);
    final decoded = codec.decode(encoded);

    expect(decoded.version, configuration.version);
    expect(decoded.gameType, configuration.gameType);
    expect(decoded.playerCount, configuration.playerCount);
    expect(decoded.dictionaryMode, configuration.dictionaryMode);
    expect(decoded.seed, configuration.seed);
    expect(encoded.isNotEmpty, isTrue);
    expect(encoded.length <= 11, isTrue);
  });

  test('v3 mafia code keeps preset and player count', () {
    const codec = PartyCodeCodec();
    const configuration = PartyConfiguration(
      version: PartyCodeVersion.v3,
      gameType: GameType.mafia,
      playerCount: 8,
      dictionaryMode: DictionaryMode.family,
      seed: 123456,
      mafiaPresetId: 'expanded',
    );

    final encoded = codec.encode(configuration);
    final decoded = codec.decode(encoded);

    expect(decoded.version, PartyCodeVersion.v3);
    expect(decoded.gameType, GameType.mafia);
    expect(decoded.playerCount, 8);
    expect(decoded.mafiaPresetId, 'expanded');
    expect(decoded.seed, 123456);
  });

  test('v3 alias code keeps round and target score', () {
    const codec = PartyCodeCodec();
    const configuration = PartyConfiguration(
      version: PartyCodeVersion.v3,
      gameType: GameType.alias,
      playerCount: 3,
      dictionaryMode: DictionaryMode.family,
      seed: 654321,
      aliasRoundSeconds: 90,
      aliasTargetScore: 40,
    );

    final encoded = codec.encode(configuration);
    final decoded = codec.decode(encoded);

    expect(decoded.version, PartyCodeVersion.v3);
    expect(decoded.gameType, GameType.alias);
    expect(decoded.playerCount, 3);
    expect(decoded.aliasRoundSeconds, 90);
    expect(decoded.aliasTargetScore, 40);
    expect(decoded.seed, 654321);
  });

  test('whoami generation is deterministic for the same seed and indices', () {
    final entries = List.generate(
      8,
      (index) => WhoAmIWordEntry(value: 'word_$index', rating: 'family'),
    );

    final first = resolveWhoAmIParty(
      entries: entries,
      seed: 42,
      playerCount: 5,
    );
    final second = resolveWhoAmIParty(
      entries: entries,
      seed: 42,
      playerCount: 5,
    );

    expect(first.assignments.keys.toList(), second.assignments.keys.toList());
    expect(
      first.assignments.values.map((item) => item.value).toList(),
      second.assignments.values.map((item) => item.value).toList(),
    );
  });

  test('spy generation is deterministic for word, hint and spy roles', () {
    final entries = [
      const SpyWordEntry(
        word: 'alpha',
        hints: ['a1', 'a2', 'a3'],
        rating: 'family',
      ),
      const SpyWordEntry(
        word: 'beta',
        hints: ['b1', 'b2', 'b3'],
        rating: 'family',
      ),
      const SpyWordEntry(
        word: 'gamma',
        hints: ['g1', 'g2', 'g3'],
        rating: 'family',
      ),
    ];

    final first = resolveSpyParty(
      entries: entries,
      seed: 314159,
      playerCount: 6,
      spyCount: 2,
    );
    final second = resolveSpyParty(
      entries: entries,
      seed: 314159,
      playerCount: 6,
      spyCount: 2,
    );

    expect(first.entry.word, second.entry.word);
    expect(first.hint, second.hint);
    expect(first.spyPlayerIndexes, second.spyPlayerIndexes);
  });
}
