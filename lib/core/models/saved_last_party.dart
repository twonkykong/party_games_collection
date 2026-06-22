import 'game_type.dart';

class SavedLastParty {
  const SavedLastParty({
    required this.code,
    required this.playerIndex,
    required this.gameType,
    required this.savedAtIso,
  });

  final String code;
  final int playerIndex;
  final GameType gameType;
  final String savedAtIso;

  Map<String, dynamic> toJson() => {
    'code': code,
    'playerIndex': playerIndex,
    'gameType': gameType.code,
    'savedAtIso': savedAtIso,
  };

  factory SavedLastParty.fromJson(Map<String, dynamic> json) {
    final rawIndex = json['playerIndex'];
    final playerIndex =
        rawIndex is num && rawIndex.isFinite ? rawIndex.toInt() : 1;
    return SavedLastParty(
      code: json['code'] as String,
      playerIndex: playerIndex,
      gameType: GameType.fromCode(json['gameType'] as String),
      savedAtIso:
          json['savedAtIso'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
