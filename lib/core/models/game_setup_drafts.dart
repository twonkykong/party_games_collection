import 'dictionary_mode.dart';
import 'mafia_preset.dart';

class SpySetupDraft {
  const SpySetupDraft({
    required this.playerCount,
    required this.spyCount,
    required this.dictionaryMode,
  });

  final int playerCount;
  final int spyCount;
  final DictionaryMode dictionaryMode;

  Map<String, dynamic> toJson() => {
    'playerCount': playerCount,
    'spyCount': spyCount,
    'dictionaryMode': dictionaryMode.code,
  };

  factory SpySetupDraft.fromJson(Map<String, dynamic> json) {
    return SpySetupDraft(
      playerCount: json['playerCount'] as int? ?? 4,
      spyCount: json['spyCount'] as int? ?? 1,
      dictionaryMode: DictionaryMode.fromCode(
        json['dictionaryMode'] as String? ?? DictionaryMode.family.code,
      ),
    );
  }
}

class WhoAmISetupDraft {
  const WhoAmISetupDraft({
    required this.playerCount,
    required this.dictionaryMode,
  });

  final int playerCount;
  final DictionaryMode dictionaryMode;

  Map<String, dynamic> toJson() => {
    'playerCount': playerCount,
    'dictionaryMode': dictionaryMode.code,
  };

  factory WhoAmISetupDraft.fromJson(Map<String, dynamic> json) {
    return WhoAmISetupDraft(
      playerCount: json['playerCount'] as int? ?? 4,
      dictionaryMode: DictionaryMode.fromCode(
        json['dictionaryMode'] as String? ?? DictionaryMode.family.code,
      ),
    );
  }
}

class MafiaSetupDraft {
  const MafiaSetupDraft({required this.playerCount, required this.preset});

  final int playerCount;
  final MafiaPreset preset;

  Map<String, dynamic> toJson() => {
    'playerCount': playerCount,
    'preset': preset.code,
  };

  factory MafiaSetupDraft.fromJson(Map<String, dynamic> json) {
    return MafiaSetupDraft(
      playerCount: json['playerCount'] as int? ?? 6,
      preset: MafiaPreset.fromCode(
        json['preset'] as String? ?? MafiaPreset.classic.code,
      ),
    );
  }
}

class BunkerSetupDraft {
  const BunkerSetupDraft({required this.playerCount});

  final int playerCount;

  Map<String, dynamic> toJson() => {'playerCount': playerCount};

  factory BunkerSetupDraft.fromJson(Map<String, dynamic> json) {
    return BunkerSetupDraft(playerCount: json['playerCount'] as int? ?? 6);
  }
}

class AliasSetupDraft {
  const AliasSetupDraft({
    required this.teamCount,
    required this.roundSeconds,
    required this.targetScore,
    required this.dictionaryMode,
  });

  final int teamCount;
  final int roundSeconds;
  final int targetScore;
  final DictionaryMode dictionaryMode;

  Map<String, dynamic> toJson() => {
    'teamCount': teamCount,
    'roundSeconds': roundSeconds,
    'targetScore': targetScore,
    'dictionaryMode': dictionaryMode.code,
  };

  factory AliasSetupDraft.fromJson(Map<String, dynamic> json) {
    return AliasSetupDraft(
      teamCount: json['teamCount'] as int? ?? 2,
      roundSeconds: json['roundSeconds'] as int? ?? 60,
      targetScore: json['targetScore'] as int? ?? 30,
      dictionaryMode: DictionaryMode.fromCode(
        json['dictionaryMode'] as String? ?? DictionaryMode.family.code,
      ),
    );
  }
}
