import 'dictionary_mode.dart';
import 'game_type.dart';
import 'party_code_version.dart';
import 'word_source_mode.dart';

class PartyConfiguration {
  const PartyConfiguration({
    required this.version,
    required this.gameType,
    required this.playerCount,
    required this.dictionaryMode,
    required this.wordSourceMode,
    required this.seed,
    this.spyCount,
    this.mafiaPresetId,
    this.aliasRoundSeconds,
    this.aliasTargetScore,
  });

  final PartyCodeVersion version;
  final GameType gameType;
  final int playerCount;
  final DictionaryMode dictionaryMode;
  final WordSourceMode wordSourceMode;
  final int seed;
  final int? spyCount;
  final String? mafiaPresetId;
  final int? aliasRoundSeconds;
  final int? aliasTargetScore;

  Map<String, dynamic> toJson() {
    return {
      'version': version.value,
      'gameType': gameType.code,
      'playerCount': playerCount,
      'dictionaryMode': dictionaryMode.code,
      'wordSourceMode': wordSourceMode.code,
      'seed': seed,
      'spyCount': spyCount,
      'mafiaPresetId': mafiaPresetId,
      'aliasRoundSeconds': aliasRoundSeconds,
      'aliasTargetScore': aliasTargetScore,
    };
  }
}
