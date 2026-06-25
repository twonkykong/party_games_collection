import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import '../../core/models/active_party.dart';
import '../../core/models/party_configuration.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/ui_sound_service.dart';
import 'app_bottom_sheet_frame.dart';
import 'section_card.dart';

Future<void> showGameCompletionSheet(
  BuildContext context, {
  required ActiveParty activeParty,
}) {
  final palette = AppPalette.of(context);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) =>
            _GameCompletionSheet(activeParty: activeParty, palette: palette),
  );
}

class _GameCompletionSheet extends StatelessWidget {
  const _GameCompletionSheet({
    required this.activeParty,
    required this.palette,
  });

  final ActiveParty activeParty;
  final AppPalette palette;

  PartyConfiguration _buildNextConfiguration(BuildContext context) {
    final app = AppScope.of(context);
    final current = activeParty.configuration;
    return PartyConfiguration(
      version: current.version,
      gameType: current.gameType,
      playerCount: current.playerCount,
      dictionaryMode: current.dictionaryMode,
      wordSourceMode: current.wordSourceMode,
      seed: app.codec.generateNextSeed(activeParty.code, current.gameType),
      spyCount: current.spyCount,
      mafiaPresetId: current.mafiaPresetId,
      aliasRoundSeconds: current.aliasRoundSeconds,
      aliasTargetScore: current.aliasTargetScore,
    );
  }

  Future<void> _openNextGame(BuildContext context) async {
    final app = AppScope.of(context);
    final nextConfiguration = _buildNextConfiguration(context);
    final nextCode = app.codec.encode(nextConfiguration);
    final nextParty = app.runtime.buildActivePartyFromCode(
      nextCode,
      activeParty.playerIndex,
    );
    await app.saveActiveParty(nextParty);
    app.playSound(UiSound.successSoft);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.gamePath(nextParty.gameType),
      (route) {
        final name = route.settings.name;
        if (name == null) {
          return false;
        }
        return !name.startsWith('/game/');
      },
      arguments: nextParty,
    );
  }

  Future<void> _goToMenu(BuildContext context) async {
    AppScope.of(context).playSound(UiSound.tapSoft);
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRouter.homePath, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final nextCode = AppScope.of(
      context,
    ).codec.encode(_buildNextConfiguration(context));
    return AppBottomSheetFrame(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Партия завершена',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Новая партия откроется с теми же настройками и новым кодом.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionCard(
            color: palette.surfaceMuted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Новый код партии',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: SelectableText(
                      nextCode,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 26, letterSpacing: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openNextGame(context),
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('Следующая игра'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _goToMenu(context),
            icon: const Icon(Icons.home_rounded),
            label: const Text('В меню'),
          ),
        ],
      ),
      child: const SizedBox.shrink(),
    );
  }
}
