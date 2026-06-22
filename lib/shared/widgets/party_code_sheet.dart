import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_palette.dart';
import '../../core/models/game_type.dart';
import '../../core/models/party_configuration.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/game_registry.dart';
import '../../core/services/ui_sound_service.dart';
import 'labeled_value_row.dart';
import 'section_card.dart';

Future<void> showPartyCodeSheet(
  BuildContext context, {
  required String code,
  required PartyConfiguration configuration,
}) {
  final palette = AppPalette.of(context);

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: palette.surface,
    builder: (context) {
      final app = AppScope.of(context);

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Код партии', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SectionCard(
              color: palette.surfaceMuted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.primarySoft, palette.secondarySoft],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: SelectableText(
                      code,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 28, letterSpacing: 1.3),
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledValueRow(
                    label: 'Игра',
                    value: GameRegistry.byType(configuration.gameType).title,
                  ),
                  const SizedBox(height: 14),
                  LabeledValueRow(
                    label: 'Игроков',
                    value:
                        configuration.gameType == GameType.alias
                            ? 'Команд: ${configuration.playerCount}'
                            : '${configuration.playerCount}',
                  ),
                  const SizedBox(height: 14),
                  LabeledValueRow(
                    label: 'Режим',
                    value: configuration.dictionaryMode.label,
                  ),
                  if (configuration.spyCount != null) ...[
                    const SizedBox(height: 14),
                    LabeledValueRow(
                      label: 'Шпионов',
                      value: '${configuration.spyCount}',
                    ),
                  ],
                  if (configuration.mafiaPresetId != null) ...[
                    const SizedBox(height: 14),
                    LabeledValueRow(
                      label: 'Пресет',
                      value: configuration.mafiaPresetId!,
                    ),
                  ],
                  if (configuration.aliasRoundSeconds != null) ...[
                    const SizedBox(height: 14),
                    LabeledValueRow(
                      label: 'Раунд',
                      value: '${configuration.aliasRoundSeconds} сек',
                    ),
                  ],
                  if (configuration.aliasTargetScore != null) ...[
                    const SizedBox(height: 14),
                    LabeledValueRow(
                      label: 'Победа',
                      value: '${configuration.aliasTargetScore} очков',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                app.playSound(UiSound.successSoft);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Код скопирован.')),
                  );
                }
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Скопировать код'),
            ),
          ],
        ),
      );
    },
  );
}
