import 'game_type.dart';
import 'party_configuration.dart';

class ActiveParty {
  const ActiveParty({
    required this.code,
    required this.playerIndex,
    required this.configuration,
  });

  final String code;
  final int playerIndex;
  final PartyConfiguration configuration;

  GameType get gameType => configuration.gameType;
}
