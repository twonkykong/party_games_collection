import 'package:flutter/material.dart';

import '../core/models/active_party.dart';
import '../core/models/game_type.dart';
import '../features/create/game_selection_screen.dart';
import '../features/games/spy/spy_game_screen.dart';
import '../features/games/whoami/whoami_game_screen.dart';
import '../features/games/mafia/mafia_game_screen.dart';
import '../features/games/bunker/bunker_game_screen.dart';
import '../features/games/alias/alias_game_screen.dart';
import '../features/home/home_screen.dart';
import '../features/join/join_party_screen.dart';
import '../features/rules/rules_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/setup/alias_setup_screen.dart';
import '../features/setup/bunker_setup_screen.dart';
import '../features/setup/mafia_setup_screen.dart';
import '../features/setup/spy_setup_screen.dart';
import '../features/setup/whoami_setup_screen.dart';

class AppRouter {
  static const homePath = '/';
  static const createPath = '/create';
  static const joinPath = '/join';
  static const rulesPath = '/rules';
  static const settingsPath = '/settings';
  static const spySetupPath = '/setup/spy';
  static const whoamiSetupPath = '/setup/whoami';
  static const mafiaSetupPath = '/setup/mafia';
  static const bunkerSetupPath = '/setup/bunker';
  static const aliasSetupPath = '/setup/alias';
  static const spyGamePath = '/game/spy';
  static const whoamiGamePath = '/game/whoami';
  static const mafiaGamePath = '/game/mafia';
  static const bunkerGamePath = '/game/bunker';
  static const aliasGamePath = '/game/alias';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePath:
        return _page(const HomeScreen(), settings);
      case createPath:
        return _page(const GameSelectionScreen(), settings);
      case joinPath:
        return _page(const JoinPartyScreen(), settings);
      case rulesPath:
        return _page(const RulesScreen(), settings);
      case settingsPath:
        return _page(const SettingsScreen(), settings);
      case spySetupPath:
        return _page(const SpySetupScreen(), settings);
      case whoamiSetupPath:
        return _page(const WhoAmISetupScreen(), settings);
      case mafiaSetupPath:
        return _page(const MafiaSetupScreen(), settings);
      case bunkerSetupPath:
        return _page(const BunkerSetupScreen(), settings);
      case aliasSetupPath:
        return _page(const AliasSetupScreen(), settings);
      case spyGamePath:
        return _page(
          SpyGameScreen(activeParty: settings.arguments! as ActiveParty),
          settings,
        );
      case whoamiGamePath:
        return _page(
          WhoAmIGameScreen(activeParty: settings.arguments! as ActiveParty),
          settings,
        );
      case mafiaGamePath:
        return _page(
          MafiaGameScreen(activeParty: settings.arguments! as ActiveParty),
          settings,
        );
      case bunkerGamePath:
        return _page(
          BunkerGameScreen(activeParty: settings.arguments! as ActiveParty),
          settings,
        );
      case aliasGamePath:
        return _page(
          AliasGameScreen(activeParty: settings.arguments! as ActiveParty),
          settings,
        );
      default:
        return _page(const HomeScreen(), settings);
    }
  }

  static String gameSetupPath(GameType gameType) {
    switch (gameType) {
      case GameType.spy:
        return spySetupPath;
      case GameType.whoAmI:
        return whoamiSetupPath;
      case GameType.mafia:
        return mafiaSetupPath;
      case GameType.bunker:
        return bunkerSetupPath;
      case GameType.alias:
        return aliasSetupPath;
    }
  }

  static String gamePath(GameType gameType) {
    switch (gameType) {
      case GameType.spy:
        return spyGamePath;
      case GameType.whoAmI:
        return whoamiGamePath;
      case GameType.mafia:
        return mafiaGamePath;
      case GameType.bunker:
        return bunkerGamePath;
      case GameType.alias:
        return aliasGamePath;
    }
  }

  static PageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, secondaryAnimation, page) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(curved),
            child: page,
          ),
        );
      },
    );
  }
}
